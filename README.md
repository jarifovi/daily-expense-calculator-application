# 🌌 Gravity Tracker

> **A Next-Gen, Interactive 3D Daily Expense Calculator & Budgeting Suite**
> Built with Flutter, Firebase Auth, and Cloud Firestore. Featuring a physical 3D "Gravity" card UI, neon-accented dark aesthetics, and isolated multi-user data scoping.

---

## ✨ Features

### 1. 🌌 Physics-Based "Gravity" 3D UI
* **3D Tilt Cards:** Interactive mouse tracking translates cursor hover into responsive 3D card tilt transformations.
* **Dynamic Neon Glows:** Shift shadows and glowing borders react dynamically to your mouse position and direction.
* **Micro-Animations:** Fluid floating, hover scale-up, and breathing visual indicators for a premium, alive interface.
* **Smooth Kinetic Scrolling:** Configured custom touch-like drag scroll physics for desktop browsers, trackpads, and mobile screens alike.

### 2. 🔐 Modern Firebase Authentication & Session Tracking
* **Individual Accounts:** Secure registration and login flows connecting directly to Firebase Auth.
* **Session Auditing:** Automatically logs `online` status, `createdAt`, and live timestamps (`lastLoginAt` / `lastLogoutAt`) in Cloud Firestore.
* **Clean Configuration Safety:** Elegant configuration checks translate error codes into helpful user feedback.

### 3. 🛡️ Strict Individual Data Scoping (Private silos)
* **Zero Shared Data Leaks:** Expense lists, transaction history, and custom budget limits are strictly bound to the authenticated user's ID (`UID`).
* **Real-time Synchronization:** List streams immediately filter, update, and persist changes across multi-tenant sessions in real time.

---

## 🎨 Theme & Typography
* **Primary Theme:** Modern dark theme utilizing sleek slate-greys (`#121212`), high-contrast neon greens (`#4CAF50`), and deep warning/info states.
* **Typography:** Premium modern font rendering powered by Google Fonts `Poppins`.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (version `^3.11.4` or newer)
* Dart SDK
* Firebase project credentials (configured inside `lib/firebase_options.dart`)

### Installation & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/jarifovi/daily-expense-calculator-application.git
   ```
2. Navigate to the project directory:
   ```bash
   cd daily-expense-calculator-application
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Build and run locally:
   ```bash
   flutter run
   ```

---

## 📂 Project Structure
```text
lib/
├── models/         # Data blueprints (Expense, Budget, User status)
├── providers/      # Application states (Auth, Expense, Budget, Theme)
├── screens/        # Application views (Auth wrapper, Dashboard, Details, Forms)
├── services/       # Database & API connectors (Auth, Firestore helper)
├── utils/          # Design system variables (AppTheme, AppConstants)
└── widgets/        # Reusable components (GravityTiltCard, ExpenseCard, BudgetStatusCard)
```

---

## 🛠️ Technology Stack
* **Framework:** Flutter (Web / Android / iOS / Desktop)
* **Language:** Dart
* **Authentication:** Firebase Authentication
* **Database:** Google Cloud Firestore (NoSQL)
* **State Management:** Provider
* **Charts:** FL Chart

---

## 👤 Author & Creator

* **Developer & Maintainer:** [jarifovi](https://github.com/jarifovi)

This application is fully designed, built, and maintained by **jarifovi**. If you download, fork, clone, or build upon this project, you must retain this credit and link back to the original author.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

