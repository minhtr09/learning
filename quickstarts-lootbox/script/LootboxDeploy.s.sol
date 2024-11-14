import "forge-std/Script.sol";
import {Lootbox} from "../contracts/Lootbox.sol";
import {ERC20Mock} from "../contracts/test/ERC20Mock.sol";
import {ERC721Mock} from "../contracts/test/ERC721Mock.sol";
import {ERC1155Mock} from "../contracts/test/ERC1155Mock.sol";

contract LootboxDeploy is Script {
    uint128 public constant LOOTBOX_FEE_PER_OPEN = 0.0001 ether;
    bytes32 public constant KEY_HASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    address public constant VRF_COORDINATOR_V2 = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    uint256 public constant VRF_SUBSCRIPTION_ID =
        uint256(25591577934265605984440271478594858503400843767204592300431683060650611672909);

    ERC20Mock internal _erc20Mock;
    ERC721Mock internal _erc721Mock;
    ERC1155Mock internal _erc1155Mock;

    Lootbox internal _lootbox;

    address internal _deployer = 0xEf46169CD1e954aB10D5e4C280737D9b92d0a936;

    function run() public {
        vm.startBroadcast(_deployer);
        // deploy completed
        // _deployTokens();
        // _deployLootbox();
        _claimRewards();
        vm.stopBroadcast();
        //post check
        // _postCheck();
    }

    function _deployTokens() private {
        _erc20Mock = new ERC20Mock();
        _erc721Mock = new ERC721Mock();
        _erc1155Mock = new ERC1155Mock();

        vm.label(address(_erc20Mock), "ERC20Mock");
        vm.label(address(_erc721Mock), "ERC721Mock");
        vm.label(address(_erc1155Mock), "ERC1155Mock");
    }

    function _deployLootbox() private {
        Lootbox.Token[] memory tokens = new Lootbox.Token[](3);
        tokens[0] = Lootbox.Token({
            assetContract: address(_erc20Mock),
            tokenType: Lootbox.TokenType.ERC20,
            tokenId: 0,
            totalAmount: 1000
        });
        tokens[1] = Lootbox.Token({
            assetContract: address(_erc721Mock),
            tokenType: Lootbox.TokenType.ERC721,
            tokenId: 0,
            totalAmount: 1
        });
        tokens[2] = Lootbox.Token({
            assetContract: address(_erc1155Mock),
            tokenType: Lootbox.TokenType.ERC1155,
            tokenId: 0,
            totalAmount: 10
        });

        uint256[] memory perUnitAmounts = new uint256[](3);
        perUnitAmounts[0] = 100;
        perUnitAmounts[1] = 1;
        perUnitAmounts[2] = 1;
        console.log("block number", block.number);

        uint64 amountDistributedPerOpen = 1;

        console.log("nonce pre approve", vm.getNonce(_deployer));
        // Calculate the preCreatedLootbox address
        uint256 nonce = vm.getNonce(_deployer);
        address preCreatedLootbox = computeCreateAddress(_deployer, nonce + 3);

        _erc20Mock.approve(preCreatedLootbox, type(uint256).max);
        _erc721Mock.setApprovalForAll(preCreatedLootbox, true);
        _erc1155Mock.setApprovalForAll(preCreatedLootbox, true);

        vm.label(preCreatedLootbox, "Lootbox Contract");
        vm.label(VRF_COORDINATOR_V2, "VRF Coordinator V2");

        console.log("nonce post approve", vm.getNonce(_deployer));

        _lootbox = new Lootbox({
            tokens: tokens,
            perUnitAmounts: perUnitAmounts,
            feePerOpen: LOOTBOX_FEE_PER_OPEN,
            amountDistributedPerOpen: amountDistributedPerOpen,
            openStartTimestamp: 0,
            whitelistRoot: bytes32(0),
            vrfKeyHash: KEY_HASH,
            vrfCoordinatorV2: VRF_COORDINATOR_V2,
            vrfSubscriptionId: VRF_SUBSCRIPTION_ID
        });

        vm.assertEq(address(_lootbox), preCreatedLootbox);

        _lootbox.s_vrfCoordinator().addConsumer(VRF_SUBSCRIPTION_ID, address(_lootbox));
        _lootbox.publicOpen{value: LOOTBOX_FEE_PER_OPEN * 2}(2);
    }

    function _postCheck() private {
        vm.assertEq(address(_lootbox.s_vrfCoordinator()), VRF_COORDINATOR_V2);
        (uint96 balance, uint96 nativeBalance, uint64 reqCount, address owner, address[] memory consumers) =
            _lootbox.s_vrfCoordinator().getSubscription(VRF_SUBSCRIPTION_ID);
        vm.assertEq(balance, 50 ether);
        vm.assertEq(nativeBalance, 1 ether);
        vm.assertEq(reqCount, 0);
        vm.assertEq(owner, address(_deployer));
        vm.assertEq(consumers.length, 1);
        vm.assertEq(consumers[0], address(_lootbox));
        vm.warp(block.timestamp + 10 minutes);
        // not fulfilled y
        vm.expectRevert(Lootbox.RandomnessNotFulfilled.selector);
        _lootbox.claimRewards(address(_deployer));

        // fulfilled
        _fulfill(_lootbox.getRequestIdOf(address(_deployer)));
        vm.prank(_deployer);
        _lootbox.claimRewards(address(_deployer));
    }

    function _fulfill(uint256 requestId) private {
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = 1;
        vm.prank(address(_lootbox.s_vrfCoordinator()));
        _lootbox.rawFulfillRandomWords(requestId, randomWords);
    }

    function _claimRewards() private {
        _lootbox = Lootbox(0x48e5b85cA25909bAbf76d4a501bce06dF2fa385f);
        _lootbox.claimRewards(address(_deployer));
        // _lootbox.publicOpen{value: LOOTBOX_FEE_PER_OPEN}(1);
    }
}
