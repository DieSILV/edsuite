# Development Setup

## 📋 Prerequisites

### Required Software
- **Flutter SDK**: 3.x or higher
- **Dart SDK**: 3.x or higher
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Git**: For version control

### Additional Tools
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)
- **Chrome**: For web development

## ⚙️ Initial Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
```

### 2. Install Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# Verify installation
flutter doctor
```

### 3. Configure Environment Variables

The project uses configuration files for different environments:

#### Development (`env_dev.json`)
```json
{
    "ENV": "dev",
    "BASE_URL": "http://XXXX/"
}
```

#### Production (`env.json`)
```json
{
    "ENV": "prod",
    "BASE_URL": "https://app.silcadev.com/"
}
```

### 4. IDE Setup

#### VS Code
Recommended extensions:
- **Flutter**: Full support for Flutter
- **Dart**: Support for Dart
- **Bloc**: Snippets for BLoC pattern

#### Android Studio
Recommended plugins:
- **Flutter Plugin**
- **Dart Plugin**
- **Bloc Plugin**

## 🏃‍♂️ Development Commands

### Run the Application
```bash
# Development
flutter run --dart-define-from-file=env_dev.json

# Production
flutter run --dart-define-from-file=env.json

# With specific device
flutter run -d <device-id> --dart-define-from-file=env_dev.json

# Automatic hot reload
flutter run --hot
```

### Testing
```bash
# Run all tests
flutter test

# Tests with coverage
flutter test --coverage

### Build and Deployment
```bash
# Build for Android (APK)
flutter build apk --dart-define-from-file=env.json

# Build for Android (AAB)
flutter build appbundle --dart-define-from-file=env.json

# Build for iOS
flutter build ios --dart-define-from-file=env.json

# Build for Web
flutter build web --dart-define-from-file=env.json
```

### Code Analysis and Quality
```bash
# Static analysis
flutter analyze

# Format code
dart format .

# Automatic fix of issues
dart fix --apply
```

## 🔧 Debugging Setup

### Debug in VS Code
Create a `.vscode/launch.json` file:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch development",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--dart-define-from-file",
                "env_dev.json"
            ]
        },
        {
            "name": "Launch production",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--dart-define-from-file",
                "env.json"
            ]
        }
    ]
}
```

## 🎯 Development Workflow

### 1. Create New Feature
```bash
# Create feature branch
git checkout -b feature/new-feature

# Create basic structure
mkdir lib/features/new_feature
mkdir lib/features/new_feature/presentation
mkdir lib/features/new_feature/domain
mkdir lib/features/new_feature/data
```

### 2. Implement according to Clean Architecture
1. **Domain**: Entities, use cases, repositories (interfaces)
2. **Data**: Repository implementations, models, datasources
3. **Presentation**: BLoCs, pages, widgets

### 3. Testing
1. Write unit tests for use cases
2. Integration tests for repositories
3. Widget tests for UI

### 4. Documentation
1. Update feature documentation
2. Add JSDoc/DartDoc comments
3. Update README if necessary

## 🐛 Troubleshooting

### Common Issues

#### Dependency Errors
```bash
# Clean cache
flutter clean
flutter pub get

# Update dependencies
flutter pub upgrade
```

#### Build Issues
```bash
# Clean build
flutter clean

# Full rebuild
flutter pub get
flutter build <platform>
```

#### Hot Reload Issues
```bash
# Full restart
flutter run --hot
# Press 'R' for hot restart
```

### Debug Variables
```bash
# Verbose output
flutter run --verbose

# Performance debug
flutter run --profile

# Memory analysis
flutter run --enable-memory-profiling
```

## 🔒 Security Setup

### Secrets Management
- Never commit configuration files with sensitive data
- Use environment variables for API keys
- Implement obfuscation for production builds


## 🤝 Best Practices

### Code
1. Follow Dart/Flutter conventions
2. Use static analysis (flutter analyze)
3. Maintain test coverage > 80%
4. Document public APIs

### Git
1. Descriptive and atomic commits
2. Use conventional commits
3. Mandatory review before merge
4. Tests passing before merge

### Performance
1. Use `const` constructors when possible
2. Avoid unnecessary rebuilds
3. Optimize images and assets
4. Monitor memory and CPU