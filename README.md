# local_auth_demo

A small Flutter demo that shows how to use device authentication (biometrics / OS-provided authentication) to protect access to a simple app. This project demonstrates using the `local_auth` plugin to check for biometric availability, list available biometric types, and authenticate the user using the platform's authentication mechanisms.

## What this project contains

- `lib/main.dart` - App entry point.
- `lib/login_page.dart` - Login UI that wraps `local_auth` usage: checks support, lists biometrics, and performs authentication calls.
- `lib/home_page.dart` - Simple home screen that the app can navigate to after successful authentication.

## Features

- Detect whether the device supports local authentication.
- Query available biometric types (fingerprint, face, etc.).
- Authenticate using the OS authentication dialog (biometric or device credential).
- Demonstrates handling of authentication states and errors.

## Dependencies

This project uses Flutter and the following package(s) declared in `pubspec.yaml`:

- `flutter` (SDK) — Flutter framework.
- `local_auth: ^3.0.0` — Plugin to perform local device authentication (biometrics / device credentials).

Developer dependencies:

- `flutter_test` — Flutter test framework for unit/widget tests.
- `flutter_lints` — Lint rules for Flutter projects.

For the exact versions, see `pubspec.yaml` in the project root.

## How to run

1. Make sure you have Flutter installed and configured. See https://flutter.dev for setup instructions.
2. From the project root run:

```bash
flutter pub get
flutter run
```

Run on a real device or an emulator/simulator that supports biometrics if you want to test fingerprint/Face ID flows.

## Platform notes

- iOS: to use Face ID you must add a usage description to your `Info.plist` (for example, `NSFaceIDUsageDescription`) — see the `local_auth` package documentation for details and any other required configuration.
- Android: follow the `local_auth` plugin documentation for any necessary manifest changes or runtime configuration. Some Android versions require additional setup for biometric prompts.

Always consult the package page (https://pub.dev/packages/local_auth) for the latest platform-specific setup steps.

## Where to add navigation after successful authentication

The app performs authentication inside methods in `lib/login_page.dart`. The recommended place to navigate to the home screen is immediately after you confirm the authentication succeeded and after verifying `mounted == true`. Use `Navigator.pushReplacementNamed(context, '/home')` (if you use named routes) or `Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()))` to replace the login screen so the user cannot return to it with the back button.

## License

This demo is provided as-is for learning purposes. Adapt it to your needs and follow your project's licensing conventions.