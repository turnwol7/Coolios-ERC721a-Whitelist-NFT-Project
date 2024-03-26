// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "lib/ERC721A/contracts/ERC721A.sol";

import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

// ASTARIA INTERVIEW - JUSTIN BISHOP - March 19, 2024
// This contract is a ERC721A contract that allows for the minting of tokens from a whitelist

// Only addresses that are on the whitelist can mint tokens
// Addresses that are on the whitelist can only mint once
// Addresses that are not on the whitelist cannot mint

contract Coolios is ERC721A, Ownable, ReentrancyGuard {

    // FIELDS
    // Base URI for the token
    string private _baseURI_;
    // Base URI for the token PLUS token ID as string for URL
    using Strings for uint256;
    // Need MerkleProof for bytes32[];
    using MerkleProof for bytes32[];
    uint256 private immutable MAX_SUPPLY = 666;
    uint256 public MAX_BATCH_MINT = 20;
    uint256 public mintRate = 0.1 ether;
    // This is our merkle root That I made in JavaScript (getMerkleRoot.js)
    bytes32 private MerkleRoot;
    // Mapping to track whether an address has already minted
    mapping(address => bool) private _hasMinted;

    // 0x0x0x0x0x0x0x0x0x0x0x0x0
    // CONSTRUCTOR
    // 0x0x0x0x0x0x0x0x0x0x0x0x0

    // merkle root determines who can mint
    constructor(string memory baseURI, bytes32 Root)
        ERC721A("Coolios", "COOL")
        Ownable(msg.sender)
        
    {
        require(Root != bytes32(0), "Empty Root");        
        MerkleRoot = Root;
        _baseURI_ = baseURI;
    }

    // 0x0x0x0x0x0x0x0x0x0x0x0x0
    // MINT FUNCITON
    // 0x0x0x0x0x0x0x0x0x0x0x0x0

    function mint(bytes32[] memory proof, uint8 quantity)

        external
        payable
        
        checkWhitelisted(proof)
        canMintOnlyOnce
        supplyCheck(quantity)
        checkCost(mintRate, quantity)
        batchMintCheck(quantity)
        nonReentrant
    {
        _hasMinted[msg.sender] = true;
        //this _mint is from ERC721A with reduces gas costs
        _mint(msg.sender, quantity);
        _sendFunds(msg.value);
    }

    // 0x0x0x0x0x0x0x0x0x0x0x0x0
    // MODIFIER FUNCTIONS
    // 0x0x0x0x0x0x0x0x0x0x0x0x0

    // Only addresses that are on the whitelist can mint tokens
    // Addresses that are on the whitelist can only mint once
    // Addresses that are not on the whitelist cannot mint

    // checks if address is on our whitelist (getMerkleRoot.js)
    modifier checkWhitelisted(bytes32[] memory proof) {
        require(proof.verify(MerkleRoot, keccak256(abi.encodePacked(msg.sender))), "Not whitelisted!!!!!");
        _;
    }

    // Modifier to check if the address has already minted
    modifier canMintOnlyOnce() {
        require(!_hasMinted[msg.sender], "Address has already minted");
        _;
    }

    // Modifier to check if the batch mint quantity does not exceed the limit
    modifier batchMintCheck(uint256 quantity) {
        require(quantity <= MAX_BATCH_MINT, "Exceeds maximum batch mint limit");
        _;
    }

    // used in the mint function to check if mint addition is less than MAX supply
    modifier supplyCheck(uint256 quantity) {
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Max Mint Reached");
        _;
    }

    // checks if user sends enough funds for minting
    modifier checkCost(uint256 cost, uint256 quantity) {
        // if minting 10 units, 10 X the mint rate = total value to send 
        require(msg.value >= cost * quantity, "Not enough funds supplied");
        _;
    }

    // 0x0x0x0x0x0x0x0x0x0x0x0x0
        // PUBLIC FUNCTIONS
    // 0x0x0x0x0x0x0x0x0x0x0x0x0

    // Function to generate token URI
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(_baseURI_, tokenId.toString()));
    }

    // 0x0x0x0x0x0x0x0x0x0x0x0x0
    // OWNER FUNCTIONS
    // 0x0x0x0x0x0x0x0x0x0x0x0x0

    // change the merkleroot. possible if you were concerned about security for the original root
    function setMerkleRoot(bytes32 root) external onlyOwner {
        require(root.length > 0, "Empty Root");
        MerkleRoot = root;
    }

   // to take out ETH from the contract to the owner address
    function withdraw() external onlyOwner nonReentrant {
        _sendFunds(address(this).balance);
    }

    // internal used in withdraw function to send funds to owner 
    function _sendFunds(uint256 _totalAmount) internal {
        payable(address(owner())).transfer(_totalAmount);
}
}
