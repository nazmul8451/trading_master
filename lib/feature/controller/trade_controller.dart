import '../model/trade_plan_model.dart';

class TradeController {
  // Assuming a default payout ratio of 82% (0.82)
  static const double defaultPayout = 0.82;

  static const int defaultSteps = 4;

  static List<TradeEntryModel> generateInitialPlan({
    required double totalTarget,
    required double payoutPercentage,
    int steps = defaultSteps,
  }) {
    List<TradeEntryModel> entries = [];
    double payoutRatio = payoutPercentage / 100;
    
    // Split the total target into equal small wins (steps)
    double targetPerStep = totalTarget / steps;

    // Generate ONLY the first step initially
    double investAmount = targetPerStep / payoutRatio;
         
    entries.add(TradeEntryModel(
      step: 1,
      investAmount: double.parse(investAmount.toStringAsFixed(2)),
      potentialProfit: double.parse(targetPerStep.toStringAsFixed(2)),
    ));

    return entries;
  }

  static TradeEntryModel createNextStepTrade({
    required int nextStep,
    required double totalTarget,
    required double payoutPercentage,
    int totalSteps = defaultSteps,
  }) {
    double targetPerStep = totalTarget / totalSteps;
    double payoutRatio = payoutPercentage / 100;
    double investAmount = targetPerStep / payoutRatio;

    return TradeEntryModel(
      step: nextStep,
      investAmount: double.parse(investAmount.toStringAsFixed(2)),
      potentialProfit: double.parse(targetPerStep.toStringAsFixed(2)),
    );
  }

  static double calculateRecoveryAmount({
    required double totalLossToRecover,
    required double originalTargetProfit,
    required double payoutPercentage,
  }) {
    // Investment = (Total Loss + Desired Profit) / payoutRatio
    double payoutRatio = payoutPercentage / 100;
    double amount = (totalLossToRecover + originalTargetProfit) / payoutRatio;
    return double.parse(amount.toStringAsFixed(2));
  }

  // Helper to create a NEW recovery trade object to be inserted into the list
  static TradeEntryModel createRecoveryTrade({
    required int stepNumber, // Should match the step we are trying to recover
    required double lossToRecover,
    required double targetProfitForStep,
    required double payoutPercentage,
  }) {
    double recoveryInvest = calculateRecoveryAmount(
      totalLossToRecover: lossToRecover,
      originalTargetProfit: targetProfitForStep,
      payoutPercentage: payoutPercentage,
    );

    return TradeEntryModel(
      step: stepNumber,
      investAmount: recoveryInvest,
      potentialProfit: targetProfitForStep,
      isRecovery: true,
    );
  }
}
