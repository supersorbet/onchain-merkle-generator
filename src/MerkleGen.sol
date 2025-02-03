pragma solidity ^0.8.20;

contract MerkleGenerator {
    error LengthMismatch();
    error EmptyLeaves();
    error IndexOutOfBounds();
    
    function generateClaimsRootAndProofs(//for claims (address + amount)
        address[] memory addresses,
        uint256[] memory amounts
    ) public pure returns (bytes32 root, bytes32[][] memory proofs) {
        if (addresses.length != amounts.length) revert LengthMismatch();
        if (addresses.length == 0) revert EmptyLeaves();

        bytes32[] memory leaves = new bytes32[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(
                keccak256(abi.encodePacked(addresses[i], amounts[i]))
            ));
        }
        
        root = buildRoot(leaves);
        proofs = new bytes32[][](leaves.length);
        
        for (uint256 i = 0; i < leaves.length; i++) {
            proofs[i] = getProof(leaves, i);
        }
    }
    
    function generateRootAndProofs(
        bytes32[] memory leaves
    ) public pure returns (bytes32 root, bytes32[][] memory proofs) {
        if (leaves.length == 0) revert EmptyLeaves();
        
        root = buildRoot(leaves);
        proofs = new bytes32[][](leaves.length);
        
        for (uint256 i = 0; i < leaves.length; i++) {
            proofs[i] = getProof(leaves, i);
        }
    }

    function buildRoot(bytes32[] memory leaves) internal pure returns (bytes32) {
        if (leaves.length == 0) return bytes32(0);
        if (leaves.length == 1) return leaves[0];

        bytes32[] memory layer = leaves;

        while (layer.length > 1) {
            uint256 newLength = (layer.length + 1) / 2;
            bytes32[] memory newLayer = new bytes32[](newLength);

            for (uint256 i = 0; i < newLength; i++) {
                uint256 left = 2 * i;
                uint256 right = 2 * i + 1;
                if (right >= layer.length) {
                    newLayer[i] = layer[left];
                } else {
                    bytes32 leftHash = layer[left];
                    bytes32 rightHash = layer[right];
                    newLayer[i] = leftHash < rightHash 
                        ? keccak256(abi.encodePacked(leftHash, rightHash))
                        : keccak256(abi.encodePacked(rightHash, leftHash));
                }
            }

            layer = newLayer;
        }

        return layer[0];
    }

    function getProof(
        bytes32[] memory leaves,
        uint256 index
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory tempProof = new bytes32[](32); //max depth for simplicity lol
        uint256 pos = 0;
        bytes32[] memory currentLayer = leaves;

        while (currentLayer.length > 1) {
            if (index % 2 == 1) {
                tempProof[pos++] = currentLayer[index - 1];
            } else if (index + 1 < currentLayer.length) {
                tempProof[pos++] = currentLayer[index + 1];
            }

            index /= 2;
            currentLayer = buildNextLayer(currentLayer);
        }

        bytes32[] memory proof = new bytes32[](pos);
        for (uint256 i = 0; i < pos; i++) {
            proof[i] = tempProof[i];
        }

        return proof;
    }

    function buildNextLayer(
        bytes32[] memory layer
    ) private pure returns (bytes32[] memory) {
        uint256 newLength = (layer.length + 1) / 2;
        bytes32[] memory newLayer = new bytes32[](newLength);

        for (uint256 i = 0; i < newLength; i++) {
            uint256 left = 2 * i;
            uint256 right = 2 * i + 1;
            if (right >= layer.length) {
                newLayer[i] = layer[left];
            } else {
                newLayer[i] = keccak256(
                    abi.encodePacked(layer[left], layer[right])
                );
            }
        }

        return newLayer;
    }

    function log2(uint256 x) private pure returns (uint256) {
        uint256 n = 0;
        while (x > 1) {
            x >>= 1;
            n++;
        }
        return n;
    }
}
