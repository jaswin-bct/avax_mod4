// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    event Redeem(address indexed from, uint256 itemId, uint256 quantity);

    struct Item {
        uint256 price;
        uint256 quantity;
    }

    mapping(uint256 => Item) public storeItems;
    uint256 public itemCount;

    constructor() ERC20("Degen Token", "DGNT") {
    }

    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(value > 0, "Invalid value");

        _mint(to, value);
        emit Transfer(address(0), to, value);
    }

    function redeem(uint256 itemId, uint256 quantity) external {
        require(itemId > 0 && itemId <= itemCount, "Invalid item ID");
        require(quantity > 0, "Quantity must be greater than zero");
        require(storeItems[itemId].quantity >= quantity, "Item not available");

        uint256 totalCost = storeItems[itemId].price * quantity;
        require(balanceOf(msg.sender) >= totalCost, "Insufficient balance");

        _transfer(msg.sender, owner(), totalCost);
        storeItems[itemId].quantity -= quantity;

        emit Redeem(msg.sender, itemId, quantity);
    }

    function addItem(uint256 price, uint256 initialQuantity) external onlyOwner {
        require(price > 0, "Invalid price");
        require(initialQuantity > 0, "Invalid quantity");

        itemCount++;
        storeItems[itemCount] = Item(price, initialQuantity);
    }

    function burn(uint256 amount) external {
        require(amount > 0 && balanceOf(msg.sender) >= amount, "Insufficient balance");

        _burn(msg.sender, amount);
    }
}
