enum AssetType { forex, crypto, stocks }

class RiskResult {
  final double riskAmount;
  final double positionSize;
  final String unit;

  RiskResult({
    required this.riskAmount,
    required this.positionSize,
    required this.unit,
  });
}

class RiskCalculationUtils {
  /// Calculates position size based on risk parameters.
  ///
  /// [balance]: Total account balance
  /// [riskPercentage]: % of balance to risk (e.g., 1.0 for 1%)
  /// [stopLoss]: Distance to stop loss in pips/points
  /// [assetType]: Type of asset being traded
  /// [contractSize]: Standard contract size (e.g., 100,000 for Forex standard lot)
  static RiskResult calculatePositionSize({
    required double balance,
    required double riskPercentage,
    required double stopLoss,
    required AssetType assetType,
    double contractSize = 100000, // Default for Forex Standard Lot
  }) {
    // 1. Calculate amount to risk in currency
    double riskAmount = balance * (riskPercentage / 100);

    double positionSize = 0;
    String unit = "";

    switch (assetType) {
      case AssetType.forex:
        // Position Size (Lots) = Risk Amount / (Stop Loss * Pip Value)
        // For simplicity assuming 1 pip = 10 USD for 1 standard lot
        // A more complex version would take account currency and pair into account
        if (stopLoss > 0) {
          positionSize = riskAmount / (stopLoss * (contractSize / 10000));
        }
        unit = "Lots";
        break;

      case AssetType.crypto:
      case AssetType.stocks:
        // Position Size (Units) = Risk Amount / Stop Loss (Price distance)
        if (stopLoss > 0) {
          positionSize = riskAmount / stopLoss;
        }
        unit = assetType == AssetType.crypto ? "Coins" : "Shares";
        break;
    }

    return RiskResult(
      riskAmount: riskAmount,
      positionSize: positionSize,
      unit: unit,
    );
  }
}
