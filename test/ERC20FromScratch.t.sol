// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20FromScratch} from "../src/ERC20FromScratch.sol";

contract CounterTest is Test {
    ERC20FromScratch public token;
    string public tokenName;
    string public tokenSymbol;
    address public owner;
    address public dummy;
    address public zero;

    function setUp() public {
        tokenName = "Thanh's Test Token";
        tokenSymbol = "TTT";
        token = new ERC20FromScratch(tokenName, tokenSymbol);
        owner = msg.sender;
        dummy = address(2187);
        zero = address(0);
    }

    function test_Name() public {
        assertEq(token.name(), tokenName);
    }

    function test_Symbol() public {
        assertEq(token.symbol(), tokenSymbol);
    }

    function test_MintBurn() public {
        token.mint(owner, 20_000_000);
        assertEq(token.balanceOf(owner), 20_000_000);
        token.burn(owner, 20_000_000);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_Transfer() public {
        token.mint(owner, 20_000_000);
        assertEq(token.balanceOf(owner), 20_000_000);

        vm.prank(owner);
        token.transfer(dummy, 10_000_000);

        assertEq(token.balanceOf(owner), 10_000_000);
        assertEq(token.balanceOf(dummy), 10_000_000);

        token.burn(owner);
        token.burn(dummy);
    }

    function test_ApproveAllowance() public {
        vm.prank(dummy);
        token.approve(owner, 20_000_000);

        assertEq(token.allowance(dummy, owner), 20_000_000);

        vm.prank(dummy);
        token.approve(owner, 0);
    }

}
