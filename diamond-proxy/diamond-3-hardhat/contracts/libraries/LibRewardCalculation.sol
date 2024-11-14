// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import { IRewardPool } from "../interfaces/dpos-interfaces/staking/IRewardPool.sol";

library LibRewardCalculation {
  // 32 bytes keccak hash of a string to use as a reward calculation storage location.
  bytes32 constant REWARD_CALCULATION_STORAGE_POSITION = keccak256("diamond.standard.reward.storage");

  struct RewardCalculationStorage {
    /// @dev Mapping from pool address => period number => accumulated rewards per share (one unit staking)
    mapping(address poolId => mapping(uint256 periodNumber => IRewardPool.PeriodWrapper)) _accumulatedRps;
    /// @dev Mapping from the pool address => user address => the reward info of the user
    mapping(address poolId => mapping(address user => IRewardPool.UserRewardFields)) _userReward;
    /// @dev Mapping from the pool address => reward pool fields
    mapping(address poolId => IRewardPool.PoolFields) _stakingPool;
  }
}
