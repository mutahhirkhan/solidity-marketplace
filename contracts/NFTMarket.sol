// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //modifier for non-reentrance
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

/*
when dealing money, we have to prevent re-entry in contract, when one contract calling another, because 
it would lead to money drainage, here we have to prevent resell of nft from the same address, means one time selling from 
one address consecutively
*/
contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter; //this would use to assign tokenId
    Counters.Counter public tokenIds; //this would monitor every token in our contract, starts from 0

    //first constructor will set the marketplace address
    //second constructor takes a name and symbol
    constructor() ERC721("Noder's digital marketplace", "NDM") {}

    function mint(string memory _tokenURI) public returns (uint256) {
        tokenIds.increment(); //it's now 1
        uint256 newItemId = tokenIds.current(); //unique identifier for every token create

        _mint(msg.sender, newItemId); //mint a token on sender address
        _setTokenURI(newItemId, _tokenURI);
        return newItemId; //when calling this contract, this id would be needed to frontend for showing details _marketplaceAddress
    }

    function currentId() external view returns (uint256) {
        return tokenIds.current();
    }
}

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private itemId; //unique id for every marketplace itemsId
    Counters.Counter private itemsSold; //this would help in to keep track of items are on sale currently e.g.(itemsId - itemsSold)

    struct MarketItem {
        uint256 itemId; //unique identifier
        address nftContract; //contract address for digital asset
        uint256 tokenId; //asset id
        address payable seller; //person putting item on sale
        address payable owner; //initially empty because yet not sold
        uint256 price; //price on sale
    }

    mapping(uint256 => MarketItem) private idToMarketItem; //retrieve specific data of item and return marketItem detail of it

    //triggeres when marketItem sold or put on sale
    //use for graph protocol to index the data from smart contract
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );

    event ItemSold(address seller, address buyer, address nft, uint256 tokenId, uint256 price);

    //nft put on sale
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "NFT_MARKETPLACE: Invalid Price");
        itemId.increment();
        uint256 _itemId = itemId.current();

        //item put on sale
        idToMarketItem[_itemId] = MarketItem(_itemId, nftContract, tokenId, payable(msg.sender), payable(address(0)), price);

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemCreated(_itemId, nftContract, tokenId, msg.sender, address(0), price);
    }

    function createMarketSale(address _nftContract, uint256 _itemId) public payable nonReentrant {
        MarketItem storage _item = idToMarketItem[_itemId];
        uint256 price = _item.price;
        uint256 tokenId = _item.tokenId;

        require(msg.value == price, "please send the required amount to process ");
        _item.seller.transfer(msg.value);
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);
        _item.owner = payable(msg.sender);
        itemsSold.increment();
        emit ItemSold(_item.seller, msg.sender, _nftContract, _itemId, _item.price);
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = itemId.current();
        uint256 unSoldItemCount = itemCount - itemsSold.current();
        uint256 currentIndex = 0;

        console.log(unSoldItemCount);
        MarketItem[] memory allMarketItems = new MarketItem[](unSoldItemCount); //the length of this array will be unsoldItems
        for (uint256 i = 0; i < itemCount; i++) {
            //check for unsold items
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                console.log(currentItem.price);
                allMarketItems[currentIndex] = currentItem;
                currentId++;
            }
        }
        // console.log(allMarketItems);
        // console.log(allMarketItems);
        return allMarketItems;
    }

    function fetchMyNTFs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = itemId.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount++;
            }
        }
        console.log(itemCount);
        MarketItem[] memory allMyItems = new MarketItem[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                allMyItems[currentId] = currentItem;
                currentIndex++;
            }
        }
        return allMyItems;
    }
}
