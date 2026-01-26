// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SkinnySeed.sol";

contract SkinnySeedTest is Test {
    SkinnySeed public seed;
    address public owner = address(this);
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    address public attacker = address(0x666);

    function setUp() public {
        seed = new SkinnySeed();
    }

    // ============ DEPOSIT & RETENTION ============

    function test_DepositAddsSeed() public {
        seed.deposit(100);
        assertEq(seed.eternalSeed(), 10);
    }

    function test_SeedOnlyGrows() public {
        seed.deposit(100);
        uint256 seedBefore = seed.eternalSeed();
        seed.deposit(50);
        uint256 seedAfter = seed.eternalSeed();
        assertGe(seedAfter, seedBefore);
    }

    function testFuzz_SeedAlwaysGrows(uint256 amount) public {
        vm.assume(amount > 0 && amount < 1e30);
        uint256 seedBefore = seed.eternalSeed();
        seed.deposit(amount);
        assertGe(seed.eternalSeed(), seedBefore);
    }

    // ============ SPLIT ALLOCATION ============

    function test_SplitIsCorrect() public {
        seed.deposit(100);
        assertEq(seed.eternalSeed(), 10);
        assertEq(seed.prizePool(), 55);
        assertEq(seed.treasury(), 35);
    }

    function test_FullAmountAccountedFor() public {
        seed.deposit(100);
        uint256 total = seed.eternalSeed() + seed.prizePool() + seed.treasury();
        assertEq(total, 100);
    }

    // ============ SEED LOCK ============

    function test_CanWithdrawPrize() public {
        seed.deposit(100);
        seed.withdrawPrize(55);
        assertEq(seed.prizePool(), 0);
    }

    function test_CannotWithdrawSeed() public {
        seed.deposit(100);
        vm.expectRevert(SkinnySeed.CannotWithdrawSeed.selector);
        seed.withdrawSeed(10);
    }

    function test_SeedUnchangedAfterPrizeWithdraw() public {
        seed.deposit(100);
        uint256 seedBefore = seed.eternalSeed();
        seed.withdrawPrize(55);
        assertEq(seed.eternalSeed(), seedBefore);
    }

    // ============ YIELD MATERIALIZATION ============

    function test_YieldMaterializesToSeed() public {
        seed.deposit(100);
        uint256 seedBefore = seed.eternalSeed();
        seed.materializeYields(65);
        assertGt(seed.eternalSeed(), seedBefore);
    }

    function test_YieldSplitIsProportional() public {
        seed.deposit(100);
        seed.materializeYields(65);
        assertEq(seed.eternalSeed(), 20);
        assertEq(seed.prizePool(), 110);
    }

    function test_SeedGrowsFromYield() public {
        seed.deposit(100);
        uint256 seedBefore = seed.eternalSeed();
        seed.materializeYields(100);
        uint256 seedAfter = seed.eternalSeed();
        assertGt(seedAfter, seedBefore);
    }

    function testFuzz_YieldAlwaysGrowsSeed(uint256 yieldAmount) public {
        vm.assume(yieldAmount > 0 && yieldAmount < 1e30);
        seed.deposit(100);
        uint256 seedBefore = seed.eternalSeed();
        seed.materializeYields(yieldAmount);
        assertGe(seed.eternalSeed(), seedBefore);
    }

    // ============ EDGE CASES ============

    function test_RevertOnZeroDeposit() public {
        vm.expectRevert(SkinnySeed.ZeroAmountNotAllowed.selector);
        seed.deposit(0);
    }

    function test_RevertOnWithdrawMoreThanBalance() public {
        seed.deposit(100);
        vm.expectRevert(SkinnySeed.InsufficientBalance.selector);
        seed.withdrawPrize(60);
    }

    function test_LargeDepositNoOverflow() public {
        uint256 largeAmount = 1e30;
        seed.deposit(largeAmount);
        
        uint256 expectedSeed = (largeAmount * 10) / 100;
        uint256 expectedPrize = (largeAmount * 55) / 100;
        uint256 expectedTreasury = (largeAmount * 35) / 100;
        
        assertEq(seed.eternalSeed(), expectedSeed);
        assertEq(seed.prizePool(), expectedPrize);
        assertEq(seed.treasury(), expectedTreasury);
    }

    function test_MultipleDepositsAccumulate() public {
        seed.deposit(100);
        seed.deposit(100);
        seed.deposit(100);
        
        assertEq(seed.eternalSeed(), 30);
        assertEq(seed.prizePool(), 165);
        assertEq(seed.treasury(), 105);
    }

    function test_WithdrawExactBalance() public {
        seed.deposit(100);
        seed.withdrawPrize(55);
        assertEq(seed.prizePool(), 0);
    }

    function test_PartialWithdraw() public {
        seed.deposit(100);
        seed.withdrawPrize(25);
        assertEq(seed.prizePool(), 30);
    }

    // ============ ACCESS CONTROL ============

    function test_OwnerSetOnDeploy() public {
        assertEq(seed.owner(), owner);
    }

    function test_OnlyOwnerCanWithdrawPrize() public {
        seed.deposit(100);
        vm.prank(attacker);
        vm.expectRevert(SkinnySeed.OnlyOwner.selector);
        seed.withdrawPrize(55);
    }

    function test_OnlyOwnerCanWithdrawTreasury() public {
        seed.deposit(100);
        vm.prank(attacker);
        vm.expectRevert(SkinnySeed.OnlyOwner.selector);
        seed.withdrawTreasury(35);
    }

    function test_OwnerCanWithdrawTreasury() public {
        seed.deposit(100);
        seed.withdrawTreasury(35);
        assertEq(seed.treasury(), 0);
    }

    function test_OnlyOwnerCanTransferOwnership() public {
        vm.prank(attacker);
        vm.expectRevert(SkinnySeed.OnlyOwner.selector);
        seed.transferOwnership(attacker);
    }

    function test_OwnerCanTransferOwnership() public {
        seed.transferOwnership(user1);
        assertEq(seed.owner(), user1);
    }

    function test_AttackerCannotWithdrawSeed() public {
        seed.deposit(100);
        vm.prank(attacker);
        vm.expectRevert(SkinnySeed.CannotWithdrawSeed.selector);
        seed.withdrawSeed(10);
    }

    // ============ MULTI-USER ============

    function test_MultipleUsersCanDeposit() public {
        vm.prank(user1);
        seed.deposit(100);
        
        vm.prank(user2);
        seed.deposit(200);
        
        vm.prank(user3);
        seed.deposit(300);
        
        assertEq(seed.eternalSeed(), 60);
        assertEq(seed.prizePool(), 330);
        assertEq(seed.treasury(), 210);
    }

    function test_UserDepositsTracked() public {
        vm.prank(user1);
        seed.deposit(100);
        
        vm.prank(user2);
        seed.deposit(200);
        
        assertEq(seed.userDeposits(user1), 100);
        assertEq(seed.userDeposits(user2), 200);
    }

    function test_TotalDepositorsTracked() public {
        vm.prank(user1);
        seed.deposit(100);
        
        vm.prank(user2);
        seed.deposit(200);
        
        vm.prank(user3);
        seed.deposit(300);
        
        assertEq(seed.totalDepositors(), 3);
    }

    function test_SameUserDepositsTwice() public {
        vm.prank(user1);
        seed.deposit(100);
        
        vm.prank(user1);
        seed.deposit(100);
        
        assertEq(seed.userDeposits(user1), 200);
        assertEq(seed.totalDepositors(), 1);
    }

    function test_SeedGrowsWithMultipleUsers() public {
        vm.prank(user1);
        seed.deposit(100);
        uint256 seedAfterUser1 = seed.eternalSeed();
        
        vm.prank(user2);
        seed.deposit(100);
        uint256 seedAfterUser2 = seed.eternalSeed();
        
        assertGt(seedAfterUser2, seedAfterUser1);
    }
}
