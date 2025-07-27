# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ezer is a church management assistant app for Revive Church, built with Flutter. The app provides a comprehensive platform for church members to access resources, view schedules, join teams, receive updates, and provide feedback through an interactive sanctuary map.

## Development Commands

### Running the Application
- `flutter run` - Run the app in debug mode with hot reload
- `flutter run --release` - Run the app in release mode
- `flutter run -d chrome` - Run in web browser
- `flutter run -d windows` - Run on Windows desktop
- `flutter run -d android` - Run on Android device/emulator
- `flutter run -d ios` - Run on iOS device/simulator

### Dependencies and Setup
- `flutter pub get` - Install dependencies from pubspec.yaml
- `flutter clean` - Clean build artifacts
- `flutter pub upgrade` - Upgrade all dependencies

### Testing
- `flutter test` - Run all unit and widget tests
- `flutter test test/widget_test.dart` - Run specific test file

### Code Quality
- `flutter analyze` - Run static analysis using rules from analysis_options.yaml

### Building
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web app
- `flutter build windows` - Build Windows desktop app

## Architecture

### Navigation & State Management
- **Navigation**: GoRouter for declarative routing with clear route paths (/home, /resources, /schedule, etc.)
- **State Management**: Riverpod for reactive state management across all features
- **Navigation Structure**: ShellRoute with bottom navigation bar for main sections

### Core Features & Screens

#### Main Navigation (Bottom Navigation Bar)
1. **Home** (`/home`) - Personalized dashboard with profile summary, bulletin, latest sermon, recent updates, and upcoming events
2. **Resources** (`/resources`) - Searchable media archive with photos, videos, and audio content
3. **Schedule** (`/schedule`) - Calendar view with event highlights and detailed event information
4. **Teams** (`/teams`) - Split into Connect Groups (application-based) and Hangouts (open events)
5. **Updates** (`/updates`) - Church news and announcements with pinned important updates

#### Authentication Flow
- **Splash Screen** (`/splash`) - App initialization with Supabase setup and loading animation
- **Login Screen** (`/login`) - Email/password authentication with error handling
- **Sign Up Screen** (`/signup`) - Account creation with email verification

#### Additional Features
- **Sanctuary Map** (`/sanctuary-map`) - Interactive 2D map for location sharing and environmental feedback
- **Profile Management** (`/profile`) - User profile and church information
- **Detail Screens** - Individual screens for events, teams, media, updates, and sermons

### Project Structure
```
lib/
├── main.dart                 # App entry point with ProviderScope and routing
├── config/
│   └── supabase_config.dart # Supabase configuration settings
├── services/
│   └── supabase_service.dart # Supabase client and helper methods
├── router/
│   └── app_router.dart      # GoRouter configuration with authentication flow
├── models/                  # Data models (User, Event, MediaItem, Update, Team, Sermon, Bulletin, AuthState)
├── providers/               # Riverpod providers for state management and authentication
├── screens/                 # Authentication, main screens, and detail screens
├── widgets/                 # Reusable UI components
└── themes/                  # App theming (Material 3 with purple color scheme)
```

### Data Models
- **User**: Profile information and church membership details
- **Event**: Calendar events with signup functionality and capacity tracking
- **MediaItem**: Photos, videos, and audio with categorization and collection features
- **Update**: Church announcements with type classification and pinning
- **Team**: Connect Groups (application-based) and Hangouts (open participation)
- **Sermon**: Audio/video sermons with transcripts and metadata
- **Bulletin**: Weekly church bulletin with themed content

### State Management Patterns
- **Provider-based architecture**: Each feature has dedicated providers (eventsProvider, mediaProvider, etc.)
- **Filtered providers**: Computed providers for search, filtering, and categorization
- **State persistence**: Providers maintain state across navigation
- **Reactive UI**: Widgets rebuild automatically when underlying state changes

## Dependencies
- **flutter_riverpod**: State management and dependency injection
- **go_router**: Declarative routing and navigation
- **supabase_flutter**: Backend database and authentication
- **shared_preferences**: Local data persistence
- **table_calendar**: Calendar widget for schedule screen
- **cached_network_image**: Optimized image loading and caching
- **intl**: Internationalization and date formatting
- **cupertino_icons**: iOS-style icons
- **flutter_lints**: Code quality and style enforcement

## Key Design Patterns
- **Repository Pattern**: Providers act as data repositories with mock data
- **Separation of Concerns**: Clear separation between UI, state management, and data models
- **Responsive Design**: Mobile-first approach with adaptive layouts
- **Material Design 3**: Modern UI with consistent theming and components

## Configuration
- **SDK constraint**: Dart ^3.6.1
- **Multi-platform support**: Android, iOS, Web, Windows, macOS, Linux
- **Private package**: publish_to: 'none' prevents accidental publishing
- **Analysis**: Uses package:flutter_lints/flutter.yaml for code quality