# Flutter Mini Project 📱

A beginner-friendly **Flutter learning project** designed to demonstrate core Flutter concepts and best practices through a practical mini application.

## 🎯 Purpose

This project is created for **learning and practicing Flutter development**. It covers essential topics including:
- Authentication with Supabase
- Navigation using GoRouter
- Android development
- Feature-based project structure
- Environment configuration with flutter_dotenv


## 📦 What's Inside

### Features
- **Auth Module**: User authentication with Supabase and Google Sign-In
- **Home Module**: Main application dashboard
- **Profile Module**: User profile management
- **Settings Module**: Application settings

### Architecture
- **Feature-based structure**: Organized by features (auth, home, profile, settings)
- **Shared components**: Common UI elements and shell layout
- **Router setup**: Declarative navigation with GoRouter

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.11.4 or higher)
- Dart SDK
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/binoydipu/flutter-mini-project
   cd flutter-mini-project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment variables**
   - Create a `.env` file in the project root
   - Add your Supabase URL and API key:
     ```
     see .env.example for reference
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📚 Key Technologies

| Technology | Purpose |
|-----------|---------|
| **Flutter** | UI framework for cross-platform development |
| **Supabase** | Backend for authentication and data storage |
| **GoRouter** | Type-safe routing and navigation |
| **Google Sign-In** | OAuth authentication integration |
| **flutter_dotenv** | Environment configuration management |
| **Flutter Spinkit** | Loading indicators |

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── core/
│   ├── constants/         # App-wide constants
│   ├── router/            # Navigation configuration (GoRouter)
│   └── theme/             # Theme and styling
├── features/
│   ├── auth/              # Authentication feature
│   ├── home/              # Home/Dashboard feature
│   ├── profile/           # User profile feature
│   └── settings/          # Settings feature
└── shared/
    └── main_shell.dart    # Main app shell layout
```

## 🎓 Learning Topics Covered

- ✅ State management patterns
- ✅ Navigation and routing
- ✅ Authentication flows
- ✅ API integration
- ✅ Environment configuration
- ✅ Multi-platform development
- ✅ Widget composition
- ✅ Error handling


## 📝 Notes for Learners

This project is **intentionally kept simple** to focus on core Flutter concepts. As you progress, consider:
- Adding state management solutions (Provider, Riverpod, BLoC)
- Adding unit and widget tests
- Exploring advanced navigation patterns
- Integrating additional features (e.g., notifications, real-time updates)

## 🤝 Contributing

Since this is a learning project, feel free to:
- Experiment with different approaches
- Add new features
- Refactor and improve code quality
- Document your learning process

## 📄 License

This project is free to use for educational purposes.

---

**Happy Learning! 🚀**