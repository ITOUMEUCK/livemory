# Copilot Instructions for Mobile App

## Project Overview
This is a Flutter mobile application named "mobile" (part of the livemory project) targeting Android, iOS, Linux, macOS, Windows, and web platforms. It's currently a starter project with minimal custom code beyond the Flutter template.

## Tech Stack
- **Framework**: Flutter SDK ^3.10.4
- **Language**: Dart
- **Build System**: Gradle (Kotlin DSL) for Android
- **Android Config**: namespace `com.example.mobile`, compileSdk from Flutter, Java 17
- **Linting**: `flutter_lints` ^6.0.0 with default ruleset

## Project Structure
- `lib/main.dart` - Single entry point with StatefulWidget counter demo
- `android/` - Android-specific native code (Kotlin DSL, namespace: com.example.mobile)
- `ios/` - iOS-specific native code (Swift)
- `test/` - Widget tests
- `analysis_options.yaml` - Dart analyzer configuration (uses `package:flutter_lints/flutter.yaml`)

## Key Workflows

### Running the App
```bash
flutter run              # Run on connected device
flutter run -d chrome    # Run on Chrome (web)
flutter run -d windows   # Run on Windows desktop
```

### Development Commands
```bash
flutter pub get          # Install dependencies after pubspec.yaml changes
flutter analyze          # Static analysis (uses analysis_options.yaml)
flutter test             # Run tests
flutter pub upgrade      # Update dependencies
```

### Hot Reload & Hot Restart
- **Hot Reload** (save file or `r`): Apply code changes without losing state
- **Hot Restart** (`R`): Reset app state completely

## Code Conventions

### Widget Structure
- Use `const` constructors wherever possible for better performance
- StatefulWidget pattern: `MyWidget` class + `_MyWidgetState` private class
- Always use `super.key` in widget constructors

### State Management
- Use `setState()` for local widget state changes
- Counter example in [lib/main.dart](lib/main.dart) demonstrates the standard pattern

### Theming
- Theme defined in `MaterialApp` using `ColorScheme.fromSeed()`
- Access theme via `Theme.of(context)` (e.g., `Theme.of(context).colorScheme.inversePrimary`)

### Linting
- Uses `flutter_lints` package (strict superset of Dart recommended lints)
- Suppress individual lints with `// ignore: rule_name` or `// ignore_for_file: rule_name`
- Run `flutter analyze` to check for violations before committing

## Platform-Specific Notes

### Android
- Uses Kotlin DSL for Gradle (`.gradle.kts` files)
- Build output redirected to `../../build` (shared monorepo build directory)
- Default package: `com.example.mobile` (should be changed for production)

### iOS
- Swift-based with Objective-C bridging support
- AppDelegate pattern for lifecycle management

## Important Patterns
- No custom dependencies yet beyond `cupertino_icons` - keep dependency additions minimal
- All platforms enabled but likely targeting mobile first (Android/iOS)
- Standard Flutter project structure - follow Flutter conventions documented at https://docs.flutter.dev/
