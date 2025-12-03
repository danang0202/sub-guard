# 🛡️ Subs Guard

**Subs Guard** is a modern, intelligent subscription tracking application designed to help you manage your recurring expenses and prevent unwanted charges. Built with a sleek **Neo-Modern** aesthetic, it ensures you never miss a payment or forget to cancel a trial.

## ✨ Key Features

*   **📅 Smart Reminders:** Get notified at **07:30**, **12:00**, and **18:00** on key dates (H-7, H-3, H-1, and Payment Day).
*   **🎨 Neo-Modern Design:** A stunning dark-themed UI with glassmorphism effects, ambient glows, and smooth animations.
*   **🔔 Intense Alerts:** Optional full-screen alerts for urgent payments (H-1 and Due Date) to ensure you never miss a beat.
*   **📊 Comprehensive Dashboard:** View monthly costs, upcoming bills, and active subscriptions at a glance.
*   **💾 Local Backup & Restore:** Securely backup your data to a JSON file and restore it anytime.
*   **🔋 Battery Optimization Guide:** Built-in guide to help you whitelist the app from battery optimizations for reliable notifications.
*   **🛠️ Test Notification:** Verify your notification settings instantly with a built-in test feature.

## 🛠️ Tech Stack

*   **Framework:** Flutter (Dart)
*   **State Management:** Riverpod
*   **Local Database:** Hive (NoSQL)
*   **Notifications:** Flutter Local Notifications & Android Alarm Manager Plus
*   **UI/UX:** Custom Neo-Modern Design System (Glassmorphism, Gradients)

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (3.10.0 or higher)
*   Android Studio / VS Code
*   Android SDK (min SDK 21)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/sub-guard.git
    cd sub-guard
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## 📱 Notification Setup (Important)

For notifications to work reliably on Android, especially on devices with aggressive battery management (Xiaomi, Samsung, etc.), please follow the **Battery Optimization** guide inside the app settings:
1.  Go to **Settings** > **System** > **Battery Optimization**.
2.  Follow the instructions for your specific device manufacturer.

## 🎨 Customizing the Logo

To update the app icon:
1.  Place your logo file as `sub-guard-logo.png` in the root directory.
2.  Run:
    ```bash
    flutter pub run flutter_launcher_icons
    ```

---
*Developed with ❤️ using Flutter*
