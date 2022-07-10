// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MessiCollection is ERC721Enumerable, Ownable {
    uint256 public _price = 0.01 ether;

    bool public _paused;

    uint256 public maxTokenIds = 13;

    uint256 public tokenIds;

    string _baseTokenURI;

    //I learned that this is an importante feature if you want to prevent a security problem from escalating.

    modifier onlyWhenNotPaused() {
        require(
            !_paused,
            "This contract is currently in pause. Please wait until we fix the issue."
        );
        _;
    }

    // As you can see, it's possible to set the baseURI when you first deploy this contract. This way, this contract
    // can be used in more than a deployment, because the baseURI isn't static.

    constructor(string memory baseURI) ERC721("Messi Collection", "M10") {
        _baseTokenURI = baseURI;
    }

    function mint() public payable onlyWhenNotPaused {
        require(tokenIds < maxTokenIds, "Exceed maximum supply.");
        require(msg.value >= _price, "Ether sent is not enough.");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    // This function overrides the implementation from OZ, returning our _baseTokenURI instead.
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    // This function uses onlyOwner modifier and is useful to withdraw the ether obtained from minting.
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // As Solidity by example explains, this functions are required if some people make errors when sending transactions.
    receive() external payable {}

    fallback() external payable {}
}
