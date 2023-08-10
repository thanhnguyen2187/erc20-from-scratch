// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20FromScratch} from "../src/ERC20FromScratch.sol";

contract ERC20FromScratchTest is Test {
    ERC20FromScratch public token;
    string public tokenName;
    string public tokenSymbol;
    address public deployer;
    address public dummy;
    address public zero;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function setUp() public {
        tokenName = "Thanh's Test Token";
        tokenSymbol = "TTT";
        deployer = msg.sender;
        dummy = address(2187);
        zero = address(0);

        token = new ERC20FromScratch(tokenName, tokenSymbol);
    }

    function test_Name() public {
        assertEq(token.name(), tokenName);
    }

    function test_Symbol() public {
        assertEq(token.symbol(), tokenSymbol);
    }

    function test_MintBurn() public {
        // test
        token.mint(deployer, 20_000_000);
        assertEq(token.balanceOf(deployer), 20_000_000);

        // clean up
        token.burn(deployer);
        assertEq(token.balanceOf(deployer), 0);
    }

    function test_Transfer() public {
        // set up
        token.mint(deployer, 20_000_000);
        assertEq(token.balanceOf(deployer), 20_000_000);

        // test
        vm.prank(deployer);
        token.transfer(dummy, 10_000_000);

        assertEq(token.balanceOf(deployer), 10_000_000);
        assertEq(token.balanceOf(dummy), 10_000_000);

        // clean up
        token.burn(deployer);
        token.burn(dummy);
        assertEq(token.balanceOf(deployer), 0);
        assertEq(token.balanceOf(dummy), 0);
    }

    function test_ApproveAllowance() public {
        // test
        vm.prank(dummy);
        token.approve(deployer, 20_000_000);

        assertEq(token.allowance(dummy, deployer), 20_000_000);

        // clean up
        vm.prank(dummy);
        token.approve(deployer, 0);

        assertEq(token.allowance(dummy, deployer), 0);
    }

    function test_TransferFrom_Success() public {
        // set up
        token.mint(dummy, 20_000_000);

        // test
        vm.prank(dummy);
        token.approve(deployer, 20_000_000);
        assertEq(token.allowance(dummy, deployer), 20_000_000);

        vm.prank(deployer);
        token.transferFrom(dummy, deployer, 10_000_000);
        assertEq(token.balanceOf(deployer), 10_000_000);
        assertEq(token.allowance(dummy, deployer), 10_000_000);

        // clean up
        token.burn(dummy);

        vm.prank(dummy);
        token.approve(deployer, 0);
        assertEq(token.allowance(dummy, deployer), 0);
    }

    function test_MintBurnEvents() public {
        // test
        vm.expectEmit(true, true, true, true);
        emit Transfer(zero, deployer, 20_000_000);

        token.mint(deployer, 20_000_000);
        assertEq(token.balanceOf(deployer), 20_000_000);

        // clean up
        vm.expectEmit(true, true, true, true);
        emit Transfer(deployer, zero, 20_000_000);

        token.burn(deployer);
        assertEq(token.balanceOf(deployer), 0);
    }
}
