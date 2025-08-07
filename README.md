# Agenda App

A cross-platform calendar and agenda application built with Flutter, supporting Android, Web, and Windows platforms.

## Features

- 📅 Calendar view and event management
- 🔐 User authentication
- 📱 Cross-platform support (Android, Web, Windows)
- 🎯 Event tracking and scheduling
- 🏠 Home dashboard
- 🎨 Modern Material Design UI

## Screenshots

![App Screenshot](flutter_01.png)

## Getting Started

### Prerequisites

- Flutter SDK (3.24.3 or later)
- Dart SDK (3.5.3 or later)
- For Android: Android Studio with Android SDK
- For Windows: Visual Studio with C++ tools
- For Web: Chrome browser

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd calendar_app_25
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Configuration

The app supports runtime configuration via Dart defines:

```bash
flutter run --dart-define=TOKEN=your_token_here
```

## Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

## Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
└── src/
    ├── constants.dart        # App constants
    ├── controller/          # Business logic controllers
    │   ├── auth_controller.dart
    │   ├── events_controller.dart
    │   └── home_controller.dart
    ├── extensions/          # Dart extensions
    ├── model/              # Data models
    ├── view/               # UI screens
    └── widgets/            # Reusable UI components
```

## Development

### Code Style
This project follows Dart/Flutter coding conventions. Format your code with:
```bash
dart format .
```

### Static Analysis
Run static analysis:
```bash
flutter analyze
```

## CI/CD

This project includes a GitHub Actions workflow that:
- Runs tests and code analysis
- Builds for Android (APK & AAB)
- Builds for Web
- Builds for Windows
- Uploads build artifacts

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure code quality
5. Submit a pull request

## License

This project is private and not published to pub.dev.
