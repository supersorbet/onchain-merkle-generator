# Example using cast to generate Merkle data
cast call <contract address> "generateClaimsRootAndProofs(address[],uint256[])" "[0x111...,0x222...]" "[1,2...]" --rpc-url $RPC_URL 