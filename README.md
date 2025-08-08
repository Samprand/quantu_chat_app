# Flutter Chat App

A Flutter chat application built with **Clean Architecture** and **BLoC pattern**, featuring a modern UI powered by flutter_chat_ui.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                   # Core functionality
│   ├── constants/         # App constants
│   ├── di/               # Dependency injection
│   ├── errors/           # Error handling
│   ├── usecases/         # Base use case classes
│   └── utils/            # Utility functions
├── data/                  # Data layer
│   ├── datasources/      # Remote & local data sources
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
├── domain/               # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic
└── presentation/         # Presentation layer
    ├── bloc/            # BLoC state management
    ├── pages/           # UI screens
    └── widgets/         # Reusable widgets
```

## 🚀 Features

- **Real-time messaging** with simulated backend
- **Clean Architecture** with layer separation
- **BLoC pattern** for state management
- **Modern UI** using flutter_chat_ui
- **Message search** functionality
- **Message actions** (copy, delete)
- **Offline support** with local caching
- **Error handling** with user feedback
- **Dependency injection** with get_it

## 📦 Dependencies

### Core Dependencies
- `flutter_chat_ui: ^1.6.15` - Chat UI components
- `flutter_chat_types: ^3.6.2` - Type definitions for chat
- `flutter_bloc: ^8.1.3` - State management
- `get_it: ^7.6.4` - Dependency injection
- `dartz: ^0.10.1` - Functional programming
- `equatable: ^2.0.5` - Value equality
- `uuid: ^4.2.1` - Unique ID generation

## 🎯 Getting Started

### Prerequisites
- Flutter SDK 3.5.2 or higher
- Dart SDK 3.5.2 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd flutter_chat_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Architecture Details

### 1. **Core Layer**
- Contains shared functionality used across all layers
- Defines error types, use cases, and dependency injection
- Utilities for date formatting and common operations

### 2. **Domain Layer**
- Pure Dart code with business logic
- Entities define the core data structures
- Use cases contain specific business operations
- Repository interfaces define data contracts

### 3. **Data Layer**
- Implements domain repository interfaces
- Handles data from remote APIs and local storage
- Contains data models with JSON serialization
- Manages caching and offline functionality

### 4. **Presentation Layer**
- Contains UI components and state management
- BLoC pattern for reactive state management
- Separates UI logic from business logic
- Handles user interactions and navigation

## 🎨 UI Components

The app uses `flutter_chat_ui` for a professional chat interface:

- **Message bubbles** with sender information
- **User avatars** and names
- **Message timestamps** with smart formatting
- **Typing indicators** and message status
- **Long-press actions** for message options
- **Search functionality** with highlighting

## 📱 Features in Detail

### Real-time Messaging
- Send and receive messages in real-time
- Simulated backend with mock users
- Optimistic UI updates for smooth UX

### Message Management
- Search through message history
- Copy message content
- Delete own messages
- Mark messages as read

### Offline Support
- Local message caching
- Graceful handling of network issues
- Retry mechanisms for failed operations

### Error Handling
- User-friendly error messages
- Retry buttons for failed operations
- Graceful degradation when offline

## 🧪 Testing

The architecture is designed for easy testing:

```bash
# Run unit tests
flutter test

# Run integration tests (if available)
flutter drive --target=test_driver/app.dart
```

## 🔄 State Management

The app uses **BLoC pattern** for state management:

- **Events** represent user actions
- **States** represent UI states
- **BLoC** handles business logic and state transitions
- **Repository** pattern for data access

## 🛠️ Development

### Adding New Features

1. **Define entities** in the domain layer
2. **Create use cases** for business logic
3. **Implement repository** methods
4. **Add BLoC events/states** for UI
5. **Create UI components** in presentation layer

### Code Style

- Follow Dart naming conventions
- Use meaningful class and variable names
- Add documentation for public APIs
- Implement proper error handling

## 📊 Project Status

- ✅ Clean Architecture implementation
- ✅ BLoC state management
- ✅ Modern chat UI
- ✅ Real-time messaging simulation
- ✅ Local caching
- ✅ Error handling
- ⏳ File/image sharing (future)
- ⏳ Push notifications (future)
- ⏳ Multiple chat rooms (future)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Built with ❤️ using Flutter and Clean Architecture principles.
