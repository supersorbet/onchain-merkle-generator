# solidity/On Chain Merkle Proof Generator 🔗

A zero-deps solidity utility for generating Merkle roots + proofs & testing w/ forge or directly in your contracts. Foundry-ready and optimized

@supersorbet

## Start

1. **Grab package**:
```bash
forge install supersorbet/onchainmerkle-generator
```

2. **Basic usage**:
```solidity
import "merkle-generator/src/MerkleGen.sol";

contract myAirdropOrSumthinLikeThat {
    using MerkleGenerator for MerkleGenerator;
    
    bytes32 public merkleRoot;
    
    function setRoot(address[] calldata users, uint256[] calldata amounts) public {
        (merkleRoot, ) = MerkleGenerator.generateClaimsRootAndProofs(users, amounts);
    }

    function claim(address user, uint256 amount, bytes32[] calldata proof) public {
        bytes32 leaf = keccak256(abi.encodePacked(
            keccak256(abi.encodePacked(user, amount)) // Double-hash!
        ));
        
        require(verifyProof(merkleRoot, proof, leaf), "Bad proof");
        // Your claim logic here
    }
}
```

## Why?
because rewriting merkle logic for every project is tedious and node packages are a pain in the ass sometimes

---

## Features 🛠️
- Generate roots + proofs in one call
- Prevents hash collisions with double-hashing
- Gas-optimized tree construction
- Works with any address/amount combos

## CLI ✨
```bash
# Generate proofs from command line
./scripts/generate-merkle.sh \
    0xYourContractAddress \
    "[0x111...,0x222...]" \
    "[100,200...]"
```

## Safety Stuff ⚠️
- **Encoding matters** - Keep your leaf format consistent
- **Test your hashes** - See [verification tests](test/MerkleTest.t.sol)
- **Gas limits** - Works best for <1000 leaves

---

## Foundry Toolkit Overview 🔨

**Foundry is a blazing fast Ethereum development toolkit written in Rust.** It includes:

- **Forge**: Testing & deployment framework
- **Cast**: CLI for contract interactions
- **Anvil**: Local testnet node
- **Chisel**: Solidity REPL

### Basic Commands

```bash
# Build project
forge build

# Run tests
forge test

# Format code
forge fmt

# Gas snapshots
forge snapshot

# Start local node
anvil

# Deploy contracts
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PK>
```

### Need Help?
```bash
forge --help
anvil --help
cast --help
```

Full docs: [book.getfoundry.sh](https://book.getfoundry.sh/)

---

Made with 🫀 by [Your Name]. Feedback and PRs welcome.
