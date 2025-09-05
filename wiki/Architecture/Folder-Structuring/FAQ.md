# FAQ – Folder Structure

This FAQ collects common "why not" questions about the folder structure and documents the reasoning behind key decisions.

[[_TOC_]]

## Why not keep a `Core/` folder?

In many enterprise projects, a `Core/` folder is used to hold shared or business-level logic. At first glance, this seems like a natural fit. However, under the **related-based** principle, introducing a `Core/` folder would inevitably cause a split: part of a feature’s logic would live inside `Core/`, and part inside the feature itself.

For example:

- `LanguageManager` would sit in `Core/`, while its UI (`LanguagePanel`) would sit in `Features/Language`.
- The `Theme` controller would move to `Core/`, while its tokens and variants remain in `App/Themes`.

This creates **scattered responsibilities** and makes the architecture harder to follow.

Instead, we keep logic **within the feature it belongs to**:

- **Feature-specific logic** → Lives inside the feature itself.

  - Example: `LanguageController` and `LanguagesPanel.qml` both live under `App/Features/Language/`. Supporting helpers stay in `internals/`, hidden from other features.

- **Cross-feature logic** → Exposed through a feature’s public controller/API.

  - Example: When clicking the **Layers** icon in `MapToolbar`, the action is routed to the `PanelRouter` (inside `App/Features/SidePanel/`), which then opens `LayersPanel` from `App/Features/Map/`. The map feature does not directly depend on side panel internals but communication happens through the router’s public interface.

This way, we avoid a "god" `Core/` folder while still maintaining **clear boundaries** and **proper communication** between features. Each feature stays modular and self-contained, and shared logic remains discoverable without being centralized in an artificial catch-all directory.


## Why are folders PascalCase vs lowercase?

### **PascalCase**

QML module (must map to a URI)

Example:

- `App/Themes` -> `import App.Themes`
- `App/Features/Map` -> `import App.Features.Map`

### **lowercase**

Non-module (internal-only).

Example:

- `App/Features/Map/internals/`
- `App/Themes/tokens/`

This makes it visually obvious what can be imported versus what is private implementation.

## Why is `src/` renamed to `App/`?

Qt requires **URI and folder path to align** ([Writing a QML Module](https://doc.qt.io/qt-6/qtqml-writing-a-module.html)).

With `src/`, we ended up with hacks like:

```qml
import App.Features.Map   // but folder is src/Features/Map
```

This caused fragile CMake aliasing and runtime import errors.


With `App/`, the path and URI align directly:

```qml
import App.Features.Map   // folder: App/Features/Map
```

Result: no hacks, no confusion, predictable imports.

## Why not split components into `primitives/` and `composites/`?

Early iterations tried this, but to align with **flat-based structuring**, it's better to put them inside `Components/` instead and if a component is complex enough then on its own folder. Components here must be **business-agnostic**.

```
Components/
├─ Button.qml
├─ Dialog.qml
├─ Toolbar.qml
└─ toast/
   ├─ Toast.qml
   └─ ToastManager.cpp
```

In essence, if a component has >2 files and forms a clear unit (like `toast/`), they can live in a small subfolder. Otherwise: keep it flat preventing unnecessary nested folders.

## Why not put all panels under `Sidepanel/`?

This was a concern during the previous iterations but trying a single `Sidepanel/` folder that held every panel (TracksPanel, MapPanel, SettingsPanel, etc.) causes a "god" folder problem where `Sidepanel/` becomes a coupled central point of communication between features. Instead, each feature owns its panel:

```
Features/Tracks/TracksPanel.qml
Features/Settings/SettingsPanel.qml
```

And then a global `SidePanel/PanelRouter` aggregates them. This approach is inspired from ReactRouter or VueRouter.

## Why introduce `internals/` folders?

Without `internals/`, every QML or C++ file at the feature root was implicitly public (well they still are but this makes a clear boundary what's private and what's not).

By convention:

- **Public API:** `<Feature>/MapView.qml`, `<Feature>/TracksPanel.qml`
- **Private details:** `<Feature>/internals/Overlay.qml`, `<Feature>/internals/MapMath.cpp`

This makes the feature’s API clear and prevents cross-feature leakage.

> Note to readers: The examples are just that examples. If the current codebase now reflects the use of `internals` folder, please update the examples.

## Why not centralize all models in `App/Models`?

Centralizing all models created bloat and encouraged premature generalization.

Example:

- `TracksListModel` was only used inside `Features/Tracks/`.
- Putting it in `App/Models/` implied it was reusable for all other features when it wasn’t.

**Rule:**

- Keep models local to a feature unless shared.
- Promote only when used by ≥2 features.

This keeps `App/Models` clean and genuinely shared.

## Why `variants/` and not `themes/` in Theming?

The `Themes.qml` which is an enum singleton cannot have a property called `Themes` which will conflict with its filename hence the need to name tham as `Variants` instead. Why? Because a QML component cannot have an enum directly but they must be inside an enum object. However, Qt does uplift the enum constants to the parent object so we can use `Themes.Fincantieri` than the verbose `Themes.Variants.Fincantieri`.

## Why no `ui/` or `views/` folders?

Earlier drafts tried grouping all QML under a `ui/` folder. This separated UI from logic, but in practice:

- UI and logic constantly needed to evolve together.
- Devs jumped back and forth between folders for a single feature.

The **feature-based** approach keeps everything (QML, controllers, assets) together. Example:

```
Features/Map/
├─ MapView.qml
├─ MapController.cpp
└─ internals/
```

This matches how features evolve in reality: UI + logic together. This approach is inspired by frameworks like React, Vue, and others where `.tsx` or `.vue` files have both UI and logic together preventing hunting for related logic code.

## Why not create a `shared/` folder?

A `shared/` folder is tempting, but it tends to become a **dumping ground for “misc stuff”**. Instead, responsibilities are clear:

- **Truly reusable UI** -> `Components/`
- **Truly shared entities/models** -> `Entities/`, `Models/`
- Everything else stays feature-local.

This enforces discipline and avoids a black hole of unrelated utilities. However, this does not necessarily mean that we cannot have a `App/Utilities` folder. If we ever need one, feel free to create but make sure it makes sense to do so.

Every decision is maintenance in the future.
