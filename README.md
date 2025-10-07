# Service Tracker

A Flutter application for tracking car services and maintenance schedules.

## Features

- Track service events with date, mileage, location, and items
- **GPS location support** - automatically detect current city/location
- Register current mileage readings
- Set up service reminders based on time and/or mileage
- Manage service items (predefined and custom)
- Bilingual support (English and Hungarian)
- Manual language switching
- Metric units only
- Single car support

## Technical Stack

- **Framework**: Flutter/Dart
- **State Management**: Provider
- **Storage**: JSON files (human-readable)
- **Internationalization**: flutter_localizations with English and Hungarian

## Getting Started

1. Install Flutter SDK
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # Business logic and storage
├── providers/                # State management
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
├── l10n/                     # Internationalization
└── constants/                # Constants and defaults
```

## Storage

Data is stored in JSON format in the application's document directory for easy backup and portability.

