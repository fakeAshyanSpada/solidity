// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

contract MyContract {
  IUniswapV3Pool pool;

  function doSomethingWithPool() public {
    // pool.swap(...);
  }
}
