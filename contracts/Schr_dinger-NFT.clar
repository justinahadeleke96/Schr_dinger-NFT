;; Schrodinger NFT Contract
;; An NFT that only reveals its state after X blocks

(define-non-fungible-token schrodinger-nft uint)

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NFT-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-REVEALED (err u102))
(define-constant ERR-NOT-READY-TO-REVEAL (err u103))
(define-constant ERR-ALREADY-MINTED (err u104))
(define-constant ERR-INVALID-REVEAL-BLOCKS (err u105))

(define-constant MAX-REVEAL-BLOCKS u1000000)

(define-data-var next-token-id uint u1)
(define-data-var contract-owner principal tx-sender)

(define-map nft-data
  uint
  {
    owner: principal,
    mint-block: uint,
    reveal-block: uint,
    revealed: bool,
    metadata-uri: (optional (string-ascii 256))
  })

(define-public (mint (reveal-after-blocks uint))
  (let 
    (
      (token-id (var-get next-token-id))
      (current-block block-height)
    )
    (asserts! (> reveal-after-blocks u0) ERR-INVALID-REVEAL-BLOCKS)
    (asserts! (<= reveal-after-blocks MAX-REVEAL-BLOCKS) ERR-INVALID-REVEAL-BLOCKS)
    (asserts! (is-none (nft-get-owner? schrodinger-nft token-id)) ERR-ALREADY-MINTED)
    (try! (nft-mint? schrodinger-nft token-id tx-sender))
    (map-set nft-data token-id {
      owner: tx-sender,
      mint-block: current-block,
      reveal-block: (+ current-block reveal-after-blocks),
      revealed: false,
      metadata-uri: none
    })
    (var-set next-token-id (+ token-id u1))
    (ok token-id)
  )
)

(define-public (reveal (token-id uint) (metadata-uri (string-ascii 256)))
  (let 
    (
      (nft-info (unwrap! (map-get? nft-data token-id) ERR-NFT-NOT-FOUND))
      (current-block block-height)
    )
    (asserts! (is-eq (get owner nft-info) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get revealed nft-info)) ERR-ALREADY-REVEALED)
    (asserts! (>= current-block (get reveal-block nft-info)) ERR-NOT-READY-TO-REVEAL)
    (map-set nft-data token-id (merge nft-info {
      revealed: true,
      metadata-uri: (some metadata-uri)
    }))
    (ok true)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq sender recipient)) ERR-NOT-AUTHORIZED)
    (let ((nft-info (unwrap! (map-get? nft-data token-id) ERR-NFT-NOT-FOUND)))
      (asserts! (is-eq (get owner nft-info) sender) ERR-NOT-AUTHORIZED)
      (map-set nft-data token-id (merge nft-info { owner: recipient }))
      (nft-transfer? schrodinger-nft token-id sender recipient)
    )
  )
)

(define-read-only (get-nft-info (token-id uint))
  (map-get? nft-data token-id)
)

(define-read-only (get-token-uri (token-id uint))
  (match (map-get? nft-data token-id)
    nft-info 
      (if (get revealed nft-info)
        (get metadata-uri nft-info)
        none)
    none
  )
)

(define-read-only (is-revealed (token-id uint))
  (match (map-get? nft-data token-id)
    nft-info (get revealed nft-info)
    false
  )
)

(define-read-only (blocks-until-reveal (token-id uint))
  (match (map-get? nft-data token-id)
    nft-info 
      (if (>= block-height (get reveal-block nft-info))
        u0
        (- (get reveal-block nft-info) block-height))
    u0
  )
)

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? schrodinger-nft token-id)
)

(define-read-only (get-last-token-id)
  (- (var-get next-token-id) u1)
)
