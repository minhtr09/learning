// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import { AccessControlEnumerable } from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import { TokenAdminRegistry } from "@chainlink/contracts-ccip/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IOwner } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IOwner.sol";
import { IGetCCIPAdmin } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IGetCCIPAdmin.sol";
import { RegistryModuleOwnerCustom } from "@chainlink/contracts-ccip/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import { BurnMintERC677 } from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
import { CCIPReceiver, Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract TokensManager is AccessControlEnumerable, CCIPReceiver, Initializable {
  using EnumerableSet for EnumerableSet.AddressSet;

  event TokenRemoved(address indexed token);
  event TokenRegistered(address indexed token, bool viaCCIPAdmin);
  event PoolSet(address indexed token, address indexed pool);
  event TokenAdminRegistrySet(address indexed tokenAdminRegistry);
  event RegistryModuleOwnerCustomSet(address indexed registryModuleOwnerCustom);
  event TokenCreatedOnSourceChain(address indexed token, address indexed deployer, uint256 initialSupply, bytes32 messageId);
  event TokenCreatedOnDestinationChain(address indexed token, address indexed deployer, uint256 initialSupply);
  event RemoteTokensManagerSet(address indexed remoteTokensManager);

  error UnauthorizedToken(address token);
  error UnauthorizedRemoteTokensManager(address remoteTokensManager);
  error UnauthorizedTokenDeployer(address token);

  EnumerableSet.AddressSet internal _tokens;
  mapping(address deployedToken => address deployer) internal _tokenDeployers;
  mapping(address deployer => uint256 nonce) internal _deployerNonces;
  address internal _concentratedPool;
  address internal _remoteTokensManager;

  TokenAdminRegistry internal _tokenAdminRegistry;
  RegistryModuleOwnerCustom internal _registryModuleOwnerCustom;

  uint64 internal _destinationChainSelector;

  receive() external payable { }
  fallback() external payable { }

  modifier onlyManagedToken(
    address token
  ) {
    if (!_tokens.contains(token)) {
      revert UnauthorizedToken(token);
    }
    _;
  }

  modifier onlyTokenDeployer(
    address token
  ) {
    if (_tokenDeployers[token] != msg.sender) {
      revert UnauthorizedTokenDeployer(token);
    }
    _;
  }

  modifier onlyRemoteTokensManager(
    address sender
  ) {
    if (sender != _remoteTokensManager) {
      revert UnauthorizedRemoteTokensManager(sender);
    }
    _;
  }

  constructor(
    address ccipRouter
  ) CCIPReceiver(ccipRouter) {
    // _disableInitializers();
  }

  function initialize(address admin, address tokenAdminRegistry, address concentratedPool, address registryModuleOwnerCustom) external initializer {
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _setTokenAdminRegistry(tokenAdminRegistry);
    _setConcentratedPool(concentratedPool);
    _setRegistryModuleOwnerCustom(registryModuleOwnerCustom);
  }

  function createTokenUnderManagement(
    string memory name,
    string memory symbol,
    uint8 decimals,
    uint256 initialSupply,
    uint256 mintAmount
  ) external returns (address tokenAddress) {
    bytes32 salt = keccak256(abi.encodePacked(name, symbol, decimals, initialSupply, _deployerNonces[msg.sender]));
    _deployerNonces[msg.sender]++;
    BurnMintERC677 token = new BurnMintERC677{ salt: salt }(name, symbol, decimals, initialSupply);
    _tokenDeployers[address(token)] = msg.sender;
    _mintTokenForDeployer(token, mintAmount);
    token.grantMintAndBurnRoles(_concentratedPool);
    _tokens.add(address(token));
    // Register the token
    _registryToken(address(token), true);
    _setPoolForToken(address(token));
    // Transfer ownership back to the deployer.
    token.transferOwnership(msg.sender);
    tokenAddress = address(token);

    // Create a CCIP message to create the token on the destination chain
    Client.EVM2AnyMessage memory message = _buildCCIPMessage(name, symbol, decimals, initialSupply, mintAmount);
    uint256 fees = IRouterClient(i_ccipRouter).getFee(_destinationChainSelector, message);

    // Send the CCIP message
    bytes32 messageId = IRouterClient(i_ccipRouter).ccipSend{ value: fees }(_destinationChainSelector, message);
    emit TokenCreatedOnSourceChain(tokenAddress, msg.sender, initialSupply, messageId);
  }

  function setTokenAdminRegistry(
    address tokenAdminRegistry
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _setTokenAdminRegistry(tokenAdminRegistry);
  }

  function setRemoteTokensManager(
    address remoteTokensManager
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _setRemoteTokensManager(remoteTokensManager);
  }

  function setConcentratedPool(
    address concentratedPool
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _setConcentratedPool(concentratedPool);
  }

  function registerToken(address token, bool viaCCIPAdmin) external onlyManagedToken(token) onlyRole(DEFAULT_ADMIN_ROLE) {
    _registryToken(token, viaCCIPAdmin);
    _setPoolForToken(token);
  }

  function _registryToken(address token, bool viaCCIPAdmin) internal {
    _registryModuleOwnerCustom.registerAdminViaOwner(token);
    _tokenAdminRegistry.acceptAdminRole(token);

    emit TokenRegistered(token, viaCCIPAdmin);
  }

  function setDestinationChainSelector(
    uint64 destinationChainSelector
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _destinationChainSelector = destinationChainSelector;
  }

  function _setPoolForToken(
    address token
  ) internal {
    _tokenAdminRegistry.setPool(token, _concentratedPool);
    emit PoolSet(token, _concentratedPool);
  }

  function _setRemoteTokensManager(
    address remoteTokensManager
  ) internal {
    _remoteTokensManager = remoteTokensManager;
    emit RemoteTokensManagerSet(remoteTokensManager);
  }

  function _setTokenAdminRegistry(
    address tokenAdminRegistry
  ) internal {
    _tokenAdminRegistry = TokenAdminRegistry(tokenAdminRegistry);
    emit TokenAdminRegistrySet(tokenAdminRegistry);
  }

  function _setRegistryModuleOwnerCustom(
    address registryModuleOwnerCustom
  ) internal {
    _registryModuleOwnerCustom = RegistryModuleOwnerCustom(registryModuleOwnerCustom);
    emit RegistryModuleOwnerCustomSet(registryModuleOwnerCustom);
  }

  function _setConcentratedPool(
    address concentratedPool
  ) internal {
    _concentratedPool = concentratedPool;
  }

  function _mintTokenForDeployer(BurnMintERC677 token, uint256 amount) internal {
    token.grantMintRole(address(this));
    BurnMintERC677(token).mint(msg.sender, amount);
    token.revokeMintRole(address(this));
  }

  function _buildCCIPMessage(
    string memory name,
    string memory symbol,
    uint8 decimals,
    uint256 initialSupply,
    uint256 mintAmount
  ) internal view returns (Client.EVM2AnyMessage memory message) {
    // Create a CCIP message to create the token on the destination chain
    message = Client.EVM2AnyMessage({
      receiver: abi.encode(_remoteTokensManager), // ABI-encoded receiver address
      data: abi.encode(msg.sender, name, symbol, decimals, initialSupply, mintAmount), // ABI-encoded string
      tokenAmounts: new Client.EVMTokenAmount[](0), // No tokens to transfer
      extraArgs: Client._argsToBytes(
        // Additional arguments, setting gas limit
        Client.EVMExtraArgsV2({
          gasLimit: 2_000_000, // Gas limit for the callback on the destination chain
          allowOutOfOrderExecution: true // Allows the message to be executed out of order relative to other messages from the same sender
         })
      ),
      // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
      feeToken: address(0)
    });
  }

  function _ccipReceive(
    Client.Any2EVMMessage memory message
  ) internal override onlyRemoteTokensManager(abi.decode(message.sender, (address))) {
    (address deployer, string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, uint256 mintAmount) =
      abi.decode(message.data, (address, string, string, uint8, uint256, uint256));
    bytes32 salt = keccak256(abi.encodePacked(name, symbol, decimals, initialSupply, _deployerNonces[deployer]));
    BurnMintERC677 token = new BurnMintERC677{ salt: salt }(name, symbol, decimals, initialSupply);
    _deployerNonces[deployer]++;
    _tokenDeployers[address(token)] = deployer;
    _mintTokenForDeployer(token, mintAmount);
    token.grantMintAndBurnRoles(_concentratedPool);
    _tokens.add(address(token));
    // Register the token
    _registryToken(address(token), true);
    _setPoolForToken(address(token));
    // Transfer ownership back to the deployer.
    token.transferOwnership(deployer);
    emit TokenCreatedOnDestinationChain(address(token), deployer, initialSupply);
  }

  function removeToken(
    address token
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _tokens.remove(token);
    delete _tokenDeployers[token];
    emit TokenRemoved(token);
  }

  function getManagedTokens() external view returns (address[] memory) {
    return _tokens.values();
  }

  function isTokenUnderManagement(
    address token
  ) external view returns (bool) {
    return _tokens.contains(token);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(AccessControlEnumerable, CCIPReceiver) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}
