// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Coolios} from "../src/Coolios.sol";
import "../lib/forge-std/src/StdCheats.sol";

contract CooliosFuzzTest is Test {
    Coolios public coolios;

    //these are 4 addresses from my Remix account
    address[] public whitelistAddresses = [
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,
        0x617F2E2fD72FD9D5503197092aC168c91465E7f2
    ];

    //proofs for the whitelist addresses generated offchain in getmerkle.js
    bytes32[][] public proofs = [
    [
        bytes32(0x04a10bfd00977f54cc3450c9b25c9b3a502a089eba0097ba35fc33c4ea5fcb54),
        bytes32(0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770)
    ],
    [
        bytes32(0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb),
        bytes32(0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770)
    ],
    [
        bytes32(0xf6d82c545c22b72034803633d3dda2b28e89fb704f3c111355ac43e10612aedc),
        bytes32(0x39a01635c6a38f8beb0adde454f205fffbb2157797bf1980f8f93a5f70c9f8e6)
    ],
    [
        bytes32(0xdfbe3e504ac4e35541bebad4d0e7574668e16fefa26cd4172f93e18b59ce9486),
        bytes32(0x39a01635c6a38f8beb0adde454f205fffbb2157797bf1980f8f93a5f70c9f8e6)
    ]
];

    
    function setUp() public {
        string memory baseURI = "https://example.com/";
        bytes32 merkleRoot = 0xfbaa96a1f7806c1ab06f957c8fc6e60875b6880254f77b71439c7854a6b47755;
        coolios = new Coolios(baseURI, merkleRoot);
        address cooliosAddress = address(coolios);
        emit log_address(cooliosAddress);
    }

    //test for the contract address
    function test_whatIsContractAddress() public {
        address cooliosAddress = address(coolios);
        emit log_address(cooliosAddress);
    }

    //test for the msg.sender
    function test_MintingCoolios() public{
        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
  
        vm.deal(whitelistAddresses[i], 5 ether);
        vm.startPrank(whitelistAddresses[i]);
        address _testAddr = coolios.getMsgSenderFromCoolios(); 
        //assert that the address is the same as the whitelist address
        emit log_address(_testAddr);
        assertEq(_testAddr, whitelistAddresses[i]);
        coolios.mint{value: 100000000000000000 }(proofs[i], 1);
        vm.stopPrank();
        }
        //after the loop of 4 white list addresses have minted,
        //supply should be 4
        uint256 supply = coolios.totalSupply();
        emit log_uint(supply);
        assertEq(supply, 4);
    }

    //test that supply is 0 after the contract is deployed
    function test_ZeroSupply() public {
        //test should be zero because Foundru resets functio to function
        uint256 supply = coolios.totalSupply();
        emit log_uint(supply);
        assertEq(supply, 0);
    }
}