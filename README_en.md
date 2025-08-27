<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://edsuite.pe/assets/images/logo-dark.png" width="200" alt="Nest Logo" /></a>
</p>
 

  <p align="center">Edsuite Application Documentation</p>
    <p align="center">

## EDSUITE

## 🎯 Description
Official application developed in Flutter as part of the **Escienza** technology platform.

## 🚀 Quick Start

### Prerequisites
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code

### Installation
```bash
# Clone the repository
git clone <repository-url>

# Install dependencies
flutter pub get

# Configure environment variables (copy from .env_dev.json and .env.json)
# Set up env_dev.json and env.json according to your environment

# Run in development
flutter run --dart-define-from-file=env_dev.json

# Run in production
flutter run --dart-define-from-file=env.json
```

## 📱 Main Features

### ⚙️ Initial Setup
- Server connection via custom IP
- Activation code validation
- Dynamic access according to service type:
1. 🟢 Self-Service (Cashkeeper)
2. 🟣 Point of Sale (Niubiz)

### 🔐 Authentication and Security
- Credential validation in Niubiz with user code
- Secure session and state management
- Real-time data protection

### 🛠️ Self-Service Module (Cashkeeper)
- Direct payment at self-service terminal
- Cashkeeper integration for cash payments
- Fast and secure operations without staff intervention

### 💳 Point of Sale Module (Niubiz)
- Login with Niubiz user
- Payment processing with Niubiz POS Web
- Optimized flow for app service

## 🏗️ Architecture

### Design Patterns
- **Domain Driven Design**: Clear separation of responsibilities
- **BLoC Pattern**: Predictable state management
- **Repository Pattern**: Data source abstraction

### Package Structure
```
packages/
├── edsuite_common/     # Shared widgets and utilities
└── niubiz/  # Niubiz client
```

### Technical Features
- Modular package structure for better maintainability
- Niubiz client with channel management
- Robust error handling

## 📚 Documentation

### 📖 Development Guides
- [Development Setup](docs/DEVELOPMENT_SETUP.md)
- [System Architecture](docs/ARCHITECTURE.md)

### 🔧 Features
- [Self-Service](docs/features/documents/DOCUMENTS_MODULE.md)
- [Point of Sale](docs/features/user_management/USER_MANAGEMENT.md)

## 🛠️ Useful Commands

```bash
# Create a package
flutter create --template=package package_name

# Development
flutter run --dart-define-from-file=env_dev.json

# Production
flutter run --dart-define-from-file=env.json

# Tests
flutter test

# Build for Android
flutter build apk --dart-define-from-file=env.json

# Build for iOS
flutter build ios --dart-define-from-file=env.json

# Code analysis
flutter analyze

# Format code
dart format .
```

## 🎨 Resources

### Fonts
- **Brunson**: Main project font
- **Mosvita Sans Serif**: Secondary font (Regular, Bold, Light, SemiBold)

### Icons
- Main icon: `assets/icons/escienza_icon.png`

## 🤝 Contributors

- 🧑‍💻 Hugo Grados Changanaqui – Full Stack Developer
- 🧑‍💻 Diego Silva Carrión – Full Stack Developer
- 🏢 Escienza Team – Engineering & Technology

## 📄 License

This project is under a **private** license. All rights reserved to Escienza E.I.R.L.
