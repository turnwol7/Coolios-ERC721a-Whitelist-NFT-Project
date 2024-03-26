pragma solidity ^0.8.0;

import { Test, console } from "../lib/forge-std/src/Test.sol";
import { Coolios } from "../src/Coolios.sol";

contract CooliosFuzzTest is Test {
    Coolios public coolios;

    address[] private whitelistAddresses = [
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,
        0x617F2E2fD72FD9D5503197092aC168c91465E7f2
    ];

    bytes32[][] private proofs = [
        [0x04a10bfd00977f54cc3450c9b25c9b3a502a089eba0097ba35fc33c4ea5fcb54, 0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770],
        [0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb, 0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770],
        [0xf6d82c545c22b72034803633d3dda2b28e89fb704f3c111355ac43e10612aedc, 0x39a01635c6a38f8beb0adde454f205fffbb2157797bf1980f8f93a5f70c9f8e6],
        [0xdfbe3e504ac4e35541bebad4d0e7574668e16fefa26cd4172f93e18b59ce9486, 0x39a01635c6a38f8beb0adde454f205fffbb2157797bf1980f8f93a5f70c9f8e6]
    ];

    function setUp() public {
        string memory baseURI = "https://example.com/";
        bytes32 merkleRoot = 0xfbaa96a1f7806c1ab06f957c8fc6e60875b6880254f77b71439c7854a6b47755;
        coolios = new Coolios(baseURI, merkleRoot);
    }

    function testMint() public {
        // Iterate over each address in the whitelist and mint for each
        for (uint i = 0; i < whitelistAddresses.length; i++) {
            address account = whitelistAddresses[i];
            bytes32[] memory proof = proofs[i];


            // Verify the minting process
            uint256 initialBalance = coolios.balanceOf(account);
            coolios.mint{value: 0.1 ether}(proof, 1);
            uint256 finalBalance = coolios.balanceOf(account);

            // Assert that the balance increased by 1 after minting
            assertEq(finalBalance - initialBalance, 1, "Incorrect minting");
        }
    }

}
