# Trading Master - App Documentation

## 1. Overview
**Trading Master** is a comprehensive mobile application designed for traders to manage their capital, plan compounding growth, track daily goals, and journal their trading psychology. The app features a premium, glassmorphism-inspired dark UI for a focused trading environment.

## 2. Core Features & User Flow

### 2.1 Dashboard (`DashboardScreen`)
- **Central Hub**: Displays current balance, quick actions, and navigation.
- **Glassmorphism UI**: Uses `GlassContainer` and `PremiumBackground` for a modern look.
- **Key Modules**:
  - **Balance Card**: Shows current wallet balance derived from `WalletService`.
  - **Quick Actions**: "Start New Trade", "Goal Plan", "Journal", etc.
  - **Compounding Curve**: Visual projection of growth (currently static visualization).

### 2.2 Plan Creation (`CreatePlanScreen` & `TradeSetupScreen`)
- **Purpose**: Allows users to generate a trading plan based on:
  - **Capital**: Starting investment.
  - **Target Profit %**: Daily growth goal.
  - **Duration**: Days, Weeks, or Months.
- **Logic**: Uses compounding interest formulas to calculate daily targets.
- **Outcome**: Creates a `TradePlanModel` saved via `TradeStorageService`.

### 2.3 Plan Library (`GoalPlansLibraryScreen`)
- **View All Plans**: Lists all active active trading plans.
- **Filtering**: Filter plans by duration type (Days, Weeks, Months).
- **Management**: Long-press to select and delete plans.
- **Navigation**: Tapping a plan opens the `GoalPlanDetailScreen`.

### 2.4 Active Plan Tracking (`GoalPlanDetailScreen`)
- **Daily Progress**: Shows a list of daily targets (Steps).
- **Interaction**: Users mark days as "Target Hit" (Success) or "Stop Loss" (Risk Management).
- **Feedback**: Premium dialogs provide immediate feedback and encouragement based on the outcome.
- **State**: Updates the `TradeEntryModel` status (switches from 'pending' to 'win'/'loss').

### 2.5 Journaling (`JournalScreen`)
- **Trading Journal**: A dedicated space for traders to log thoughts, emotions, and trade confirmations.
- **Editor**: Supports basic text entry for keeping a record of trading psychology.

### 2.6 Settings (`SettingsScreen`)
- **Profile**: View user details.
- **Wallet Management**: Manually deposit or withdraw funds to correct the app's balance tracking.
- **Preferences**: Toggle notifications and biometric security.

## 3. Technical Architecture

### 3.1 Tech Stack
- **Framework**: Flutter (Dart).
- **State Management**: `setState` (Local) + `GetStorage` (Persistence).
- **Responsiveness**: `flutter_screenutil` (Scaling for different screen sizes).
- **Persistence**: `get_storage` for local data saving (Plans, Journal, Wallet).

### 3.2 Data Models
- **`TradePlanModel`**: Represents a full compounding plan.
  - `id`, `balance`, `targetProfit`, `durationType`, `entries` (List of days).
- **`TradeEntryModel`**: Represents a single day/trade step.
  - `step`, `investAmount`, `potentialProfit`, `status` ('pending', 'win', 'loss').

### 3.3 Services
- **`TradeStorageService`**: Handles CRUD operations for Trade Plans and Journals.
- **`WalletService`**: Manages the global wallet balance and persists it.

### 3.4 Design System (`core/widgets`)
- **`PremiumBackground`**: The consistent dark, gradient-blob background.
- **`GlassContainer`**: A reusable container with blur, gradient border, and transparency.
- **`AnimatedEntrance`**: wrapper for staggered entrance animations.
- **`AppTypography` & `AppColors`**: Centralized design tokens.

## 4. How It All Connects
1.  **User Starts**: lands on `DashboardScreen`.
2.  **Creates Plan**: Goes to `CreatePlanScreen` -> Inputs Data -> Generates `TradePlanModel`.
3.  **Views Plan**: Redirected to `GoalPlanDetailScreen` (or finds it later in `GoalPlansLibraryScreen`).
4.  **Tracks Progress**: Marks daily targets on `GoalPlanDetailScreen`.
5.  **Analyzes**: Checks `AnalyticsScreen` (Placeholder) or `JournalScreen`.
