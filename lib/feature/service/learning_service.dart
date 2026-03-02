import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../model/learning_model.dart';

class LearningService {
  static final _storage = GetStorage();
  static const String _completedLessonsKey = 'completed_lessons';

  static List<String> getCompletedLessonIds() {
    final List<dynamic>? ids = _storage.read(_completedLessonsKey);
    return ids?.cast<String>() ?? [];
  }

  static void markLessonAsCompleted(String lessonId) {
    final completedIds = getCompletedLessonIds();
    if (!completedIds.contains(lessonId)) {
      completedIds.add(lessonId);
      _storage.write(_completedLessonsKey, completedIds);
    }
  }

  static double getProgress() {
    final completedCount = getCompletedLessonIds().length;
    final totalCount = getAllLessons().length;
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  static List<LessonModel> getAllLessons() {
    return categories.expand((c) => c.lessons).toList();
  }

  static final List<LearningCategory> categories = [
    LearningCategory(
      id: 'cat_risk',
      title: 'Risk Management',
      description: 'Master the art of survival in the markets.',
      icon: Icons.security_rounded,
      color: const Color(0xFFEF4444),
      lessons: [
        LessonModel(
          id: 'risk_1',
          title: 'The 1% Rule',
          estimatedMinutes: 5,
          categoryId: 'cat_risk',
          content: '''
# The 1% Rule: Survival First

One of the most important rules in trading is the **1% Rule**. It states that you should never risk more than 1% of your total trading capital on a single trade.

## Why 1%?
Trading is a game of probabilities. Even the best traders have losing streaks. If you risk 10% per trade, a streak of 5 losses will wipe out 50% of your account. Recovering from a 50% loss requires a **100% gain** just to get back to break-even.

## How to Calculate
1. **Total Capital**: \$1,000
2. **Risk Amount (1%)**: \$10
3. **Stop Loss Distance**: 20 pips / points
4. **Position Size**: \$10 risk / 20 pips = \$0.50 per pip

By following this rule, you ensure that no single mistake or bad streak can end your trading career.
          ''',
        ),
        LessonModel(
          id: 'risk_2',
          title: 'Risk to Reward Ratio',
          estimatedMinutes: 7,
          categoryId: 'cat_risk',
          content: '''
# Risk to Reward (R:R)

The Risk to Reward ratio compares how much you are willing to lose versus how much you expect to gain.

## The Magic Ratio: 1:2
A minimum R:R of **1:2** means for every \$1 you risk, you aim to make \$2.

## Why it matters
With a 1:2 R:R, you only need a **34% win rate** to be profitable. 
- 10 trades
- 4 Wins (\$8 profit)
- 6 Losses (\$6 loss)
- **Net Profit: \$2**

Stop looking for a "Holy Grail" indicator and start focusing on your R:R.
          ''',
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_psych',
      title: 'Trading Psychology',
      description: 'Control your emotions to control your profits.',
      icon: Icons.psychology_rounded,
      color: const Color(0xFF8B5CF6),
      lessons: [
        LessonModel(
          id: 'psych_1',
          title: 'The Revenge Trading Trap',
          estimatedMinutes: 6,
          categoryId: 'cat_psych',
          content: '''
# Revenge Trading: The Account Killer

Revenge trading happens when you try to "win back" money immediately after a loss. It is fueled by anger and frustration, not logic.

## The Symptoms
- Increasing position size after a loss.
- Entering a trade without a setup just to be "in the market".
- Feeling like the market "owes you" something.

## How to Stop
1. **Walk away**: After a loss, close your laptop for at least 30 minutes.
2. **Daily Loss Limit**: If you hit your max loss for the day, **stop trading** immediately.
3. **Journal**: Write down how you feel. Acknowledging the emotion reduces its power.
          ''',
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_strat',
      title: 'Basic Strategies',
      description: 'Simple approaches for consistent growth.',
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF10B981),
      lessons: [
        LessonModel(
          id: 'strat_1',
          title: 'Trend is Your Friend',
          estimatedMinutes: 8,
          categoryId: 'cat_strat',
          content: '''
# Trend Following

The simplest way to trade is to follow the existing momentum of the market.

## Identifying a Trend
- **Uptrend**: Higher Highs (HH) and Higher Lows (HL).
- **Downtrend**: Lower Lows (LL) and Lower Highs (LH).

## Rule of Thumb
Never trade against the trend on the higher timeframe. If the Daily chart is going up, only look for "Buy" setups on the 1-hour chart.

"The trend is your friend until the end when it bends."
          ''',
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_candles',
      title: 'Candlestick Mastery',
      description: 'Learn the language of the market.',
      icon: Icons.signal_cellular_alt_rounded,
      color: const Color(0xFFFFD700),
      lessons: [
        LessonModel(
          id: 'candle_1',
          title: 'The Hammer Pattern',
          estimatedMinutes: 5,
          categoryId: 'cat_candles',
          content: '''
# The Hammer: A Bullish Signal

The **Hammer** is a single candlestick pattern that forms at the bottom of a downtrend. It signals a potential reversal.

## How to Identify
- **Small Body**: Located at the top of the candle.
- **Long Lower Wick**: At least 2x the size of the body.
- **No Upper Wick**: Or a very small one.

## What it Means
The long lower wick shows that sellers pushed the price down, but buyers stepped in aggressively to push the price back up near the opening. It shows that the "bears" are losing control and the "bulls" are taking over.

## Pro Tip
Always wait for the **next candle** to close above the hammer's body for confirmation before entering a trade.
          ''',
        ),
        LessonModel(
          id: 'candle_2',
          title: 'Engulfing Patterns',
          estimatedMinutes: 6,
          categoryId: 'cat_candles',
          content: '''
# Engulfing Patterns: Strong Momentum

Engulfing patterns consist of two candles and show a dramatic shift in market sentiment.

## Bullish Engulfing
- **Candle 1**: A small red (bearish) candle.
- **Candle 2**: A large green (bullish) candle that **completely covers** the body of the first candle.
- **Signal**: Powerful reversal signal at the bottom of a downtrend.

## Bearish Engulfing
- **Candle 1**: A small green (bullish) candle.
- **Candle 2**: A large red (bearish) candle that **completely covers** the body of the first candle.
- **Signal**: Strong reversal signal at the top of an uptrend.

These patterns are most effective when they happen at **Support or Resistance** levels.
          ''',
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_growth',
      title: 'Small Account Growth',
      description: 'Strategic tips for growing low capital.',
      icon: Icons.trending_up,
      color: const Color(0xFF60A5FA),
      lessons: [
        LessonModel(
          id: 'growth_1',
          title: 'The Power of Compounding',
          estimatedMinutes: 7,
          categoryId: 'cat_growth',
          content: '''
# Grow Small, End Big

Growing a small account (e.g., \$100) is **harder** than growing a large one because of the emotional pressure to "get rich quick."

## The Compounding Secret
Instead of trying to double your money in a day, aim for a **small daily target** (e.g., 2-5%).

## The Math
If you start with **\$100** and make just **3% daily profit**:
- Day 1: \$103
- Day 30: \$242
- Day 60: \$589
- Day 100: \$1,921

## The Rules for Low Capital
1. **Don't Overtrade**: 2-3 high-quality trades are enough.
2. **Patience**: Accept that you won't buy a Lambo tomorrow.
3. **Withdraw Profits**: Once you double your account, withdraw your initial capital.
          ''',
        ),
        LessonModel(
          id: 'growth_2',
          title: 'Low Capital Strategy',
          estimatedMinutes: 6,
          categoryId: 'cat_growth',
          content: '''
# Low Capital Strategy

When your capital is low, you have **zero room for error**. You must be a "Sniper," not a "Machine Gunner."

## 1. Focus on One Asset
Choose one pair (e.g., EUR/USD or Gold) and learn its movement patterns perfectly. Don't jump between 10 different assets.

## 2. Use Higher Timeframes for Direction
Even if you enter on a 1-minute chart, always check the **15-minute or 1-hour chart** for the overall trend. Trading against the "Big Money" trend will wipe out a small account instantly.

## 3. Strict Stop Loss
Never trade without a Stop Loss. A small account can't survive a "hope it goes back up" trade. If the trade hits your SL, **it's okay**. Analyze why, and move to the next opportunity.
          ''',
        ),
      ],
    ),
  ];
}
