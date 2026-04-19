// SPDX-License-Identifier: LicenseRef-BUSL
pragma solidity 0.8.33;

import {IBasicInterestRateStrategy} from 'src/hub/interfaces/IBasicInterestRateStrategy.sol';

interface IInterestRateStrategy is IBasicInterestRateStrategy {

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


}