// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MessiCollection is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    uint256 public _price = 1 ether / 100;

    bool public _paused;

    uint256 public maxTokenIds = 13;

    Counters.Counter public tokenIds;

    string _baseTokenURI;

    event Mint(uint256 tokenId);

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

    // mint a new token
    function mint() public payable onlyWhenNotPaused {
        require(tokenIds.current() + 1 < maxTokenIds, "Exceed maximum supply.");
        require(msg.value >= _price, "Ether sent is not enough.");
        
        _safeMint(msg.sender, tokenIds.current());
        emit Mint(tokenIds.current());
        tokenIds.increment();        
    }

    // This function overrides the implementation from OZ, returning our _baseTokenURI instead.
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // pause contract from executing transactions
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    // check balance of ether in contract
    function contractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    // This function uses onlyOwner modifier and is useful to withdraw the ether obtained from minting.
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        require(address(this).balance > 0, "No ether available in contract");
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // As Solidity by example explains, this functions are required if some people make errors when sending transactions.
    receive() external payable {}

    fallback() external payable {}
}
