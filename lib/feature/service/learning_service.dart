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
          imageUrl: 'assets/images/learning/hammer.png',
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
          imageUrl: 'assets/images/learning/engulfing.png',
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
    LearningCategory(
      id: 'cat_sr',
      title: 'Support & Resistance',
      description: 'The foundation of technical analysis.',
      icon: Icons.layers_rounded,
      color: const Color(0xFFFACC15),
      lessons: [
        LessonModel(
          id: 'sr_1',
          title: 'Understanding Support',
          estimatedMinutes: 5,
          categoryId: 'cat_sr',
          imageUrl: 'assets/images/learning/support_resistance.png',
          content: '''
# Support: The Floor

**Support** is a price level where a downtrend tends to pause due to a concentration of demand (buying power).

## How it Works
Think of it as a "floor." When the price drops to this level, buyers see it as "cheap" and start buying, which prevents the price from falling further.

## Key Characteristics
- **Bounces**: Each time the price touches and bounces off the level, the support becomes stronger.
- **Psychological Levels**: Round numbers (like \$10, \$50, \$100) often act as natural support.
- **Historical Areas**: Look for areas where the price has reversed in the past.
          ''',
        ),
        LessonModel(
          id: 'sr_2',
          title: 'Understanding Resistance',
          estimatedMinutes: 5,
          categoryId: 'cat_sr',
          imageUrl: 'assets/images/learning/support_resistance.png',
          content: '''
# Resistance: The Ceiling

**Resistance** is a price level where an uptrend tends to pause or reverse due to a concentration of supply (selling power).

## How it Works
Think of it as a "ceiling." When the price rises to this level, sellers see it as "expensive" and start selling, which prevents the price from rising further.

## Role Reversal
A very important concept in trading is that **Broken Resistance becomes Support**, and **Broken Support becomes Resistance**. If the market breaks through the "ceiling," it often turns into the new "floor."
          ''',
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_structure',
      title: 'Market Structure',
      description: 'The blueprint of price movement.',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF38BDF8),
      lessons: [
        LessonModel(
          id: 'struct_1',
          title: 'Market Phases',
          estimatedMinutes: 6,
          categoryId: 'cat_structure',
          imageUrl: 'assets/images/learning/market_structure.png',
          content: '''
# Market Phases: HH, HL, LH, LL

To understand where the market is going, you must understand **Structure**.

## Uptrend (Bullish)
A market is in an uptrend when it makes **Higher Highs (HH)** and **Higher Lows (HL)**.

## Downtrend (Bearish)
A market is in a downtrend when it makes **Lower Lows (LL)** and **Lower Highs (LH)**.

## Why it Matters
Trading is simply identifying the structure and following it. If the structure is Bullish, you only look for Buy opportunities at the Higher Lows.
          ''',
        ),
        LessonModel(
          id: 'struct_2',
          title: 'BOS vs CHoCH',
          estimatedMinutes: 8,
          categoryId: 'cat_structure',
          imageUrl: 'assets/images/learning/market_structure.png',
          content: '''
# Advanced Structure: BOS & CHoCH

Price doesn't move in a straight line. It breaks old levels to create new ones.

## BOS (Break of Structure)
When price continues the trend by breaking the previous HH (in an uptrend) or LL (in a downtrend), it is called a **BOS**. It confirms the trend is healthy.

## CHoCH (Change of Character)
When price fails to make a new HH and instead breaks below the previous HL, it is a **CHoCH**. This is the first signal that the trend might be reversing.

Mastering BOS and CHoCH allows you to enter trades at the very beginning of a new trend.
          ''',
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_indicators',
      title: 'Technical Indicators',
      description: 'Using math to confirm your bias.',
      icon: Icons.show_chart_rounded,
      color: const Color(0xFFFB7185),
      lessons: [
        LessonModel(
          id: 'ind_1',
          title: 'RSI Mastery',
          estimatedMinutes: 7,
          categoryId: 'cat_indicators',
          imageUrl: 'assets/images/learning/rsi.png',
          content: '''
# RSI: Relative Strength Index

The **RSI** is a momentum oscillator that measures the speed and change of price movements.

## Overbought (Above 70)
When RSI is above 70, the market is considered "Overbought." This doesn't mean you should sell immediately, but it signals that the trend might be exhausted.

## Oversold (Below 30)
When RSI is below 30, the market is "Oversold." It signals that the selling pressure might be ending.

## Divergence: The Secret Weapon
If price makes a **Higher High** but RSI makes a **Lower High**, it is called "Bearish Divergence." This is one of the strongest reversal signals in trading.
          ''',
        ),
        LessonModel(
          id: 'ind_2',
          title: 'Moving Averages (EMA)',
          estimatedMinutes: 6,
          categoryId: 'cat_indicators',
          imageUrl: 'assets/images/learning/ema_crossover.png',
          content: '''
# EMA: The Trend Smoother

Moving averages help you filter out "noise" from the price action and see the clear trend.

## Fast vs Slow EMA
- **20 EMA (Fast)**: Reacts quickly to price changes. Good for short-term trends.
- **50 EMA (Slow)**: Solid support/resistance for long-term trends.

## The Crossover Strategy
1. **Golden Cross**: When the 20 EMA crosses **above** the 50 EMA. This confirms a strong Bullish momentum.
2. **Death Cross**: When the 20 EMA crosses **below** the 50 EMA. This confirms a strong Bearish momentum.

Stay on the right side of the moving average to stay on the right side of the profit.
          ''',
        ),
        LessonModel(
          id: 'ind_3',
          title: 'MACD: Momentum Master',
          estimatedMinutes: 8,
          categoryId: 'cat_indicators',
          content: '''
# MACD: Moving Average Convergence Divergence

The MACD is a multi-purpose tool that shows trend direction, momentum, and potential reversals.

## The Signal Line Crossover
- **Bullish**: When the MACD line (Blue) crosses **above** the Signal line (Orange).
- **Bearish**: When the MACD line crosses **below** the Signal line.

## Histogram Insights
The histogram bars show the distance between the two lines. When the bars are getting taller, momentum is increasing. When they shrink, momentum is fading.
          ''',
        ),
        LessonModel(
          id: 'ind_4',
          title: 'Bollinger Bands',
          estimatedMinutes: 7,
          categoryId: 'cat_indicators',
          content: '''
# Bollinger Bands: Volatility Measurement

These bands expand and contract based on market volatility.

## The Squeeze
When the bands come close together, it's called a **Squeeze**. This signals that a big price move is about to happen soon.

## Riding the Bands
In a strong trend, the price will often "hug" the upper band (in an uptrend) or lower band (in a downtrend). A break outside the band often signals a temporary exhaustion.
          ''',
        ),
      ],
    ),
  ];
}
