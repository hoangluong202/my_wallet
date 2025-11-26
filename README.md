# 💰 FinTrack: Your Personal Money Manager

FinTrack is a simple, easy-to-use mobile app built with Flutter. It helps you keep track of all your money coming in and going out. Use it to fully control your finances and see exactly where your money goes.

## ✨ Features

FinTrack helps you track all your money with clear, simple tools.

* **🏦 Manage Different Accounts (Wallets):** Keep track of money in different places like your bank, cash, savings, or credit cards. You can see the balance for each one.

* **➕ Log Everything:** Record four types of records:

  * **Income** (money you receive)

  * **Expense** (money you spend)

  * **Debt** (money you owe to others)

  * **Loan** (money others owe to you)
    Each record includes the amount, date, which wallet it came from, and a category.

* **🏷️ Simple Categories:** Use easy-to-change categories for all your records (Income, Expense, Debt, Loan) to organize your money clearly.

* **📊 Clear Money Reports:** See simple reports to understand your finances:

  * **Monthly Report:** See your total Income versus total Expense each month.

  * **Spending Map:** Charts show you exactly where you spend your money (Expense by Category).

* **📅 History:** Easily look back at all your individual transactions and records. You can choose to view them organized by **day, week, month, or year.**

* **💾 Local-First & Cloud Sync:** Your records are always saved fast and safely on your phone first. Then, they are synced securely to the cloud (Firebase Firestore). This means you can use the app offline, and your data will still stay up-to-date across all your phones and tablets.

## 📂 Project Structure (Layered Architecture)

FinTrack uses a scalable layered architecture to ensure clean separation of concerns. All code is organized within the `lib/` directory following this structure:
### Core Structure

    lib/
    ├── main.dart
    │
    ├── core/                     // App-wide utilities, constants, configurations
    │   ├── constants/            // Colors, text styles, keys
    │   ├── utils/                // Formatters, extensions
    │   ├── theme/                // App theme and styling
    │   ├── router/               // Navigation and routing
    │   └── error/                // Exceptions and failure classes
    │
    └── features/                 // All application features

### Feature Structure

    lib/
    └── features/
        └── [feature_name]/        // e.g., wallets, transactions
            │
            ├── presentation/      // UI Layer
            │   ├── pages/         // Screens
            │   ├── widgets/       // Reusable widgets
            │   └── view_models/   // State management
            │
            ├── domain/            // Business logic
            │   ├── entities/      // Core models
            │   └── use_cases/     // Application use cases
            │
            └── data/              // Data access layer
                ├── models/        // DTOs, drift tables, DAOs
                ├── repositories/  // Repository interfaces & implementations
                └── services/      // Firebase, APIs, local DB sources
