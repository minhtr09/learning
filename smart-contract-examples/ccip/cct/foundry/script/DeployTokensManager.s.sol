// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import {Script, console} from "forge-std/Script.sol";
// import {HelperUtils} from "./utils/HelperUtils.s.sol"; // Utility functions for JSON parsing and chain info
// import {HelperConfig} from "./HelperConfig.s.sol"; // Network configuration helper
// import {BurnMintERC677WithCCIPAdmin} from "../src/BurnMintERC677WithCCIPAdmin.sol";
// import {BurnMintERC677} from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
// import {TokensManager} from "../src/ronin/TokensManager.sol";
// import {BurnMintTokensPool} from "../src/BurnMintTokensPool.sol";
// import {DeployBurnMintTokensPoolAndSetPool, ApplyChainUpdates} from "./DeployBurnMintTokensPoolAndSetPool.s.sol";
// import {TransferTokens} from "./TransferTokens.s.sol";
// import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

// contract DeployTokensManager is Script {
//     function run() external {
//         new DeployBurnMintTokensPoolAndSetPool().run();
//         // Get the chain name based on the current chain ID
//         string memory chainName = HelperUtils.getChainName(block.chainid);

//         // Define the path to the config.json file
//         string memory root = vm.projectRoot();
//         string memory configPath = string.concat(root, "/script/config.json");

//         // Extract token parameters from the config.json file
//         string memory name = HelperUtils.getStringFromJson(vm, configPath, ".BnMToken.name");
//         string memory symbol = HelperUtils.getStringFromJson(vm, configPath, ".BnMToken.symbol");
//         uint8 decimals = uint8(HelperUtils.getUintFromJson(vm, configPath, ".BnMToken.decimals"));
//         uint256 initialSupply = HelperUtils.getUintFromJson(vm, configPath, ".BnMToken.initialSupply");
//         TokensManager tokensManager;
//         address newToken;
//         vm.startBroadcast();
//         {
//             string memory deployedTokenPath =
//                 string.concat(root, "/script/output/deployedTokensPool_", chainName, ".json");

//             // Extract the deployed token address from the JSON file
//             address concentratedPool =
//                 HelperUtils.getAddressFromJson(vm, deployedTokenPath, string.concat(".deployedTokensPool_", chainName));

//             // Fetch the network configuration to get the TokenAdminRegistry address
//             HelperConfig helperConfig = new HelperConfig();
//             (,,, address tokenAdminRegistry, address registryModuleOwnerCustom,,,) = helperConfig.activeNetworkConfig();

//             tokensManager =
//                 new TokensManager(msg.sender, tokenAdminRegistry, concentratedPool, registryModuleOwnerCustom);
//             BurnMintTokensPool(concentratedPool).setTokensManager(address(tokensManager));
//             newToken = tokensManager.createNewTokenERC667(name, symbol, decimals, initialSupply, 100000000 ether);
//         }
//         vm.stopBroadcast();
//         new ApplyChainUpdates().run(newToken);

//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(msg.sender), // Receiver address on the destination chain
//             data: abi.encode(), // No additional data
//             tokenAmounts: new Client.EVMTokenAmount[](1), // Array of tokens to transfer
//             feeToken: address(0), // Fee token (native or LINK)
//             extraArgs: abi.encodePacked(
//                 bytes4(keccak256("CCIP EVMExtraArgsV1")), // Extra arguments for CCIP (versioned)
//                 abi.encode(uint256(0)) // Placeholder for future use
//             )
//         });
//         message.tokenAmounts[i] = Client.EVMTokenAmount({token: newToken, amount: 0.1 ether});

//         // Prepare to write the deployed token address to a JSON file
//         string memory jsonObj = "internal_key";
//         string memory key = string(abi.encodePacked("deployedTokensManager_", chainName));
//         string memory finalJson = vm.serializeAddress(jsonObj, key, address(tokensManager));

//         // Define the output file path for the deployed token address
//         string memory fileName = string(abi.encodePacked("./script/output/deployedTokensManager_", chainName, ".json"));
//         console.log("Writing deployed tokens manager address to file:", fileName);

//         // Write the JSON file containing the deployed token address
//         vm.writeJson(finalJson, fileName);

//         address router = BurnMintTokensPool(concentratedPool).getRouter();
//         // Approve the router to transfer tokens on behalf of the sender
//         IERC20(newToken).approve(router, type(uint256).max);

//         // Estimate the fees required for the transfer
//         uint256 fees = router.getFee(destinationChainSelector, message);
//         console.log("Estimated fees:", fees);

//         // Send the CCIP message and handle fee payment
//         bytes32 messageId;
//         messageId = routerContract.ccipSend{value: fees}(destinationChainSelector, message);

//         // Log the Message ID
//         console.log("Message ID:");
//         console.logBytes32(messageId);

//         // Provide a URL to check the status of the message
//         string memory messageUrl = string(
//             abi.encodePacked(
//                 "Check status of the message at https://ccip.chain.link/msg/", HelperUtils.bytes32ToHexString(messageId)
//             )
//         );
//         console.log(messageUrl);
//     }
// }
