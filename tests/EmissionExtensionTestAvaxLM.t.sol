// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import {Test} from 'forge-std/Test.sol';
// import {IERC20} from 'forge-std/interfaces/IERC20.sol';
// import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol'; // TODO: import Lido when lib is updated
// import {IAaveIncentivesController} from '../src/interfaces/IAaveIncentivesController.sol';
// import {IEmissionManager, ITransferStrategyBase, RewardsDataTypes, IEACAggregatorProxy} from '../src/interfaces/IEmissionManager.sol';
// import {BaseTest} from './utils/BaseTest.sol';
// import 'forge-std/console.sol';

// contract EmissionExtensionTestAvaxLMGHO is BaseTest {
//   // @dev Used to simplify the definition of a program of emissions
//   //  asset The asset on which to put reward on, usually Aave aTokens or vTokens (variable debt tokens)
//   //  emission Total emission of a `reward` token during the whole distribution duration defined
//   // E.g. With an emission of 10_000 MATICX tokens during 1 month, an emission of 50% for variableDebtPolWMATIC would be
//   // 10_000 * 1e18 * 50% / 30 days in seconds = 1_000 * 1e18 / 2_592_000 = ~ 0.0003858 * 1e18 MATICX per second

//   address constant wAVAX = AaveV3AvalancheAssets.WAVAX_UNDERLYING;
//   address constant wAVAX_ORACLE = AaveV3AvalancheAssets.WAVAX_ORACLE;
//   address constant sAVAX_ORACLE = AaveV3AvalancheAssets.sAVAX_ORACLE;
//   address constant sAVAX = AaveV3AvalancheAssets.sAVAX_UNDERLYING;
//   address constant WAVAX_V_TOKEN = AaveV3AvalancheAssets.WAVAX_V_TOKEN;
//   address constant BTCb_A_TOKEN = AaveV3AvalancheAssets.BTCb_A_TOKEN;
//   address constant USDC_A_TOKEN = AaveV3AvalancheAssets.USDC_A_TOKEN;
//   address constant USDC_V_TOKEN = AaveV3AvalancheAssets.USDC_V_TOKEN;
//   address constant sAVAX_A_TOKEN = AaveV3AvalancheAssets.sAVAX_A_TOKEN;
//   address constant USDt_A_TOKEN = AaveV3AvalancheAssets.USDt_A_TOKEN;



//   struct NewEmissionPerAsset {
//     address asset;
//     address[] rewards;
//     uint88[] newEmissionsPerSecond;
//   }

//   struct NewDistributionEndPerAsset {
//     address asset;
//     address reward;
//     uint32 newDistributionEnd;
//   }

//   address constant EMISSION_ADMIN = 0xac140648435d03f784879cd789130F22Ef588Fcd; // ACI
//   address constant REWARD_ASSET = sAVAX;

//   uint256 constant NEW_TOTAL_DISTRIBUTION = 11_130 ether;
//   uint88 constant NEW_DURATION_DISTRIBUTION_END = 15 days;

//   IEACAggregatorProxy constant REWARD_ORACLE = IEACAggregatorProxy(sAVAX_ORACLE);


//   uint256 constant TOTAL_DISTRIBUTION = 11_130 ether; // 80 awETH/14 Days
//   uint88 constant DURATION_DISTRIBUTION = 15 days;

//   address wAVAX_WHALE = 0x0dDBa20fa3B247fB3381cdE1a1FAe35C032e33fC;
//   address WAVAX_V_TOKEN_WHALE = 0xD48573cDA0fed7144f2455c5270FFa16Be389d04;
//   address BTCb_A_Token_WHALE = 0xD48573cDA0fed7144f2455c5270FFa16Be389d04;
//   address sAVAX_A_TOKEN_WHALE = 0x50e0cd4E3112410276dd88B918F31BeB1AAed302;
//   address USDt_A_TOKEN_WHALE = 0x43B87443CC4a6dd2a8b8801D26D1641Bb04060C8;
//   address USDC_A_TOKEN_WHALE = 0x407317167268c1f108a0d6c21F0c5F48aB9fd39a;
//   address USDC_V_TOKEN_WHALE = 0x407317167268c1f108a0d6c21F0c5F48aB9fd39a; 


//   function setUp() public {
//     vm.createSelectFork(vm.rpcUrl('Avalanche'), 247253747); // change this when ready
//   }

//   function test_setNewEmissionPerSecond() public {
//     NewEmissionPerAsset memory newEmissionPerAsset = _getNewEmissionPerSecond();

//     vm.startPrank(EMISSION_ADMIN);

//     // The emission admin can change the emission per second of the reward after the rewards have been configured.
//     // Here we change the initial emission per second to the new one.
//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setEmissionPerSecond(
//       newEmissionPerAsset.asset,
//       newEmissionPerAsset.rewards,
//       newEmissionPerAsset.newEmissionsPerSecond
//     );
//     emit log_named_bytes(
//       'calldata to execute tx on EMISSION_MANAGER to set the new emission per second from the emissions admin (safe)',
//       abi.encodeWithSelector(
//         IEmissionManager.setEmissionPerSecond.selector,
//         newEmissionPerAsset.asset,
//         newEmissionPerAsset.rewards,
//         newEmissionPerAsset.newEmissionsPerSecond
//       )
//     );

//     // Calculate new distribution end (14 days after the initial end)
//     uint32 newDistributionEnd = uint32(block.timestamp + 15 days);

//     vm.startPrank(EMISSION_ADMIN);

//     // Call setDistributionEnd with single values instead of arrays
//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
//         BTCb_A_TOKEN,
//         REWARD_ASSET,
//         newDistributionEnd
//     );

//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
//         WAVAX_V_TOKEN,
//         REWARD_ASSET,
//         newDistributionEnd
//     );

//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
//         USDC_A_TOKEN,
//         REWARD_ASSET,
//         newDistributionEnd
//     );

//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
//         USDC_V_TOKEN,
//         REWARD_ASSET,
//         newDistributionEnd
//     );

//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
//         sAVAX_A_TOKEN,
//         REWARD_ASSET,
//         newDistributionEnd
//     );

//     IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
//         USDt_A_TOKEN,
//         REWARD_ASSET,
//         newDistributionEnd
//     );

//     emit log_named_bytes(
//         'calldata to execute tx on EMISSION_MANAGER to extend the distribution end from the emissions admin (safe)',
//         abi.encodeWithSelector(
//             IEmissionManager.setDistributionEnd.selector,
//             BTCb_A_TOKEN,
//             REWARD_ASSET,
//             newDistributionEnd
//         )
//     );

//     vm.stopPrank();

//     address[] memory assets = new address[](1);
//     assets[0] = sAVAX;

//     // claim pending rewards

//     IAaveIncentivesController(AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER).claimRewards(
//       assets,
//       type(uint256).max,
//       GHO_A_TOKEN_WHALE,
//       REWARD_ASSET
//     );

//     vm.warp(block.timestamp + 15 days);

    

//     uint256 balanceBefore = IERC20(REWARD_ASSET).balanceOf(GHO_A_TOKEN_WHALE);

//     vm.startPrank(GHO_A_TOKEN_WHALE);

//     IAaveIncentivesController(AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER).claimRewards(
//       assets,
//       type(uint256).max,
//       GHO_A_TOKEN_WHALE,
//       REWARD_ASSET
//     );

//     vm.stopPrank();

//     uint256 balanceAfter = IERC20(REWARD_ASSET).balanceOf(GHO_A_TOKEN_WHALE);

//     // Approx estimated rewards with current emission in 1 month, considering the new emissions per second set.
//     uint256 deviationAccepted = 14_600 ether;
//     assertApproxEqAbs(
//       balanceBefore,
//       balanceAfter,
//       deviationAccepted,
//       'Invalid delta on claimed rewards'
//     );
//   }

//   function _getNewEmissionPerSecond() internal pure returns (NewEmissionPerAsset memory) {
//     NewEmissionPerAsset memory newEmissionPerAsset;

//     address[] memory rewards = new address[](1);
//     rewards[0] = REWARD_ASSET;
//     uint88[] memory newEmissionsPerSecond = new uint88[](1);
//     newEmissionsPerSecond[0] = _toUint88(NEW_TOTAL_DISTRIBUTION / DURATION_DISTRIBUTION);

//     newEmissionPerAsset.asset = GHO_A_TOKEN;
//     newEmissionPerAsset.rewards = rewards;
//     newEmissionPerAsset.newEmissionsPerSecond = newEmissionsPerSecond;

//     return newEmissionPerAsset;
//   }

//   function _getNewDistributionEnd() internal view returns (NewDistributionEndPerAsset memory) {
//     NewDistributionEndPerAsset memory newDistributionEndPerAsset;

//     newDistributionEndPerAsset.asset = GHO_A_TOKEN;
//     newDistributionEndPerAsset.reward = REWARD_ASSET;
//     newDistributionEndPerAsset.newDistributionEnd = _toUint32(
//       block.timestamp + NEW_DURATION_DISTRIBUTION_END
//     );

//     return newDistributionEndPerAsset;
//   }

//   function _toUint32(uint256 value) internal pure returns (uint32) {
//     require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
//     return uint32(value);
//   }
//   function _toUint88(uint256 value) internal pure returns (uint88) {
//     require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
//     return uint88(value);
//   }
// }