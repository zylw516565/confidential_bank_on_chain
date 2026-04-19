// SPDX-License-Identifier: LicenseRef-BUSL
pragma solidity 0.8.33;

interface IBasicInterestRateStrategy {
  error InterestRateDataNotSet();

  function setInterestRateData(bytes calldata data) external;

  function calculateInterestRate(
    uint256 liquidity,
    uint256 drawn,
    uint256 /* deficit */,
    uint256 swept
  ) external view returns (uint256);
}