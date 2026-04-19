// SPDX-License-Identifier: LicenseRef-BUSL
pragma solidity 0.8.33;

import {WadRayMath} from 'src/lib/math/WadRayMath.sol';
import {
  IInterestRateStrategy,
  IBasicInterestRateStrategy
} from 'src/hub/interfaces/IInterestRateStrategy.sol';

contract InterestRateStrategy is IInterestRateStrategy {
  using WadRayMath for *;

  /// @inheritdoc IInterestRateStrategy
  uint256 public constant MAX_ALLOWED_DRAWN_RATE = 1000_00;

  /// @inheritdoc IInterestRateStrategy
  uint256 public constant MIN_OPTIMAL_RATIO = 1_00;

  /// @inheritdoc IInterestRateStrategy
  uint256 public constant MAX_OPTIMAL_RATIO = 99_00;

  address public immutable HUB;

  InterestRateData internal _rateData;

  constructor(address hub_) {
    require(hub_ != address(0), InvalidAddress());
    HUB = hub_;
  }

  function setInterestRateData(bytes calldata data) external {
    require(HUB == msg.sender, OnlyHub());

    InterestRateData memory rateData = abi.decode(data, (InterestRateData));
    require(
      MIN_OPTIMAL_RATIO <= rateData.optimalUsageRatio &&
        rateData.optimalUsageRatio <= MAX_OPTIMAL_RATIO,
      InvalidOptimalUsageRatio()
    );
    require(
      rateData.baseDrawnRate + rateData.rateGrowthBeforeOptimal + rateData.rateGrowthAfterOptimal <=
        MAX_ALLOWED_DRAWN_RATE,
      InvalidMaxDrawnRate()
    );

    _rateData = rateData;

    emit UpdateInterestRateData(
      HUB,
      rateData.optimalUsageRatio,
      rateData.baseDrawnRate,
      rateData.rateGrowthBeforeOptimal,
      rateData.rateGrowthAfterOptimal
    );
  }

  function getInterestRateData() external view returns (InterestRateData memory) {
    return _rateData;
  }

  function getOptimalUsageRatio() external view returns (uint256) {
    return _rateData.optimalUsageRatio;
  }

  function getBaseDrawnRate() external view returns (uint256) {
    return _rateData.baseDrawnRate;
  }

  function getRateGrowthAfterOptimal() external view returns (uint256) {
    return _rateData.rateGrowthAfterOptimal;
  }

  function getRateGrowthBeforeOptimal() external view returns (uint256) {
    return _rateData.rateGrowthBeforeOptimal;
  }

  function getMaxDrawnRate() external view returns (uint256) {
    return
    _rateData.baseDrawnRate +
    _rateData.rateGrowthBeforeOptimal +
    _rateData.rateGrowthAfterOptimal;
  }

  /// @inheritdoc IBasicInterestRateStrategy
  function calculateInterestRate(
    uint256 liquidity,
    uint256 drawn,
    uint256 /* deficit */,
    uint256 swept
  ) external view returns (uint256) {
    require(_rateData.optimalUsageRatio > 0, InterestRateDataNotSet());

    uint256 currentDrawnRateRay = _rateData.baseDrawnRate.bpsToRay();
    if (drawn == 0) {
      return currentDrawnRateRay;
    }

    uint256 usageRatioRay = drawn.rayDivUp(liquidity + drawn + swept);
    uint256 optimalUsageRatioRay = _rateData.optimalUsageRatio.bpsToRay();

    if (usageRatioRay <= optimalUsageRatioRay) {
      currentDrawnRateRay += _rateData
        .rateGrowthBeforeOptimal
        .bpsToRay()
        .rayMulUp(usageRatioRay)
        .rayDivUp(optimalUsageRatioRay);
    } else {
      currentDrawnRateRay +=
        _rateData.rateGrowthBeforeOptimal.bpsToRay() +
        _rateData
          .rateGrowthAfterOptimal
          .bpsToRay()
          .rayMulUp(usageRatioRay - optimalUsageRatioRay)
          .rayDivUp(WadRayMath.RAY - optimalUsageRatioRay);
    }

    return currentDrawnRateRay;
  }
}