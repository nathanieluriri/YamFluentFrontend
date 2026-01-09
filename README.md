# yam_fluent

YamFluent is a Flutter app for speaking practice. It guides learners through short breathing warmups, AI conversation prompts, audio playback for pronunciation, and per-turn fluency scoring.

## Highlights
- Guided AI conversation flow with pronunciation playback and scoring
- Breathing warmup before sessions
- Practice history and session feedback summaries
- Custom UI widgets and animations

## Feature Architecture
The app is organized by feature, with each feature owning its data, domain, and presentation layers:
- `data/` handles API clients, DTOs (data transfer objects), and storage adapters
- `domain/` defines entities (core business models) and use cases (application actions)
- `presentation/` contains screens, controllers, and UI-specific logic

This layout keeps UI concerns separate from business logic and data access, making each feature easier to reason about and test.

## Tech Stack
- Flutter (Dart)
- Riverpod for state management
- GoRouter for navigation
- Dio for API networking
- Hive for local storage

## Project Structure
- `lib/src/features/` - Feature modules (ai_conversation, breathing_exercise, feedback, practice_history, etc.)
- `lib/ui/widgets/` - Shared UI components used across features
- `assets/` - Images, icons, animations, backgrounds
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` - Platform shells

## Requirements
- Flutter SDK (see `pubspec.yaml` for the Dart SDK constraint)
- A running backend API that provides session creation, session listing, and audio analysis endpoints
- OAuth / auth provider configuration for sign-in

## Setup
```bash
flutter pub get
```

## Run (Debug)
```bash
flutter run
```

## Run (Web)
```bash
flutter run -d chrome
```

## Run (Release)
```bash
flutter run --release
```

## Build (Release)
```bash
flutter build apk
flutter build ios
flutter build web
```

## Notes
- The conversation flow relies on backend APIs for session creation and scoring.
- Audio recording requires microphone permissions on the target platform.
- Web builds require HTTPS (or localhost) for microphone access.

## Glossary
- DTO (Data Transfer Object): A simple data shape used to move data between the API and the app.
- Entity: A core business model used by the app logic.
- Use case: A single app action (e.g., “start conversation session”).
- Controller: Presentation-layer logic that coordinates UI state and user actions.

## License
Proprietary. All rights reserved.
