# save_homework

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

==============================================================
Project Structure
First, you'll need to add the provider package to your pubspec.yaml file:

YAML

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0 # Use the latest version
The file structure should be organized for clarity:

lib/
├── main.dart
├── models/
│   └── submission.dart
├── providers/
│   └── submission_provider.dart
├── screens/
│   ├── input_page.dart
│   └── list_page.dart
└── widgets/
    └── notification_badge.dart