import '../model/trade_plan_model.dart';

class TradeController {
  // Assuming a default payout ratio of 82% (0.82)
  static const double defaultPayout = 0.82;

  static List<TradeEntryModel> generateInitialPlan({
    required double balance,
    required double payoutPercentage,
  }) {
    List<TradeEntryModel> entries = [];
    double payoutRatio = payoutPercentage / 100;
    
    // 1% of Balance
    double investAmount = balance * 0.01;
    double potentialProfit = investAmount * payoutRatio;
          
    entries.add(TradeEntryModel(
      step: 1,
      investAmount: double.parse(investAmount.toStringAsFixed(2)),
      potentialProfit: double.parse(potentialProfit.toStringAsFixed(2)),
    ));

    return entries;
  }

  static TradeEntryModel createNextStepTrade({
    required int nextStep,
    required double balance,
    required double payoutPercentage,
  }) {
    double payoutRatio = payoutPercentage / 100;
    // 1% of Current Balance
    double investAmount = balance * 0.01;
    double potentialProfit = investAmount * payoutRatio;

    return TradeEntryModel(
      step: nextStep,
      investAmount: double.parse(investAmount.toStringAsFixed(2)),
      potentialProfit: double.parse(potentialProfit.toStringAsFixed(2)),
    );
  }

  static TradeEntryModel createRecoveryTrade({
    required int stepNumber,
    required double balance,
    required double payoutPercentage,
  }) {
    double payoutRatio = payoutPercentage / 100;
    // 2.5% of Balance for recovery
    double recoveryInvest = balance * 0.025;
    double potentialProfit = recoveryInvest * payoutRatio;

    return TradeEntryModel(
      step: stepNumber,
      investAmount: double.parse(recoveryInvest.toStringAsFixed(2)),
      potentialProfit: double.parse(potentialProfit.toStringAsFixed(2)),
      isRecovery: true,
    );
  }
}
