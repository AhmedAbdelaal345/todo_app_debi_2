# Flutter Todo App

This is a Flutter-based Todo application developed as part of a DEPI internship. The app allows users to manage their tasks, utilizing `shared_preferences` for local data persistence and `flutter_bloc` (Cubit) for state management. It features a clean, animated user interface for an engaging user experience.




## Features

*   **User-Specific Todo Lists:** Tasks are managed per user, with data persistence handled via `shared_preferences`.
*   **Add, Edit, Delete Todos:** Full CRUD (Create, Read, Update, Delete) functionality for managing tasks.
*   **Toggle Todo Status:** Mark tasks as complete or incomplete.
*   **Filtering Todos:** Search functionality to filter tasks by title or description.
*   **State Management with Cubit:** Efficient and predictable state management using `flutter_bloc`.
*   **Animated User Interface:** Smooth and engaging animations for a better user experience, particularly in the login and todo listing pages.
*   **Login Page:** A dedicated login page with email validation and animated elements.
*   **Splash Screen:** (Implied by `splach_page.dart`)
*   **Profile Page:** (Implied by `profile_page.dart`)
*   **Details Page:** (Implied by `details_page.dart` for viewing/editing todo details)




## Technologies Used

*   **Flutter:** Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Dart:** The programming language used for Flutter development.
*   **`flutter_bloc` (Cubit):** A predictable state management library that helps implement the BLoC (Business Logic Component) pattern. Cubit is a simpler variant of BLoC.
*   **`shared_preferences`:** A Flutter plugin for reading and writing simple key-value pairs to persistent storage (NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.). This is used for user-specific data persistence.
*   **`flutter_animate`:** A package for easily adding animations to Flutter widgets.
*   **`fluttertoast`:** A plugin for showing toast messages (temporary notifications) in Flutter applications.




## Project Structure

The project follows a standard Flutter project structure with a clear separation of concerns:

```
lib/
├── cubit/              # Contains Cubit logic and state definitions
│   ├── todo_cubit.dart   # Business logic for todo operations
│   └── todo_state.dart   # State definitions for TodoCubit
├── model/              # Data models
│   └── todo_model.dart   # Defines the TodoModel class
├── pages/              # UI pages/screens of the application
│   ├── details_page.dart # Page to view/edit individual todo details
│   ├── login_page.dart   # User login screen with animations
│   ├── profile_page.dart # User profile page
│   ├── splach_page.dart  # Splash screen
│   ├── todo_page.dart    # Main todo list display and management
│   └── wrapper_page.dart # Handles navigation after login
├── utils/              # Utility functions and constants
│   ├── constants.dart    # Application-wide constants
│   ├── show_dialog_widget.dart # Reusable dialog for adding/editing todos
│   └── show_logout_widget.dart # Reusable dialog for logout confirmation
└── main.dart           # Entry point of the application
```




## How to Run

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK installed (version 3.0.0 or higher)
*   Dart SDK installed
*   A code editor like VS Code or Android Studio with Flutter and Dart plugins.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/AhmedAbdelaal345/todo_app_debi_2.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd todo_app_debi_2
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

    The app should launch on your connected device or emulator.




## Screenshots

### Login Page

![Login Page](https://raw.githubusercontent.com/AhmedAbdelaal345/todo_app_debi_2/main/assets/screenshot/1.png)




### Todo List (Empty State)

![Todo List (Empty State)](https://raw.githubusercontent.com/AhmedAbdelaal345/todo_app_debi_2/main/assets/screenshot/2.png)




### Todo Details Page

![Todo Details Page](https://raw.githubusercontent.com/AhmedAbdelaal345/todo_app_debi_2/main/assets/screenshot/3.png)




### Todo List (with a task)

![Todo List (with a task)](https://raw.githubusercontent.com/AhmedAbdelaal345/todo_app_debi_2/main/assets/screenshot/4.png)




### Profile Page

![Profile Page](https://raw.githubusercontent.com/AhmedAbdelaal345/todo_app_debi_2/main/assets/screenshot/5.png)


