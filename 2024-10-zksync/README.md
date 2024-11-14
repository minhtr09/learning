# ZKsync

### Prize Pool TO BE FILLED OUT BY CYFRIN

- Total Pool - $500,000
- H/M - $475,000
- Low - $25,000

- Starts: October 28, 2024 Noon UTC
- Ends: Dec 02, 2024 Noon UTC

- nSLOC: 15,741

[//]: # (contest-details-open)

## About the Project

ZKsync Era is an EVM compatible layer 2 rollup that uses zero-knowledge proofs to scale Ethereum without compromising on security or decentralization.

[Documentation](https://docs.zksync.io/)
[Website](https://zksync.io/)  
[Twitter](https://x.com/zksync)  
[GitHub](https://github.com/matter-labs)

## Relevant Documentation

[Contracts](https://github.com/matter-labs/era-contracts/blob/gateway-release-candidate/docs/README.md)  
[ZKsync Governance](https://docs.zknation.io/zksync-governance/zksync-governance-procedures-overview)

[//]: # (contest-details-close)
[//]: # (scope-open)

## Scope (contracts)

### Era-Contracts

```js
├── da-contracts
│   ├── contracts
│   │   ├── CalldataDA.sol
│   │   ├── DAContractsErrors.sol
│   │   ├── DAUtils.sol
│   │   ├── IL1DAValidator.sol
│   │   ├── IL1Messenger.sol
│   │   └── RollupL1DAValidator.sol
├── l1-contracts
│   ├── contracts
│   │   ├── bridge
│   │   │   ├── BridgeHelper.sol
│   │   │   ├── BridgedStandardERC20.sol
│   │   │   ├── L1BridgeContractErrors.sol
│   │   │   ├── L1ERC20Bridge.sol
│   │   │   ├── L1Nullifier.sol
│   │   │   ├── L2SharedBridgeLegacy.sol
│   │   │   ├── L2WrappedBaseToken.sol
│   │   │   ├── L2WrappedBaseTokenStore.sol
│   │   │   ├── asset-router
│   │   │   │   ├── AssetRouterBase.sol
│   │   │   │   ├── IAssetRouterBase.sol
│   │   │   │   ├── IL1AssetRouter.sol
│   │   │   │   ├── IL2AssetRouter.sol
│   │   │   │   ├── L1AssetRouter.sol
│   │   │   │   └── L2AssetRouter.sol
|   |   │   ├── interfaces
|   |   │   │   ├── IAssetHandler.sol
|   |   │   │   ├── IBridgedStandardToken.sol
|   |   │   │   ├── IL1AssetDeploymentTracker.sol
|   |   │   │   ├── IL1AssetHandler.sol
|   |   │   │   ├── IL1BaseTokenAssetHandler.sol
|   |   │   │   ├── IL1ERC20Bridge.sol
|   |   │   │   ├── IL1Nullifier.sol
|   |   │   │   ├── IL1SharedBridgeLegacy.sol
|   |   │   │   ├── IL2SharedBridgeLegacy.sol
|   |   │   │   ├── IL2SharedBridgeLegacyFunctions.sol
|   |   │   │   ├── IL2WrappedBaseToken.sol
|   |   │   │   └── IWETH9.sol
|   |   │   └── ntv
|   |   │       ├── IL1NativeTokenVault.sol
|   |   │       ├── IL2NativeTokenVault.sol
|   |   │       ├── INativeTokenVault.sol
|   |   │       ├── L1NativeTokenVault.sol
|   |   │       ├── L2NativeTokenVault.sol
|   |   │       └── NativeTokenVault.sol
│   │   ├── bridgehub
│   │   │   ├── Bridgehub.sol
│   │   │   ├── CTMDeploymentTracker.sol
│   │   │   ├── IBridgehub.sol
│   │   │   ├── ICTMDeploymentTracker.sol
│   │   │   ├── IMessageRoot.sol
│   │   │   ├── L1BridgehubErrors.sol
│   │   │   └── MessageRoot.sol
│   │   ├── common
│   │   │   ├── Config.sol
│   │   │   ├── Dependencies.sol
│   │   │   ├── L1ContractErrors.sol
│   │   │   ├── L2ContractAddresses.sol
│   │   │   ├── Messaging.sol
│   │   │   ├── ReentrancyGuard.sol
│   │   │   ├── interfaces
│   │   │   │   ├── IL1Messenger.sol
│   │   │   │   └── IL2ContractDeployer.sol
│   │   │   └── libraries
│   │   │       ├── DataEncoding.sol
│   │   │       ├── DynamicIncrementalMerkle.sol
│   │   │       ├── FullMerkle.sol
│   │   │       ├── L2ContractHelper.sol
│   │   │       ├── Merkle.sol
│   │   │       ├── MessageHashing.sol
│   │   │       ├── SemVer.sol
│   │   │       ├── SystemContractsCaller.sol
│   │   │       ├── UncheckedMath.sol
│   │   │       └── UnsafeBytes.sol
│   │   ├── governance
│   │   │   ├── AccessControlRestriction.sol
│   │   │   ├── ChainAdmin.sol
│   │   │   ├── Common.sol
│   │   │   ├── IAccessControlRestriction.sol
│   │   │   ├── IChainAdmin.sol
│   │   │   ├── IPermanentRestriction.sol
│   │   │   ├── L2AdminFactory.sol
│   │   │   ├── L2ProxyAdminDeployer.sol
│   │   │   ├── PermanentRestriction.sol
│   │   │   ├── TransitionaryOwner.sol
│   │   ├── state-transition
│   │   │   ├── ChainTypeManager.sol
│   │   │   ├── IChainTypeManager.sol
│   │   │   ├── L1StateTransitionErrors.sol
│   │   │   ├── ValidatorTimelock.sol
│   │   │   ├── Verifier.sol
│   │   │   ├── chain-deps
│   │   │   │   ├── DiamondInit.sol
│   │   │   │   ├── DiamondProxy.sol
│   │   │   │   ├── GatewayCTMDeployer.sol
│   │   │   │   ├── ZKChainStorage.sol
│   │   │   │   └── facets
│   │   │   │       ├── Admin.sol
│   │   │   │       ├── Executor.sol
│   │   │   │       ├── Getters.sol
│   │   │   │       ├── Mailbox.sol
│   │   │   │       └── ZKChainBase.sol
│   │   │   ├── chain-interfaces
│   │   │   │   ├── IAdmin.sol
│   │   │   │   ├── IDiamondInit.sol
│   │   │   │   ├── IExecutor.sol
│   │   │   │   ├── IGetters.sol
│   │   │   │   ├── IL1DAValidator.sol
│   │   │   │   ├── ILegacyGetters.sol
│   │   │   │   ├── IMailbox.sol
│   │   │   │   ├── ITransactionFilterer.sol
│   │   │   │   ├── IVerifier.sol
│   │   │   │   ├── IZKChain.sol
│   │   │   │   └── IZKChainBase.sol
│   │   │   ├── data-availability
│   │   │   │   ├── CalldataDA.sol
│   │   │   │   ├── CalldataDAGateway.sol
│   │   │   │   ├── RelayedSLDAValidator.sol
│   │   │   │   ├── RollupDAManager.sol
│   │   │   │   └── ValidiumL1DAValidator.sol
│   │   │   ├── l2-deps
│   │   │   │   ├── IComplexUpgrader.sol
│   │   │   │   ├── IL2GatewayUpgrade.sol
│   │   │   │   ├── IL2GenesisUpgrade.sol
│   │   │   │   └── ISystemContext.sol
│   │   │   └── libraries
│   │   │       ├── BatchDecoder.sol
│   │   │       ├── Diamond.sol
│   │   │       ├── LibMap.sol
│   │   │       ├── PriorityQueue.sol
│   │   │       ├── PriorityTree.sol
│   │   │       └── TransactionValidator.sol
│   │   ├── transactionFilterer
│   │   │   └── GatewayTransactionFilterer.sol
│   │   ├── upgrades
│   │   │   ├── BaseZkSyncUpgrade.sol
│   │   │   ├── BaseZkSyncUpgradeGenesis.sol
│   │   │   ├── BytecodesSupplier.sol
│   │   │   ├── DefaultUpgrade.sol
│   │   │   ├── GatewayUpgrade.sol
│   │   │   ├── GovernanceUpgradeTimer.sol
│   │   │   ├── IDefaultUpgrade.sol
│   │   │   ├── IGatewayUpgrade.sol
│   │   │   ├── IL1GenesisUpgrade.sol
│   │   │   ├── L1GatewayHelper.sol
│   │   │   ├── L1GenesisUpgrade.sol
│   │   │   └── ZkSyncUpgradeErrors.sol
│   │   └── vendor
│   │       └── AddressAliasHelper.sol
├── l2-contracts
│   ├── contracts
|   |   ├── ConsensusRegistry.sol
|   |   ├── Dependencies.sol
|   |   ├── ForceDeployUpgrader.sol
|   |   ├── L2ContractHelper.sol
|   |   ├── SystemContractsCaller.sol
│   │   ├── data-availability
│   │   │   ├── DAErrors.sol
│   │   │   ├── RollupL2DAValidator.sol
│   │   │   ├── StateDiffL2DAValidator.sol
│   │   │   └── ValidiumL2DAValidator.sol
│   │   ├── errors
│   │   │   └── L2ContractErrors.sol
│   │   ├── interfaces
│   │   │   ├── IConsensusRegistry.sol
│   │   │   ├── IL2DAValidator.sol
│   │   │   ├── IPaymaster.sol
│   │   │   └── IPaymasterFlow.sol
│   │   ├── vendor
│   │   │   └── AddressAliasHelper.sol
│   │   └── verifier
│   │       ├── Verifier.sol
│   │       └── chain-interfaces
│   │           └── IVerifier.sol
├── system-contracts
│   ├── bootloader
│   │   ├── bootloader.yul
│   ├── contracts
|   |   ├── AccountCodeStorage.sol
|   |   ├── BootloaderUtilities.sol
|   |   ├── ComplexUpgrader.sol
|   |   ├── Compressor.sol
|   |   ├── Constants.sol
|   |   ├── ContractDeployer.sol
|   |   ├── Create2Factory.sol
|   |   ├── DefaultAccount.sol
|   |   ├── EmptyContract.sol
|   |   ├── EventWriter.yul
|   |   ├── ImmutableSimulator.sol
|   |   ├── KnownCodesStorage.sol
|   |   ├── L1Messenger.sol
|   |   ├── L2BaseToken.sol
|   |   ├── L2GatewayUpgrade.sol
|   |   ├── L2GatewayUpgradeHelper.sol
|   |   ├── L2GenesisUpgrade.sol
|   |   ├── MsgValueSimulator.sol
|   |   ├── NonceHolder.sol
|   |   ├── PubdataChunkPublisher.sol
|   |   ├── SloadContract.sol
|   |   ├── SystemContext.sol
|   |   ├── SystemContractErrors.sol
|   |   ├── abstract
|   |   │   └── SystemContractBase.sol
|   |   ├── interfaces
|   |   │   ├── IAccount.sol
|   |   │   ├── IAccountCodeStorage.sol
|   |   │   ├── IBaseToken.sol
|   |   │   ├── IBootloaderUtilities.sol
|   |   │   ├── IBridgehub.sol
|   |   │   ├── IComplexUpgrader.sol
|   |   │   ├── ICompressor.sol
|   |   │   ├── IContractDeployer.sol
|   |   │   ├── ICreate2Factory.sol
|   |   │   ├── IImmutableSimulator.sol
|   |   │   ├── IKnownCodesStorage.sol
|   |   │   ├── IL1Messenger.sol
|   |   │   ├── IL2DAValidator.sol
|   |   │   ├── IL2GenesisUpgrade.sol
|   |   │   ├── IL2SharedBridgeLegacy.sol
|   |   │   ├── IL2StandardToken.sol
|   |   │   ├── IL2WrappedBaseToken.sol
|   |   │   ├── IMailbox.sol
|   |   │   ├── IMessageRoot.sol
|   |   │   ├── INonceHolder.sol
|   |   │   ├── IPaymaster.sol
|   |   │   ├── IPaymasterFlow.sol
|   |   │   ├── IPubdataChunkPublisher.sol
|   |   │   ├── ISystemContext.sol
|   |   │   └── ISystemContextDeprecated.sol
|   |   ├── libraries
|   |   │   ├── EfficientCall.sol
|   |   │   ├── RLPEncoder.sol
|   |   │   ├── SystemContractHelper.sol
|   |   │   ├── SystemContractsCaller.sol
|   |   │   ├── TransactionHelper.sol
|   |   │   ├── UnsafeBytesCalldata.sol
|   |   │   └── Utils.sol
|   |   ├── precompiles
|   |   │   ├── CodeOracle.yul
|   |   │   ├── EcAdd.yul
|   |   │   ├── EcMul.yul
|   |   │   ├── EcPairing.yul
|   |   │   ├── Ecrecover.yul
|   |   │   ├── Keccak256.yul
|   |   │   ├── P256Verify.yul
|   |   │   └── SHA256.yul
```
### zk-governance

```js
l1-contracts
├── src
|   ├── EmergencyUpgradeBoard.sol
|   ├── Guardians.sol
|   ├── Multisig.sol
|   ├── ProtocolUpgradeHandler.sol
|   ├── SecurityCouncil.sol
|   ├── TestnetProtocolUpgradeHandler.sol
│   └── interfaces
│       ├── IGuardians.sol
│       ├── IL2Governor.sol
│       ├── IPausable.sol
│       ├── IProtocolUpgradeHandler.sol
│       ├── ISecurityCouncil.sol
│       ├── IStateTransitionManager.sol
│       └── IZKsyncEra.sol

l2-contracts
├── src
|   ├── Counter.sol
|   ├── ZkCappedMinter.sol
|   ├── ZkGovOpsGovernor.sol
|   ├── ZkMerkleDistributor.sol
|   ├── ZkProtocolGovernor.sol
|   ├── ZkTokenGovernor.sol
|   ├── ZkTokenV1.sol
|   ├── ZkTokenV2.sol
|   ├── extensions
|   │   ├── GovernorGuardianVeto.sol
|   │   └── GovernorSettableFixedQuorum.sol
|   ├── interfaces
|   │   ├── IMintable.sol
|   │   └── IMintableAndDelegatable.sol
|   └── lib
|       ├── GovernorCountingFractional.sol
|       └── Nonces.sol

```

[//]: # (scope-close)
[//]: # (getting-started-open)

## Setup

Clone the contest repo:

```bash
git clone https://github.com/Cyfrin/2024-10-zksync.git
```

1. `era-contracts/l1-contracts`

Build:

```bash
yarn && yarn build
```

Tests:

```bash
yarn test:foundry
```

2. `era-contracts/l2-contracts`

Build:

```bash
yarn && yarn build
```

Tests:

```bash
yarn test
```

3. `era-contracts/system-contracts`

Build:

```bash
yarn && yarn build
```

Tests:

```bash
# In the first terminal
yarn test-node
```

```bash
# In the second terminal
yarn test
```

4. `era-contracts/da-contracts`

Build:

```bash
yarn && yarn build
```

5. `zk-governance/l1-contracts`

Build:

```bash
forge build
```

Tests:

```bash
forge test
```

6. `zk-governance/l2-contracts`

Build:

```bash
forge build
```

Tests:

```bash
forge test
```

[//]: # (getting-started-close)
[//]: # (known-issues-open)

Everything found during previous audits & contests:
- https://docs.zksync.io/build/resources/audit-bug-bounty
- https://code4rena.com/reports/2023-03-zksync
- https://code4rena.com/reports/2023-10-zksync
- https://code4rena.com/reports/2024-03-zksync

1. Contracts  on  L1  cannot  access  their  native  balance  on  their  aliased  L2 
address

It is currently not possible for an L1 smart contract to access and transfer the 
native tokens on their aliased L2 address. 

2. Gas  spent  on  pubdata  is  not  subtracted  in  between  near  calls,  leading  to 
uncompensated operator calculations and potential DOS.

The  bootloader executes  transactions  with the amount  of  gas  that  has  been  requested  and 
paid for by the transactions. Pubdata cost is charged separately from execution cost and must 
be taken into account by calculating the difference of the pubdata counter after and before 
the  transaction  execution  and  multiplying  the  result  by  `gasPerPubdata`.  A  transaction  is 
executed over multiple near calls, and so each near call checks if the remaining gas is sufficient 
to pay for the overall pubdata that the transaction has consumed up to this point. By reverting the near call 
it is ensured that the overspent gas does not cause any 
state changes, the operator is forced to perform computations without receiving 
compensation  for  it.

3. Validator can provide inefficient bytecode compression

In the current implementation, the mechanism for bytecode compression is not strictly unambiguous. That means the validator has the flexibility to choose a less efficient compression for the bytecode to increase the deployment cost for the end user. Besides that, there is another non-fixed [issue](https://github.com/code-423n4/2023-10-zksync-findings/issues/805), that gives a way for the operator to forces the user to pay more for the bytecode compression or even burn all the transaction gas during bytecode compression verification.

4. extcodehash does not distinguish empty contracts on account balances

According to the [EIP-161](https://eips.ethereum.org/EIPS/eip-161), an account is “empty” when it meets the following conditions: it has no deployed code, its nonce value is zero, and it holds a balance of zero. According to [EIP-1052](https://eips.ethereum.org/EIPS/eip-1052), the extcodehash of an empty account should evaluate to `bytes32(0)`, otherwice it is `keccak256(deployedBytecode)`. On ZKsync, bytes32(0) is returned in case there is no deployed code and nonce is zero regardless of the account balance.

5. DefaultAccount does not always return successfully

DefaultAccount, while it should always behave as an EOA (i.e. any call to it should return success(0,0)), if called with a selector of one of its methods and incorrect ABI-encoding of its parameters, will fail with empty error. This happens due to the fact that the ABI decoding fails before the modifier is triggered.

[//]: # (known-issues-close)