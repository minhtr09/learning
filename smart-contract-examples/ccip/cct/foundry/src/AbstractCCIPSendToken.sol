// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from
    "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from
    "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {HelperUtils} from "../script/utils/HelperUtils.s.sol";

contract AbstractCCIPSendToken is OwnerIsCreator {
    using SafeERC20 for IERC20;

    address internal immutable i_ccipRouter;
    address internal _token;
    uint64 internal _destinationChainSelector;

    event TokenSent(address indexed receiver, uint256 amount, string explorerUrl);

    constructor(address router, address token, uint64 destinationChainSelector) {
        _token = token;
        i_ccipRouter = router;
        _destinationChainSelector = destinationChainSelector;
        IERC20(token).approve(router, type(uint256).max);
    }

    function sendTokenPayNative(address receiver) external payable returns (string memory explorerUrl) {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(receiver, 0.1 ether, address(0));
        uint256 fees = IRouterClient(i_ccipRouter).getFee(_destinationChainSelector, evm2AnyMessage);

        // Send the CCIP message
        bytes32 messageId = IRouterClient(i_ccipRouter).ccipSend{value: fees}(_destinationChainSelector, evm2AnyMessage);
        explorerUrl = string(
            abi.encodePacked(
                "Check status of the message at https://ccip.chain.link/msg/", bytes32ToHexString(messageId)
            )
        );
        emit TokenSent(receiver, 0.1 ether, explorerUrl);
    }

    function _buildCCIPMessage(address receiver, uint256 amount, address feeTokenAddress)
        private
        view
        returns (Client.EVM2AnyMessage memory)
    {
        // Set the token amounts
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: _token, amount: amount});
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: "", // ABI-encoded string
            tokenAmounts: tokenAmounts, // The amount and type of token being transferred
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit
                Client.EVMExtraArgsV2({
                    gasLimit: 200_000, // Gas limit for the callback on the destination chain
                    allowOutOfOrderExecution: true // Allows the message to be executed out of order relative to other messages from the same sender
                })
            ),
            // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
            feeToken: feeTokenAddress
        });
    }

    function bytes32ToHexString(bytes32 _bytes) internal pure returns (string memory) {
        bytes memory hexString = new bytes(64);
        bytes memory hexAlphabet = "0123456789abcdef";
        for (uint256 i = 0; i < 32; i++) {
            hexString[i * 2] = hexAlphabet[uint8(_bytes[i] >> 4)];
            hexString[i * 2 + 1] = hexAlphabet[uint8(_bytes[i] & 0x0f)];
        }
        return string(hexString);
    }

    function withdrawNative() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to send Ron");
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setDestinationChainSelector(uint64 destinationChainSelector) external onlyOwner {
        _destinationChainSelector = destinationChainSelector;
    }
}
