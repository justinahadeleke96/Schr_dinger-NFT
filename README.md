🧬 Schrodinger NFT Smart Contract

Overview

The Schrodinger NFT Contract is a Clarity smart contract that introduces a unique concept of time-delayed NFT reveal — inspired by Schrödinger’s thought experiment.
When minted, each NFT remains in an unrevealed state until a predetermined number of blocks have passed. Only after this waiting period can the NFT owner “reveal” the token’s metadata, determining its final state.

⚙️ Core Features

Time-Locked Reveal Mechanism

NFTs remain hidden until the blockchain reaches the specified reveal block.

Prevents early knowledge of metadata or rarity.

Customizable Reveal Delay

The minter chooses how many blocks after minting (reveal-after-blocks) the NFT becomes revealable.

Limited by MAX-REVEAL-BLOCKS to prevent overly long locks.

On-Chain Metadata Reveal

Once eligible, the owner calls reveal() to attach the metadata URI, permanently changing the NFT’s state to revealed.

Transfer Support

Tokens can be transferred safely before or after reveal using the transfer() function.

Ownership and Query Functions

Includes read-only helper functions to inspect token ownership, reveal status, metadata, and remaining blocks until reveal.

📜 Contract Structure

Section	Description
NFT Definition	define-non-fungible-token schrodinger-nft uint defines NFTs by numeric IDs.
Constants	Define error codes, limits (e.g., MAX-REVEAL-BLOCKS), and authorization checks.
Data Variables	Store next token ID and contract owner.
Maps	nft-data holds each NFT’s attributes (owner, mint/reveal blocks, reveal state, and metadata).
Public Functions	Mint, reveal, and transfer NFTs.
Read-Only Functions	Retrieve info like metadata URI, reveal status, and blocks until reveal.

🪙 Key Public Functions
1. mint (reveal-after-blocks uint)

Mints a new NFT with a reveal delay in blocks.

Validates that the delay is greater than u0 and below MAX-REVEAL-BLOCKS.

Mints a new NFT to the sender and stores its reveal information.

Returns the new token ID.

2. reveal (token-id uint, metadata-uri (string-ascii 256))

Reveals an NFT’s metadata after the designated block height has been reached.

Can only be called by the NFT’s owner.

Once revealed, metadata becomes immutable.

Returns (ok true) on success.

3. transfer (token-id uint, sender principal, recipient principal)

Transfers NFT ownership between two principals.

Only callable by the current owner.

Prevents self-transfers.

Updates both the NFT map and underlying token registry.

📖 Read-Only Functions
Function	Description
get-nft-info(token-id)	Returns full NFT data record.
get-token-uri(token-id)	Returns metadata URI if revealed, otherwise none.
is-revealed(token-id)	Returns whether the NFT is revealed.
blocks-until-reveal(token-id)	Returns remaining blocks before the NFT can be revealed.
get-owner(token-id)	Returns current NFT owner.
get-last-token-id()	Returns the most recently minted token ID.

🧩 Example Flow

Mint an NFT

(contract-call? .schrodinger-nft mint u100)


→ Mints a new NFT that can be revealed after 100 blocks.

Wait for Reveal Eligibility

Check progress with:

(contract-call? .schrodinger-nft blocks-until-reveal u1)


Reveal Metadata
Once block height ≥ reveal block:

(contract-call? .schrodinger-nft reveal u1 "ipfs://QmExampleMetadata")


Check Metadata

(contract-call? .schrodinger-nft get-token-uri u1)

🔒 Error Codes
Code	Meaning
u100	Not authorized
u101	NFT not found
u102	Already revealed
u103	Not ready to reveal
u104	Already minted
u105	Invalid reveal block count

🧠 Design Notes

Prevents front-running or metadata leaks before reveal.

Each token’s reveal logic is deterministic and block-height based.

Supports trust-minimized reveal phases in NFT drops.

📜 License
MIT License. Free to use, modify, and distribute with attribution.