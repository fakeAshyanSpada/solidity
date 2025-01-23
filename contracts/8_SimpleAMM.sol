// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SimpleAMM {
    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public constantProduct;
    bytes32  public hashA;
    bytes32  public hashB;

    event Swap(address indexed user, string inputToken, uint256 amountIn, uint256 amountOut);

    constructor(string memory  _tokenA, string memory _tokenB, uint256  _reserveA, uint256  _reserveB) {
        require(_reserveA > 0 && _reserveB > 0, "invalid reserves");
        hashA = keccak256(abi.encodePacked(_tokenA));
        hashB = keccak256(abi.encodePacked(_tokenB));
        reserveA = _reserveA;
        reserveB = _reserveB;
        constantProduct = _reserveA * _reserveB;
    }

    function swap(uint256 amountIn, string memory inputToken)  public returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than 0");
        bytes32 tokenHash = keccak256(abi.encodePacked(inputToken));
        require(tokenHash == hashA || tokenHash == hashB, "Invalid token");
        if (tokenHash == hashA) {
            uint256 newReserveA = reserveA + amountIn;
            uint256 newReserveB = constantProduct / newReserveA;
            amountOut = reserveB - newReserveB;

            reserveA = newReserveA;
            reserveB = newReserveB;
        } else {
            uint256 newReserveB = reserveB + amountIn;
            uint256 newReserveA = constantProduct / newReserveB;
            amountOut = reserveA - newReserveA;

            reserveA = newReserveA;
            reserveB = newReserveB;
        }
    } 

    function getPrice() public view returns (uint256) {
        return reserveA / reserveB;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}