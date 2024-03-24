pragma solidity ^0.8.0;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Coolios} from "../src/Coolios.sol";

contract CooliosFuzzTest is Test {
    Coolios public coolios;
    bytes32[] public merkleProof;

    function setUp() public {
        coolios = new Coolios("BaseURI", bytes32(0));
        // Mocking the Merkle proof for testing purposes
        merkleProof = generateMerkleProofForAddress(msg.sender);
        // Assuming msg.sender's address is included in the Merkle tree
    }

    function testFuzz_MintWithRandomAddresses(uint256 numAttempts) public {
        for (uint256 i = 0; i < numAttempts; i++) {
            // Generate a random address for testing
            address randomAddress = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, i)))));
            // Verify if the random address is in the Merkle tree
            if (verifyAddressInMerkleTree(randomAddress)) {
                try coolios.mint(merkleProof, 1) {
                    revert("Minting should fail for random addresses not in Merkle tree");
                } catch {}
            } else {
                revert("Minting should succeed for addresses in Merkle tree");
            }
        }
    }

    // Mock function to generate Merkle proof for an address
    function generateMerkleProofForAddress(address _address) internal pure returns (bytes32[] memory) {
      
        bytes32[] memory proof; // Placeholder for proof
        return proof;
    }

    // Mock function to verify if an address is in the Merkle tree
    function verifyAddressInMerkleTree(address _address) internal pure returns (bool) {
       
        return true;
    }
}
