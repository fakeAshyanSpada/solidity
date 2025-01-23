// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SimpleAMM {
    // 流动池中的两种资产
    uint256 public reserveA;
    uint256 public reserveB;

    // 恒定乘积
    uint256 public constantProduct;
    
    // A资产名
    string  public tokenA;
    // B资产名
    string  public tokenB;
    // A资产名Hash
    bytes32 public hashA;
    // B资产名Hash
    bytes32 public hashB;

    // 流动性提供者份额
    mapping(address => uint256) public liquidityShares;
    uint256 public totalLiquidityShares;

    // 手续费率
    uint256 public immutable FEE_RATE;

    // 事件
    event Swap(address indexed user, string inputToken, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address indexed user, uint256 amountA, uint256 amountB, uint256 amountShares);
    event RemoveLiquidity(address indexed user, uint256 amountA, uint256 amountB, uint256 amountShares);

    constructor(string memory  _tokenA, string memory _tokenB, uint256  _reserveA, uint256  _reserveB, uint256 _feeRate) {
        require(_reserveA > 0 && _reserveB > 0, "invalid reserves");
        hashA = keccak256(abi.encodePacked(_tokenA));
        hashB = keccak256(abi.encodePacked(_tokenB));
        reserveA = _reserveA;
        reserveB = _reserveB;
        tokenA = _tokenA;
        tokenB = _tokenB;
        constantProduct = _reserveA * _reserveB;
        FEE_RATE = _feeRate;
    }

    function swap(uint256 amountIn, string memory inputToken)  public returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than 0");
        bytes32 tokenHash = keccak256(abi.encodePacked(inputToken));
        require(tokenHash == hashA || tokenHash == hashB, "Invalid token");
        // 计算手续费
        uint256 fee = (amountIn * FEE_RATE) / 1000;
        amountIn = amountIn - fee;

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
        emit Swap(msg.sender, inputToken, amountIn, amountOut);
    }

    // 添加流动性
    function addLiquidity(uint256 amountA, uint256 amountB) public returns (uint256 shares) {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than 0");

        if (totalLiquidityShares == 0) {
            shares = sqrt(amountA * amountB);
        } else {
            shares = min(
                (amountA * totalLiquidityShares) / reserveA,
                (amountB * totalLiquidityShares) / reserveB
            );
        }

        require(shares > 0, "Invalid liquidity shares");

        reserveA += amountA;
        reserveB += amountB;
        constantProduct = amountA * amountB;

        // 更新流动性提供者份额
        liquidityShares[msg.sender] += shares;
        totalLiquidityShares += shares;

        emit AddLiquidity(msg.sender, amountA, amountB, shares);
    }

    // 移除流动性
    function removeLiquidity(uint256 shares) public returns (uint256 amountA, uint256 amountB) {
        require(shares > 0 && liquidityShares[msg.sender] >= shares, "Invalid shares");

        // 计算可提的资产数量
        amountA = (reserveA * shares) / totalLiquidityShares;
        amountB = (reserveB * shares) / totalLiquidityShares;

        // 更新流程性池
        reserveA -= amountA;
        reserveB -= amountB;
        constantProduct = reserveA * reserveB;

        // 更新流动性提供者份额
        liquidityShares[msg.sender] -= shares;
        totalLiquidityShares -= shares;

        emit RemoveLiquidity(msg.sender, amountA, amountB, shares);

    }

    function getPrice() public view returns (uint256) {
        return reserveA / reserveB;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // 辅助函数：求平方根
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // 辅助函数：取较小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}