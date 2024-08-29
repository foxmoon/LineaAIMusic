// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IEfrogsNFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract MusicNFTMarket is ERC721, Ownable {
    uint256 public nextTokenId;
    uint256 public constant MINT_PRICE = 0.0001 ether; // 0.1 ETH for minting
    uint256 public constant BUY_PRICE = 400 * 10 ** 18; // 400 CROAK for buying

    struct MusicNFT {
        string coverImageURI;
        string audioFileURI;
    }

    mapping(uint256 => MusicNFT) public musicNFTs;

    IEfrogsNFT public immutable efrogsNFT;
    IERC20 public immutable croakToken;

    constructor() ERC721("MusicNFTMarket", "MNFT") Ownable(msg.sender) {
        efrogsNFT = IEfrogsNFT(0x194395587d7b169E63eaf251E86B1892fA8f1960);
        croakToken = IERC20(0xaCb54d07cA167934F57F829BeE2cC665e1A5ebEF);
    }

    function mint(string memory _coverImageURI, string memory _audioFileURI) external payable {
        require(msg.value >= MINT_PRICE, "Insufficient ETH sent");
        _mint(_coverImageURI, _audioFileURI);

        // Refund excess ETH
        if (msg.value > MINT_PRICE) {
            payable(msg.sender).transfer(msg.value - MINT_PRICE);
        }
    }

    function _mint(string memory _coverImageURI, string memory _audioFileURI) internal {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(msg.sender, tokenId);
        musicNFTs[tokenId] = MusicNFT(_coverImageURI, _audioFileURI);
    }

    function buyWithCROAK(uint256 tokenId) external {
        require(_isTokenValid(tokenId), "Token does not exist");
        require(croakToken.transferFrom(msg.sender, ownerOf(tokenId), BUY_PRICE), "CROAK transfer failed");
        _transfer(ownerOf(tokenId), msg.sender, tokenId);
    }

    function exchangeWithEfrogs(uint256 musicTokenId, uint256 efrogsTokenId) external {
        require(_isTokenValid(musicTokenId), "Music token does not exist");
        address musicOwner = ownerOf(musicTokenId);
        efrogsNFT.transferFrom(msg.sender, musicOwner, efrogsTokenId);
        _transfer(musicOwner, msg.sender, musicTokenId);
    }

    function withdraw() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        uint256 croakBalance = croakToken.balanceOf(address(this));

        if (ethBalance > 0) {
            payable(owner()).transfer(ethBalance);
        }

        if (croakBalance > 0) {
            require(croakToken.transfer(owner(), croakBalance), "CROAK withdrawal failed");
        }
    }

    function withdrawEfrogs(uint256 tokenId) external onlyOwner {
        efrogsNFT.transferFrom(address(this), owner(), tokenId);
    }

    function _isTokenValid(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
