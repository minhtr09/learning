// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperUtils} from "./utils/HelperUtils.s.sol"; // Utility functions for JSON parsing and chain info
import {HelperConfig} from "./HelperConfig.s.sol"; // Network configuration helper
import {BurnMintTokensPool} from "../src/BurnMintTokensPool.sol";
import {BurnMintERC677} from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
import {IBurnMintERC20} from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC20/IBurnMintERC20.sol";
import {AbstractCCIPSendToken} from "../src/AbstractCCIPSendToken.sol";
import {TokenAdminRegistry} from "@chainlink/contracts-ccip/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {TransferTokens} from "./TransferTokens.s.sol";
import {ConcentratedTokensPool} from "../src/ConcentratedTokensPool.sol";
import {RateLimiter} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/RateLimiter.sol";

contract DeployBurnMintTokensPoolAndSetPool is Script {
    function run() external {
        // Get the chain name based on the current chain ID
        string memory chainName = HelperUtils.getChainName(block.chainid);
        console.log("Chain name:", chainName);
        // Construct the path to the deployed token JSON file
        string memory root = vm.projectRoot();
        string memory deployedTokenPath = string.concat(root, "/script/output/deployedToken_", chainName, ".json");

        // Extract the deployed token address from the JSON file
        address tokenAddress =
            HelperUtils.getAddressFromJson(vm, deployedTokenPath, string.concat(".deployedToken_", chainName));

        // Fetch network configuration (router and RMN proxy addresses)
        HelperConfig helperConfig = new HelperConfig();
        (, address router, address rmnProxy, address tokenAdminRegistry,,,,) = helperConfig.activeNetworkConfig();

        // Ensure that the token address, router, and RMN proxy are valid
        require(tokenAddress != address(0), "Invalid token address");
        require(router != address(0) && rmnProxy != address(0), "Router or RMN Proxy not defined for this network");

        address[] memory tokens = new address[](1);
        tokens[0] = tokenAddress;

        // ================================================================
        // │                       Deploy Pool                         │
        // ================================================================

        vm.startBroadcast();

        // Deploy the BurnMintConcentratedTokensPool contract associated with the token
        BurnMintTokensPool tokenPool = new BurnMintTokensPool(
            tokens,
            new address[](0), // Empty array for initial operators
            rmnProxy,
            router
        );

        console.log("Burn & Mint token pool deployed to:", address(tokenPool));

        // Grant mint and burn roles to the token pool on the token contract
        BurnMintERC677(tokenAddress).grantMintAndBurnRoles(address(tokenPool));
        console.log("Granted mint and burn roles to token pool:", address(tokenPool));

        vm.stopBroadcast();
        // Serialize and write the token pool address to a new JSON file
        string memory jsonObj = "internal_key";
        string memory key = string(abi.encodePacked("deployedTokensPool_", chainName));
        string memory finalJson = vm.serializeAddress(jsonObj, key, address(tokenPool));

        string memory poolFileName = string(abi.encodePacked("./script/output/deployedTokensPool_", chainName, ".json"));
        console.log("Writing deployed token pool address to file:", poolFileName);
        vm.writeJson(finalJson, poolFileName);

        // ================================================================
        // │                       Set Pool                            │
        // ================================================================
        // string memory deployedPoolPath = string.concat(root, "/script/output/deployedTokensPool_", chainName, ".json");
        // address tokenPool =
        //     HelperUtils.getAddressFromJson(vm, deployedPoolPath, string.concat(".deployedTokensPool_", chainName));
        // require(tokenAddress != address(0), "Invalid token address");
        // require(address(tokenPool) != address(0), "Invalid pool address");
        // require(tokenAdminRegistry != address(0), "TokenAdminRegistry is not defined for this network");

        // vm.startBroadcast();

        // // Instantiate the TokenAdminRegistry contract
        // TokenAdminRegistry tokenAdminRegistryContract = TokenAdminRegistry(tokenAdminRegistry);
        // address tokenAdministratorAddress;
        // {
        //     // Fetch the token configuration to get the administrator's address
        //     TokenAdminRegistry.TokenConfig memory config = tokenAdminRegistryContract.getTokenConfig(tokenAddress);
        //     tokenAdministratorAddress = config.administrator;
        // }

        // console.log("Setting pool for token:", tokenAddress);
        // console.log("New pool address:", address(tokenPool));
        // console.log("Action performed by admin:", tokenAdministratorAddress);

        // // Use the administrator's address to set the pool for the token
        // tokenAdminRegistryContract.setPool(tokenAddress, address(tokenPool));
        // console.log("Pool set for token", tokenAddress, "to", address(tokenPool));
        // vm.stopBroadcast();

        // Update chain
        // new ApplyChainUpdates().run(tokenAddress);
        // Try to transfer token
        // new TransferTokens().run();
    }
}

contract ApplyChainUpdates is Script {
    function run(address tokenAddress) external {
        // Get the current chain name based on the chain ID
        string memory chainName = HelperUtils.getChainName(block.chainid);

        // Construct paths to the configuration and local pool JSON files
        string memory root = vm.projectRoot();
        // string memory configPath = string.concat(root, "/script/config.json");
        string memory localPoolPath = string.concat(root, "/script/output/deployedTokensPool_", chainName, ".json");

        // Read the remoteChainId from config.json based on the current chain ID
        uint256 remoteChainId = HelperUtils.getUintFromJson(
            vm,
            string.concat(root, "/script/config.json"),
            string.concat(".remoteChains.", HelperUtils.uintToStr(block.chainid))
        );

        // Get the remote chain name based on the remoteChainId
        string memory remoteChainName = HelperUtils.getChainName(remoteChainId);
        string memory remotePoolPath =
            string.concat(root, "/script/output/deployedTokensPool_", remoteChainName, ".json");
        string memory remoteTokenPath = string.concat(root, "/script/output/deployedToken_", remoteChainName, ".json");

        // Extract addresses from the JSON files
        address poolAddress =
            HelperUtils.getAddressFromJson(vm, localPoolPath, string.concat(".deployedTokensPool_", chainName));
        address remotePoolAddress =
            HelperUtils.getAddressFromJson(vm, remotePoolPath, string.concat(".deployedTokensPool_", remoteChainName));
        address remoteTokenAddress =
            HelperUtils.getAddressFromJson(vm, remoteTokenPath, string.concat(".deployedToken_", remoteChainName));

        // Fetch the remote network configuration to get the chain selector
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory remoteNetworkConfig =
            HelperUtils.getNetworkConfig(helperConfig, remoteChainId);

        {
            require(poolAddress != address(0), "Invalid pool address");
            require(remotePoolAddress != address(0), "Invalid remote pool address");
            require(remoteTokenAddress != address(0), "Invalid remote token address");
        }

        vm.startBroadcast();
        // Prepare chain update data for configuring cross-chain transfers
        ConcentratedTokensPool.ChainUpdate[] memory chainUpdates = new ConcentratedTokensPool.ChainUpdate[](1);
        bytes[] memory remoteTokenAddresses = new bytes[](1);
        address[] memory tokens = new address[](1);
        {
            remoteTokenAddresses[0] = abi.encode(remoteTokenAddress);
            tokens[0] = tokenAddress;
            chainUpdates[0] = ConcentratedTokensPool.ChainUpdate({
                remoteChainSelector: remoteNetworkConfig.chainSelector, // Chain selector of the remote chain
                allowed: true, // Enable transfers to the remote chain
                remotePoolAddress: abi.encode(remotePoolAddress), // Encoded address of the remote pool
                remoteTokenAddresses: remoteTokenAddresses, // Encoded address of the remote token
                tokens: tokens, // Address of the token will be mapped to the remote token address.
                outboundRateLimiterConfig: RateLimiter.Config({
                    isEnabled: true, // Set to true to enable outbound rate limiting
                    capacity: 10000 ether, // Max tokens allowed in the outbound rate limiter
                    rate: 10 ether // Refill rate per second for the outbound rate limiter
                }),
                inboundRateLimiterConfig: RateLimiter.Config({
                    isEnabled: true, // Set to true to enable inbound rate limiting
                    capacity: 10000 ether, // Max tokens allowed in the inbound rate limiter
                    rate: 10 ether // Refill rate per second for the inbound rate limiter
                })
            });
        }

        // Instantiate the local TokenPool contract
        ConcentratedTokensPool poolContract = ConcentratedTokensPool(poolAddress);
        // Apply the chain updates to configure the pool
        poolContract.applyChainUpdates(chainUpdates);

        console.log("Chain update applied to pool at address:", poolAddress);

        vm.stopBroadcast();
    }
}
