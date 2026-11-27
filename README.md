# WRONG WAY!

An offline-first 2D neon arcade reaction game built with **Godot 4.7.2-stable** (GDScript, Compatibility renderer) for Android (portrait-first).

See a directional command (`UP`, `DOWN`, `LEFT`, `RIGHT`), then tap the **opposite direction** before the response window closes (`UP ↔ DOWN`, `LEFT ↔ RIGHT`).

## Pinned Toolchain

- **Engine:** Godot `4.7.2-stable` (`gl_compatibility` renderer)
- **Java (Android export):** Temurin JDK 17 (`jdk-17.0.21.1+2`)
- **Android SDK:** `platform-tools`, `platforms;android-36`, `platforms;android-35`, `build-tools;36.0.0`
- **Package ID:** `io.github.kaustubhtote.wrongway`

## Project Structure

```text
scenes/
  app/          # Main.tscn root shell & ScreenRouter
  screens/      # Splash, Home, ModeSelect, HowToPlay, Countdown, Gameplay, PauseOverlay, Result, Settings, BestScores
  components/   # Reusable DirectionButton (64dp+ touch targets)
scripts/
  app/          # main.gd, screen_router.gd
  game/         # game_controller.gd
  models/       # game_enums.gd, game_config.gd, direction_prompt.gd, round_state.gd, session_result.gd, score_record.gd, player_settings.gd
  services/     # prompt_generator.gd, difficulty_service.gd, scoring_service.gd, save_service.gd, audio_service.gd, haptics_service.gd, share_service.gd
  ui/           # neon_theme.gd, safe_area_margin.gd, arrow_glyph.gd, screen_base.gd, screen scripts
assets/
  icons/        # Vector app icon (app_icon.svg)
  store/        # Store icon (512x512 PNG) & feature graphic (1024x500 PNG + SVG)
tests/          # Headless GDScript test runner & unit/persistence/UI suites
docs/           # Architecture, QA plan & device matrix, Store copy, Privacy policy, Tester guide, Release checklist
.github/
  workflows/    # CI validation (.github/workflows/ci.yml)
```

## Setup, Run & Test Locally

### 1. Run in Godot
```powershell
C:\Users\<user>\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --path .
```

### 2. Headless Import & Automated QA Suite
```powershell
C:\Users\<user>\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import --quit
C:\Users\<user>\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
```

### 3. Export Debug APK (Local Device QA)
Ensure Godot Editor Settings (`export/android/java_sdk_path` and `export/android/android_sdk_path`) point to your local JDK 17 and Android SDK, and Godot `4.7.2.stable` export templates are installed:
```powershell
mkdir build -Force
C:\Users\<user>\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-debug "Android" "build/wrong-way-debug.apk"
```

### 4. Release AAB (Publisher Action Required)
Release signing credentials are intentionally **not** stored in this repository. See [Release Checklist](docs/release-checklist.md) for upload keystore creation, Play App Signing setup, and Gradle `.aab` export targeting API 36+.

## Documentation

- [Architecture](docs/architecture.md)
- [QA Plan & Device Matrix](docs/qa-plan.md)
- [Store Listing & Policy Guide](docs/store-listing.md)
- [Privacy Policy Draft](docs/privacy-policy.md)
- [Closed Tester Guide](docs/tester-guide.md)
- [Release Checklist](docs/release-checklist.md)
- [Changelog](CHANGELOG.md)
