# Folder Structure

[[_TOC_]]

## Overview

This folder structure is the product of several iterations, experiments, and lessons learned from earlier architectures. While the tree itself is straightforward, each choice reflects trade-offs and specific problems.

The structure is guided by three principles:

1. **Flat-based:** Avoid unnecessary nesting. Early attempts (with `ui/`, `atomic/`, `composite/`) created extra levels which slows navigation and adds no real value. Flattening the tree keeps things discoverable and prevents over-nested folders.

2. **Feature-based:** Organize by feature, not by technical layer. Previous versions split logic into `core/`, `ui/`, etc. This scattered responsibilities. By grouping UI, logic, and assets inside the same feature, the feature is self-contained and easy to evolve independently making the codebase modular and extensible.

3. **Related-based:** Keep public API at the feature root (e.g., `<Feature>/MapView.qml`, `<Feature>/TracksPanel.qml`). Implementation details (helpers, sub-components, private QML/C++) live in `<Feature>/internals/`. This enforces clear boundaries and prevents accidental cross-feature coupling.

## Structure

```
project-root/
├─ CMakeLists.txt                 # Top-level build orchestration
├─ README.md                      # How to build/run; link to wiki for deep dives
├─ wiki/                          # Architecture notes, decisions (ADR), conventions
├─ translations/                  # Global Qt .ts/.qm shared across features
│  └─ app_it.ts
└─ App/
   ├─ CMakeLists.txt              # Adds subdirs; defines global include/link rules
   ├─ main.cpp                    # App entry (QGuiApplication/QQuickWindow setup)
   ├─ Main.qml                    # UI entry; imports App.* modules only (no ../)
   │
   ├─ Themes/                     # The *only* source of design values
   │  ├─ CMakeLists.txt           # URI App.Themes
   │  ├─ Theme.qml                # Singleton/bridge exposing active tokens/variant
   │  ├─ tokens/                  # Design tokens (no app logic)
   │  │  ├─ ColorTokens.qml
   │  │  ├─ SpacingTokens.qml
   │  │  ├─ IconTokens.qml
   │  │  └─ ...
   │  └─ variants/                # Brand/skin overrides; switchable at runtime
   │     ├─ Fincantieri.qml
   │     └─ ...
   │
   ├─ Components/                 # App-wide, business-agnostic QML only
   │  ├─ CMakeLists.txt           # URI App.Components
   │  ├─ Button.qml               # Keep flat; no primitives/composites split
   │  ├─ toast/                   # Exception: small subfolder when >2 files form a unit
   │  │  ├─ Toast.qml
   │  │  └─ ToastManager.{h,cpp}  # Helper C++ if needed; still business-agnostic
   │  └─ ...                      # Inputs, Dialogs, Icon, Text, Toolbar, etc.
   │
   ├─ Entities/                   # Plain C++ domain types (Qt-free)
   │  ├─ CMakeLists.txt
   │  ├─ Poi.{h,cpp}
   │  ├─ Track.{h,cpp}
   │  ├─ Geometry.{h,cpp}
   │  └─ ...
   │
   ├─ Models/                     # Shared Qt Models (only if used by ≥2 features)
   │  ├─ CMakeLists.txt
   │  ├─ PoiListModel.{h,cpp}
   │  ├─ TrackListModel.{h,cpp}
   │  └─ ...
   │
   └─ Features/                   # Each feature = public files at root + optional internals/
      ├─ Sample/                  # Template feature (for onboarding/new modules); URI App.Features.Sample
      │  ├─ CMakeLists.txt        # Defines a QML module (URI App.Sample)
      │  ├─ SampleView.qml        # Public surface (importable by other features)
      │  ├─ SampleController.{h,cpp}  # Public only if truly shared; else move to internals/
      │  ├─ internals/            # Non-imported QML/C++; keep flat; add only when needed
      │  ├─ assets/               # Local-only images/icons; not imported elsewhere
      │  ├─ models/               # Local Qt Models; promote to /src/models only when shared
      │  └─ entities/             # Local entities; promote to /src/entities when shared
      │
      ├─ Map/
      │  ├─ CMakeLists.txt        # URI App.Features.Map
      │  ├─ MapView.qml           # Public view (e.g., main canvas)
      │  ├─ MapDetailsPanel.qml   # Public *Panel for SidePanel consumption (if any)
      │  ├─ MapController.{h,cpp} # Feature logic; keep here unless shared
      │  └─ internals/            # Private helpers (render nodes, overlays, etc.)
      │
      ├─ Tracks/
      │  ├─ CMakeLists.txt        # URI App.Features.Tracks
      │  ├─ TracksPanel.qml       # Public *Panel for SidePanel
      │  ├─ TracksController.{h,cpp}
      │  └─ internals/
      │
      ├─ Language/
      │  ├─ CMakeLists.txt        # URI App.Features.Language
      │  ├─ LanguagesPanel.qml    # Public *Panel for SidePanel
      │  ├─ LanguageController.{h,cpp}
      │  └─ internals/
      │
      ├─ Settings/
      │  ├─ CMakeLists.txt        # URI App.Features.Settings
      │  ├─ SettingsPanel.qml     # Public *Panel for SidePanel
      │  ├─ UserSettingsStore.{h,cpp}
      │  ├─ AppSettingsStore.{h,cpp}
      │  └─ internals/
      │
      ├─ Siderail/
      │  ├─ CMakeLists.txt        # URI App.Features.SideRail
      │  ├─ SideRail.qml          # Public if imported from Main or other features
      │  └─ internals/
      │
      ├─ Titlebar/
      │  ├─ CMakeLists.txt        # URI App.Features.TitleBar
      │  ├─ TitleBar.qml
      │  └─ internals/
      │
      └─ Sidepanel/
         ├─ CMakeLists.txt        # URI App.Features.SidePanel
         ├─ SidePanel.qml         # Aggregates *Panel.qml from other features
         ├─ BasePanel.qml         # Common base for panels (visual contract)
         ├─ PanelRouter.{h,cpp}   # Central switching; others signal “open <panel>”
         └─ internals/
```

## Key Decisions and Their Rationale

### `src/` renamed to `App/`

Earlier drafts used `src/`, but Qt requires that **module URIs match folder paths**. (For more information, check [Writing a QML Module](https://doc.qt.io/qt-6/qtqml-writing-a-module.html)) Decoupling them caused fragile CMake hacks and runtime import issues. Moving to `App/` means `App/Features/Map` cleanly maps to `import App.Features.Map`.

### PascalCase vs lowercase convention

- **PascalCase** folders are QML modules that must align with URIs (`App/Themes → import App.Themes`).
- **lowercase** folders are non-modules (`internals/`, `tokens/`, `assets/`).

This visual distinction makes it obvious what is importable and what is private.

### Why no `Core/` folder?

A central "core" folder (settings, language, network, etc.) scattered responsibilities and created hidden dependencies. Instead, each feature owns its logic. Shared concepts (e.g., models, entities) have their own top-level folders, but cross-feature behavior is exposed through **feature controllers**. Example: the SidePanel’s `PanelRouter` mediates panel navigation instead of each feature reaching into each other’s code.

For more information, check the related [FAQ](FAQ.md).

### Components vs Features

`Components/` is reserved for **business-agnostic primitives and composites** (e.g., buttons, dialogs, toast). Features get their own folders because they mix business logic + UI. This separation prevents `Components/` from becoming a dumping ground for feature-specific parts.

### Promotion rules (entities/models)

Start local inside a feature. For example, if a model is tightly tied to a specific feature, then it makes sense to create `Features/<Feature>/entities` or `Features/<Feature>/models` inside it than the global `App/Entities` or `App/Models`

Promote to `App/Models` or `App/Entities` only if **shared across ≥2 features**. This avoids premature centralization while still preventing duplication.

### Panels treated as part of their feature

Earlier iterations grouped all panels into `sidepanel/`, making it a "god folder." The current approach keeps panels in their feature (e.g., `TracksPanel.qml` in `Tracks/`).

The SidePanel only aggregates them via `PanelRouter`.

### Internals folders

Introduced to separate **private implementation** from the **public API** (main views, controllers). This convention enforces API boundaries.

## Why This Structure Works

- **Predictable imports**: Module URIs always match folders (`import App.Features.Map`).
- **Clear boundaries**: Each feature is self-contained; `internals/` prevents unwanted dependencies.
- **Scalable**: Adding new features or design systems doesn’t require reshuffling the tree.
- **Framework-aligned**: By following Qt’s module resolution, we avoid brittle CMake hacks and runtime surprises.
- **Easy onboarding**: New developers can explore a feature folder and see everything relevant (UI, logic, assets) in one place.
