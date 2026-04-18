# Change Life App 🚀

A comprehensive lifestyle management application built with **Flutter**, designed to help users track habits, maintain nutrition, manage goals, and schedule workouts all in one seamless experience.

## ✨ Features

- **Habit Tracking (`/habit`)**: Build positive routines, check off daily tasks, and track your streaks.
- **Nutrition Management (`/nutrition`)**: Fetch and display nutritional info from REST APIs with blazing fast local caching.
- **Goal Setting (`/goal`)**: Define and monitor your long-term and short-term life goals.
- **Workout Planner (`/workout`)**: Keep an organized schedule of your physical activities.
- **Secure Authentication Flow**: A fully functional mock token-based login flow keeping your data private.
- **Settings & Theme Control**: Full support for Dark/Light mode and personalized profiles.
- **Offline First**: The app will never leave you hanging when the internet drops. Data is intelligently cached locally.

## 🏗 Architecture

This project strictly adheres to the **MVVM (Model-View-ViewModel)** architectural pattern, ensuring a clean, scalable, and highly maintainable codebase:
- **Models**: Plain Dart objects with serialization capabilities (JSON/Hive).
- **ViewModels**: Orchestrators handling all business logic, executing async operations, and managing state reactivity seamlessly without dirtying the UI layer.
- **Views**: Purely declarative, stateless UI components observing `ViewModels` reactively.
- **Services**: Dedicated classes to handle direct external interactions (e.g., HTTP requests, persistent local database via Hive).

We also strictly follow a feature-first nested folder structure for maximum scalability.

## 🛠 Tech Stack Used

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Riverpod 2.x](https://riverpod.dev/) (`AsyncNotifier`, `Provider`, Derived States)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Nested ShellRoutes, Param passing, Router Guards/Redirects)
- **Local Storage (Persistence)**: [Hive](https://pub.dev/packages/hive) (Blazing fast NoSQL database for Dart)
- **Networking/API**: `http` (Configured with standard RESTful fetching)
- **Code Generation**: `build_runner` with `hive_generator`

## 🚀 Getting Started

1. Clone the repository
2. Fetch dependencies: 
   ```bash
   flutter pub get
   ```
3. Generate Hive Adapters (If modifying Models):
   ```bash
   dart run build_runner build -d
   ```
4. Run the app:
   ```bash
   flutter run
   ```
