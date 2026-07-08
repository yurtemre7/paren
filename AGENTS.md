# AGENTS.md

## 1. Project Overview
`paren` is a Flutter app for currency conversion and trip expense management. The architecture relies on GetX for state management. For a high-level overview, see `PROJECT.md`. For a detailed technical breakdown, consult `ARCHITECTURE.md`.

## 2. Core Principles
- **Efficiency is key.** Your primary goal is to implement changes surgically and efficiently.
- **Be autonomous.** Use the commands and conventions documented here to work independently.
- **Clarity over cleverness.** Write readable code that aligns with existing patterns.
- **Validate your work.** Use the provided testing and analysis commands to ensure changes are correct and regression-free.

## 3. Environment Setup
All commands must be prefixed with `fvm` to ensure the correct Flutter version is used. Start here:

```bash
fvm flutter pub get
```

## 4. Development Workflow
Execute these commands from the project root.

### Formatting
Ensure all code is formatted before committing.

```bash
fvm dart format .
```

### Static Analysis
Run the analyzer to catch issues early. This is the source of truth for code style and quality.

```bash
fvm flutter analyze
```

### Code Generation
The project uses `json_serializable` for data models and `flutter_localizations` for L10n.
- After modifying files in `lib/classes/` with `@JsonSerializable()` annotations, run:
  ```bash
  fvm dart run build_runner build --delete-conflicting-outputs
  ```
- After modifying `.arb` files in `lib/l10n/`, Flutter's build system will typically handle regeneration automatically on the next app build. To trigger it manually if needed:
  ```bash
  fvm flutter gen-l10n
  ```

### Testing
Run unit and widget tests to verify behavior. **Do not run integration tests**, as per project guidelines. The following command correctly excludes them by default.

```bash
fvm flutter test
```

## 5. Codebase Reference
- **Entrypoint**: `lib/main.dart`
- **State Management/Logic**: `lib/providers/` (GetX)
- **Data Models**: `lib/classes/` (JSON Serializable)
- **UI Components**: `lib/components/` & `lib/screens/`
- **Localization**: `lib/l10n/` (`.arb` files)
- **Platform Config**: `android/`, `ios/`, `macos/`, etc.
- **Release Scripts**: `release-*.sh` files at the project root automate release processes. For a detailed guide on the release process, see `RELEASE.md`.
  - `release-android.sh`: Builds a release `.aab` for Android and uploads it via Fastlane.
  - `release-ios.sh`: Builds a release build for iOS, uploads it via Fastlane, and commits the version bump.
  - `release-github-darwin.sh`: Builds and packages macOS (`.zip`) and iOS (`.ipa`) apps and uploads them to a GitHub release.
  - `release-emre.sh`: Interactive script to run other release scripts (Android, iOS).
