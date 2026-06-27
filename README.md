# Task Management App

A Flutter task management app with a dark + yellow neon theme, animated splash screen, and local data persistence via SharedPreferences.

---

## Screenshots

| Splash | Login | Home | Add Task |
|--------|-------|------|----------|
| Animated icon with glow pulse | Email + password validation | Task list with filters | Bottom sheet form |

---

## Features

- 🎬 **Animated splash screen** — elastic icon pop-in, yellow glow pulse, text slide-up
- 🔐 **Login screen** — email format validation, password visibility toggle
- ✅ **Add tasks** — title (required) + optional description via bottom sheet
- 🗑️ **Delete tasks** — confirmation dialog before removal
- ☑️ **Complete tasks** — tap the circle to toggle, strikethrough applied
- 📊 **Summary cards** — live Pending / Completed / Total counts
- 🔽 **Filter tabs** — view All, Pending, or Done tasks
- 💾 **Data persistence** — tasks survive app restarts via SharedPreferences

---

## Project Structure

```
lib/
├── main.dart            # App entry point + LoginScreen
├── splash_screen.dart   # Animated splash screen
├── home_screen.dart     # Task list UI + add/delete/toggle logic
├── task_model.dart      # Task data class + JSON serialization
└── task_service.dart    # SharedPreferences read/write operations

images/
└── task_icon.png        # App icon used in splash + app bar
```

---

## Setup Instructions

### Prerequisites

Make sure you have the following installed:

| Tool | Version | Check |
|------|---------|-------|
| Flutter SDK | 3.x or higher | `flutter --version` |
| Dart SDK | 3.9.2 or higher | `dart --version` |
| Android Studio / VS Code | Latest | — |
| Android Emulator or physical device | — | `flutter devices` |

---

### 1. Clone or copy the project

If you're copying files manually, your folder structure should look like this:

```
task_management/
├── lib/
│   ├── main.dart
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── task_model.dart
│   └── task_service.dart
├── images/
│   └── task_icon.png
├── pubspec.yaml
└── README.md
```

---

### 2. Install dependencies

Run this in the project root:

```bash
flutter pub get
```

This downloads the `shared_preferences` package from pub.dev. You should see:

```
+ shared_preferences 2.3.2
Running "flutter pub get" in task_management... ✓
```

---

### 3. Confirm the image asset is registered

Open `pubspec.yaml` and verify this section exists:

```yaml
flutter:
  uses-material-design: true
  assets:
    - images/
```

The `images/` folder must be at the **project root** (same level as `lib/`), not inside `lib/`.

---

### 4. Run the app

**On an emulator or connected device:**

```bash
flutter run
```

**To pick a specific device:**

```bash
flutter devices          # lists available devices
flutter run -d <device_id>
```

**To run in release mode:**

```bash
flutter run --release
```

---

### 5. Build an APK (Android)

```bash
flutter build apk --release
```

Output will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.3.2 | Local data persistence for tasks |
| `cupertino_icons` | ^1.0.8 | iOS-style icon support |

All other functionality uses Flutter's built-in `material` library.

---

## Color Reference

| Name | Hex | Used For |
|------|-----|---------|
| Background | `#1C1C1C` | Scaffold, app bar |
| Card surface | `#252525` | Task cards, bottom sheet |
| Accent yellow | `#FFEA00` | Buttons, titles, FAB, glow |
| Text primary | `#FFFFFF` | Task titles |
| Text muted | `#D1D0C7` | Subtitles, hints |
