<p align="center">
  <img src="assets/image/iconApp.png" alt="Todo App Logo" width="120"/> 
</p>

<h1 align="center">✅ Flutter Todo App (DEPI Task)</h1>
<p align="center">A cross-platform Todo Application built with Flutter</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter Badge"/>
  <img src="https://img.shields.io/badge/State-Bloc-green" alt="Bloc Badge"/>
  <img src="https://img.shields.io/badge/Storage-Shared%20Preferences-yellow" alt="SharedPreferences Badge"/>
  <img src="https://img.shields.io/badge/License-MIT-red" alt="License Badge"/>
</p>

---

## 📌 Overview
This is a Flutter-based Todo application developed as part of a **DEPI internship**.  
The app allows users to manage their tasks, utilizing `shared_preferences` for local data persistence and `flutter_bloc` (Cubit) for state management.  
It features a clean, animated user interface for an engaging user experience.

---

## ✨ Features

| Feature                  | Description |
|---------------------------|-------------|
| 👤 **User-Specific Todos** | Each user has their own task list (saved with `shared_preferences`). |
| ➕ **Add / Edit / Delete** | Full CRUD functionality for todos. |
| ✅ **Toggle Status**       | Mark tasks as complete or incomplete. |
| 🔍 **Search & Filter**     | Filter tasks by title or description. |
| 🌀 **Animated UI**         | Smooth animations on login and todo pages. |
| 🔑 **Login Page**          | With email validation and animations. |
| 👤 **Profile Page**        | Manage user profile. |
| 🕒 **Splash Screen**       | Startup splash experience. |

---

## 🛠️ Technologies Used

- **Flutter:** Google's UI toolkit for cross-platform apps.
- **Dart:** Programming language for Flutter development.
- **`flutter_bloc` (Cubit):** Predictable state management.
- **`shared_preferences`:** Local key-value storage.
- **`flutter_animate`:** Easy animations for widgets.
- **`fluttertoast`:** Toast notifications.

---

## 📂 Project Structure

lib/
├── cubit/ # Cubit logic & states
│ ├── todo_cubit.dart
│ └── todo_state.dart
├── model/ # Data models
│ └── todo_model.dart
├── pages/ # UI Screens
│ ├── details_page.dart
│ ├── login_page.dart
│ ├── profile_page.dart
│ ├── splach_page.dart
│ ├── todo_page.dart
│ └── wrapper_page.dart
├── utils/ # Utilities
│ ├── constants.dart
│ ├── show_dialog_widget.dart
│ └── show_logout_widget.dart
└── main.dart # App entry point

yaml
Copy code

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK (3.0.0+)
- Dart SDK
- VS Code / Android Studio with Flutter plugin

### Installation
```bash
# Clone repository
git clone https://github.com/AhmedAbdelaal345/todo_app_debi_2.git

# Navigate to folder
cd todo_app_debi_2

# Install dependencies
flutter pub get

# Run app
flutter run
📸 Screenshots
🔑 Login Page


📋 Todo List (Empty)


📄 Todo Details Page


✅ Todo List (with a Task)


👤 Profile Page


📜 License
This project is licensed under the MIT License.

yaml
Copy code
