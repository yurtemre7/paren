# ARCHITECTURE.md

This document provides a detailed overview of the `paren` application's architecture. For a higher-level feature overview, see `PROJECT.md`.

## Core Philosophy
The architecture is pragmatic, prioritizing clarity and development speed. It is built on the [GetX](https://pub.dev/packages/get) ecosystem, using its state management, dependency injection, and routing capabilities.

## Folder Structure (`lib`)
The `lib` directory is organized by feature and function.

```
lib/
├── classes/         # Data models (JSON serializable)
├── components/      # Reusable UI widgets used across multiple screens
├── l10n/            # Localization files (.arb)
├── providers/       # Core logic and state management (GetX controllers)
├── screens/         # Top-level UI screens
└── main.dart        # App entry point
```

- **`classes/`**: Contains all Plain Old Dart Objects (PODOs) used for data modeling. These classes are typically annotated with `@JsonSerializable` to generate `*.g.dart` files for serialization.
- **`components/`**: Holds widgets that are self-contained and reused in different parts of the app. Examples include `CalculatorKeyboard` or `CurrencyChangerRow`.
- **`l10n/`**: The source of truth for all user-facing strings, using the `.arb` format for Flutter's localization system.
- **`providers/`**: The heart of the application logic. While named `providers`, this directory contains GetX controllers.
  - `paren.dart` is the main controller, acting as a singleton for global app state.
  - Other files in this directory may contain related logic or extensions.
- **`screens/`**: Contains the main views of the application. These widgets compose the UI using widgets from `lib/components/` and interact with the controllers in `lib/providers/` to display and manipulate state.
- **`main.dart`**: Initializes the app, sets up GetX, loads initial data, and runs the root `GetMaterialApp` widget.

## State Management with GetX
GetX is used as the single source of truth for all application state.

> **Architectural Note**: While a single global controller is simple, the `Paren` controller has become bloated over time. This is largely a result of early development decisions. Future work should focus on refactoring its logic into smaller, feature-specific GetX controllers (e.g., `SheetController`, `SettingsController`). This will improve maintainability and separation of concerns.

### `Paren` Controller
The `Paren` class in `lib/providers/paren.dart` is the primary GetX controller. It is instantiated as a singleton in `main.dart` and can be accessed anywhere in the widget tree via `Get.find<Paren>()`.

It is responsible for managing:
- **API Interaction**: Uses `dio` to fetch currency data from the Frankfurter API.
- **Persistence**: Reads and writes all app settings (favorites, sheets, etc.) to `shared_preferences`.
- **UI State**: Holds the reactive state for the current conversion, selected currencies, theme, and locale. All mutable properties are declared with `.obs` to make them observable.
- **Business Logic**: Contains the methods for managing favorites, sheets, and other core features.

### Reactive UI
The UI is built with a reactive approach. Widgets that need to display or respond to state changes are wrapped in an `Obx(() => ...)` builder. This ensures that the widget will automatically rebuild whenever an observable (`.obs`) variable it depends on changes.

This pattern minimizes boilerplate and avoids the need for `StatefulWidget` in most UI code.

## Data Flow
The data flow is unidirectional, ensuring a predictable and maintainable state.

1.  **Data Source**: Data originates from one of two places:
    - **Remote API**: The Frankfurter API for currency exchange rates.
    - **Local Persistence**: `shared_preferences` for user-generated content like favorites and sheets.

2.  **Controller (`Paren`)**: The `Paren` controller is the sole actor responsible for fetching, caching, and mutating data. It exposes the data to the UI as observable properties.

3.  **UI (Widgets)**: The UI layer is "dumb." It reads data from the `Paren` controller and displays it. User interactions trigger methods on the controller (e.g., `paren.addFavorite()`). The UI **never** modifies state directly.

4.  **Update Cycle**: When a method on the controller updates an observable (`.obs`) property, GetX automatically notifies all listening widgets (those wrapped in `Obx`), which then rebuild to reflect the new state.

## Navigation
The app uses GetX for navigation, leveraging `Get.to()`, `Get.back()`, and `Get.bottomSheet()` for moving between screens and showing dialogs. This approach decouples navigation from the `BuildContext`, allowing it to be called from within controllers.
