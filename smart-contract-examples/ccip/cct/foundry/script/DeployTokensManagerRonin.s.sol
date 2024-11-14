pragma solidity ^0.8.23;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {TokensManager} from "../src/ronin/TokensManager.sol";
import {BurnMintTokensPool, ConcentratedTokensPool} from "../src/BurnMintTokensPool.sol";
contract DeployTokensManager is Script {
    TokensManager internal _tokensManager;
    address internal _roninRouter = 0x0aCAe4e51D3DA12Dd3F45A66e8b660f740e6b820;
    address internal _sepoliaRouter =
        0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address internal _deployer = 0x62aE17Ea20Ac44915B57Fa645Ce8c0f31cBD873f;

    function run() public {
        vm.startBroadcast(_deployer);
        console.log("Deployer nonce", vm.getNonce(_deployer));
        if (block.chainid == 11155111) {
            _tokensManager = new TokensManager(_sepoliaRouter);
        } else {
            _tokensManager = new TokensManager(_roninRouter);
        }
        console.log("Tokens manager address", address(_tokensManager));
    }
}
