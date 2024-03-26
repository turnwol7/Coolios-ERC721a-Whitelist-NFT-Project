const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

let whitelistAddresses = [
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
  ];

const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true});


const rootHash = merkleTree.getRoot();
console.log('Whitelist Merkle Tree\n', merkleTree.toString());
console.log("Root Hash: ", rootHash);

//example of a claiming address
// const claimingAddress = leafNodes[3];

// const hexProof = merkleTree.getHexProof(claimingAddress);
// console.log(hexProof);

// console.log(merkleTree.verify(hexProof, claimingAddress, rootHash));
//
whitelistAddresses.forEach((address) => {
  const proof =  merkleTree.getHexProof(keccak256(address));
  console.log(`Address: ${address} Proof: ${proof}\n`);
});