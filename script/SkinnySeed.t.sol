// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SkinnySeed.sol";

contract SkinnySeedTest is Test {
    SkinnySeed public seed;

    function setUp() public {
        seed = new SkinnySeed();
    }

    function test_DepositAddsSeed() public {
        seed.deposit(100);
        assertEq(seed.eternalSeed(), 10); // 10% of 100
    }

    function test_SeedOnlyGrows() public {
        seed.deposit(100);
        uint256 seedBefore = seed.eternalSeed();
        seed.deposit(50);
        uint256 seedAfter = seed.eternalSeed();
        assertGe(seedAfter, seedBefore); // seed can only grow
    }
}