pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MerkleGen.sol";

library MerkleProofLib {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool isValid) {
        uint256 len = proof.length;
        if (len == 0) return leaf == root;
        // Set up a pointer to the first element in proof array in memory.
        // (In memory, the first 32 bytes hold the length, so the array elements start at proof + 32.)
        uint256 offset = 32;
        assembly {
            // Loop through each element in proof
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // Get the sibling value from proof
                let sibling := mload(add(proof, add(32, mul(i, 32))))
                // Sort the two hashes such that the lower one comes first (if desired)
                switch gt(leaf, sibling)
                case 1 {
                    mstore(0x00, sibling)
                    mstore(0x20, leaf)
                }
                default {
                    mstore(0x00, leaf)
                    mstore(0x20, sibling)
                }
                // Compute the new leaf by hashing
                leaf := keccak256(0x00, 64)
            }
            isValid := eq(leaf, root)
        }
    }
}

contract MerkleTest is Test {
    MerkleGenerator generator;
    
    function setUp() public {
        generator = new MerkleGenerator();
    }

    function testGenerateProofs() public {
        address[] memory addresses = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        
        addresses[0] = 0xBbD90676f0180eBFB021116F126ca266fa33849f;
        amounts[0] = 1;
        
        addresses[1] = 0xB74bdf2F6F02A5CD7981Fa5A1E684085663AED87;
        amounts[1] = 2;
        
        addresses[2] = 0x669eDae31726a5aB713fFa3DB92050c5f5D7C25B;
        amounts[2] = 3;

        (bytes32 root, bytes32[][] memory proofs) = generator.generateClaimsRootAndProofs(
            addresses,
            amounts
        );

        console.log("MERKLE_ROOT: %s", vm.toString(root));
        
        console.log("\nPROOFS:");
        for (uint256 i = 0; i < proofs.length; i++) {
            console.log("Proof for address %s:", addresses[i]);
            for (uint256 j = 0; j < proofs[i].length; j++) {
                console.log(vm.toString(proofs[i][j]));
            }
        }
    }

    function testGenerateAndVerifyProofs() public view {
        address[] memory addresses = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        
        addresses[0] = 0x1111111111111111111111111111111111111111;
        amounts[0] = 1;
        
        addresses[1] = 0x2222222222222222222222222222222222222222;
        amounts[1] = 2;
        
        addresses[2] = 0x3333333333333333333333333333333333333333;
        amounts[2] = 3;

        (bytes32 root, bytes32[][] memory proofs) = generator.generateClaimsRootAndProofs(
            addresses,
            amounts
        );

        // Verify each proof
        for (uint256 i = 0; i < addresses.length; i++) {
            bytes32 leaf = keccak256(abi.encodePacked(
                keccak256(abi.encodePacked(addresses[i], amounts[i]))
            ));
            
            bool isValid = MerkleProofLib.verify(proofs[i], root, leaf);
            assertTrue(isValid, "Proof verification failed");
        }
    }
}