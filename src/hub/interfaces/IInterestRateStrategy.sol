// SPDX-License-Identifier: LicenseRef-BUSL
pragma solidity 0.8.33;

import {IBasicInterestRateStrategy} from 'src/hub/interfaces/IBasicInterestRateStrategy.sol';

interface IInterestRateStrategy is IBasicInterestRateStrategy {
  struct InterestRateData {
    uint16 optimalUsageRatio;
    uint32 baseDrawnRate;
    uint32 rateGrowthBeforeOptimal;
    uint32 rateGrowthAfterOptimal;
  }

  event UpdateInterestRateData(
    address indexed hub,
    uint256 optimalUsageRatio,
    uint256 baseDrawnRate,
    uint256 rateGrowthBeforeOptimal,
    uint256 rateGrowthAfterOptimal
  );

  error InvalidAddress();
  error OnlyHub();
  error InvalidMaxDrawnRate();
  error InvalidOptimalUsageRatio();

  function getInterestRateData() external view returns (InterestRateData memory);

  function getOptimalUsageRatio() external view returns (uint256);

  function getBaseDrawnRate() external view returns (uint256);

  function getRateGrowthAfterOptimal() external view returns (uint256);

  function getRateGrowthBeforeOptimal() external view returns (uint256);

  function getMaxDrawnRate() external view returns (uint256);

  function MAX_ALLOWED_DRAWN_RATE() external view returns (uint256);

  function MIN_OPTIMAL_RATIO() external view returns (uint256);

  function MAX_OPTIMAL_RATIO() external view returns (uint256);

  function HUB() external view returns (address);
}