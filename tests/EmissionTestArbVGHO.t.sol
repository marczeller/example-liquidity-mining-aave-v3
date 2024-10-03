// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {IAaveIncentivesController} from '../src/interfaces/IAaveIncentivesController.sol';
import {IEmissionManager, ITransferStrategyBase, RewardsDataTypes, IEACAggregatorProxy} from '../src/interfaces/IEmissionManager.sol';
import {BaseTest} from './utils/BaseTest.sol';
import 'forge-std/console.sol';

contract ArbitrumCampaignTest is BaseTest {
  address constant GHO_V_TOKEN = AaveV3ArbitrumAssets.GHO_V_TOKEN;
  address constant ARB_ORACLE = AaveV3ArbitrumAssets.ARB_ORACLE;
  address constant ARB = AaveV3ArbitrumAssets.ARB_UNDERLYING;

  address constant EMISSION_ADMIN = 0xac140648435d03f784879cd789130F22Ef588Fcd; // ACI
  address constant REWARD_ASSET = ARB;

  uint256 constant TOTAL_DISTRIBUTION = 218_700 ether;
  uint88 constant DURATION_DISTRIBUTION = 42 days;

  IEACAggregatorProxy constant REWARD_ORACLE = IEACAggregatorProxy(ARB_ORACLE);

  ITransferStrategyBase constant TRANSFER_STRATEGY =
    ITransferStrategyBase(0x991bf7661F1F2695ac8AEFc4F9a19718d6424dc0);

  address GHO_V_TOKEN_WHALE = 0x91603dCf1Be1020f2775d109E6DB75E3A7DbE7Cf;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 257283703);
  }

  function test_configureAssets() public {
    vm.startPrank(EMISSION_ADMIN);

    // Approve TOTAL_DISTRIBUTION to the transfer strategy
    IERC20(REWARD_ASSET).approve(address(TRANSFER_STRATEGY), TOTAL_DISTRIBUTION);

    // Configure assets
    IEmissionManager(AaveV3Arbitrum.EMISSION_MANAGER).configureAssets(_getAssetConfigs());

    emit log_named_bytes(
      'calldata to submit from Gnosis Safe',
      abi.encodeWithSelector(
        IEmissionManager(AaveV3Arbitrum.EMISSION_MANAGER).configureAssets.selector,
        _getAssetConfigs()
      )
    );

    vm.stopPrank();

    // Test claiming rewards with the expected claim of 36,000 ARB
    _testClaimRewardsForWhale(GHO_V_TOKEN_WHALE, GHO_V_TOKEN, 36_000 ether);
  }

  function _testClaimRewardsForWhale(address whale, address asset, uint256 expectedReward) internal {
    vm.startPrank(whale);

    vm.warp(block.timestamp + DURATION_DISTRIBUTION);

    address[] memory assets = new address[](1);
    assets[0] = asset;

    uint256 balanceBefore = IERC20(REWARD_ASSET).balanceOf(whale);

    IAaveIncentivesController(AaveV3Arbitrum.DEFAULT_INCENTIVES_CONTROLLER).claimRewards(
      assets,
      type(uint256).max,
      whale,
      REWARD_ASSET
    );

    uint256 balanceAfter = IERC20(REWARD_ASSET).balanceOf(whale);

    uint256 deviationAccepted = expectedReward;
    assertApproxEqAbs(
      balanceBefore,
      balanceAfter,
      deviationAccepted,
      'Invalid delta on claimed rewards'
    );

    vm.stopPrank();
  }

  function _getAssetConfigs() internal view returns (RewardsDataTypes.RewardsConfigInput[] memory) {
    uint32 distributionEnd = uint32(block.timestamp + DURATION_DISTRIBUTION);

    RewardsDataTypes.RewardsConfigInput[] memory configs = new RewardsDataTypes.RewardsConfigInput[](1);
    configs[0] = RewardsDataTypes.RewardsConfigInput({
      emissionPerSecond: _toUint88(TOTAL_DISTRIBUTION / DURATION_DISTRIBUTION),
      totalSupply: 0,
      distributionEnd: distributionEnd,
      asset: GHO_V_TOKEN,
      reward: REWARD_ASSET,
      transferStrategy: TRANSFER_STRATEGY,
      rewardOracle: REWARD_ORACLE
    });

    return configs;
  }

  function _toUint88(uint256 value) internal pure returns (uint88) {
    require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
    return uint88(value);
  }
}