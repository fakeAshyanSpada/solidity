// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SimpleAMM {
    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public constantProduct;
    bytes32  public tokenA;
    bytes32  public tokenB;

    event Swap(address indexed user, string inputToken, uint256 amountIn, uint256 amountOut);

    constructor(bytes32  _tokenA, bytes32 _tokenB, uint256  _reserveA, uint256  _reserveB) {
        require(_reserveA > 0 && _reserveB > 0, "invalid reserves");
        tokenA = _tokenA;
        tokenB = _tokenB;
        reserveA = _reserveA;
        reserveB = _reserveB;
        constantProduct = _reserveA * _reserveB;
    }

    function swap(uint256 amountIn, bytes32  inputToken)  public returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than 0");
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");
        if (inputToken == tokenA) {
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