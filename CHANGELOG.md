# Changelog

All notable changes to **WRONG WAY!** are documented in this file.

## [1.0.0] - Unreleased (Ready for Device QA & Closed Testing)

### Added
- **Phase 1 — Foundation:** Pinned Godot `4.7.2-stable` project (`project.godot`), `720×1280` portrait viewport (`canvas_items` / `expand`), `gl_compatibility` renderer, `.gitignore`, vector app icon, and directory layout.
- **Phase 2 — UI Shell:** Neon theme (`NeonTheme`), `SafeAreaMargin` display cutout insets, custom vector `ArrowGlyph`, `64dp+` `DirectionButton` 2×2 grid, `ScreenRouter`, and all 10 screens (`Splash`, `Home`, `ModeSelect`, `HowToPlay`, `Countdown`, `Gameplay`, `PauseOverlay`, `Result`, `Settings`, `BestScores`).
- **Phase 3 — Domain Logic:** Typed models (`GameEnums`, `GameConfig`, `DirectionPrompt`, `RoundState`, `SessionResult`, `ScoreRecord`, `PlayerSettings`), `PromptGenerator` (opposite mapping, max-2 repeat guard, deterministic seed), `DifficultyService` (`1.80s` → `0.75s` floor), `ScoringService`, and `GameController`.
- **Phase 4 & 5 — Gameplay & Persistence Polish:** Full round/countdown/pause/background-freeze wiring, versioned `SaveService` (`user://`, v0→v1 migration, corrupt JSON recovery), procedural `AudioService`, `HapticsService`, and `ShareService` with clipboard fallback.
- **Phase 6 — Automated QA:** Project-native headless test runner (`tests/run_tests.gd`) covering domain, persistence, and UI navigation/restart suites.
- **Phase 7 — CI & Android Build:** GitHub Actions workflow (`.github/workflows/ci.yml`), `export_presets.cfg` (`io.github.kaustubhtote.wrongway`, offline permissions), and verified Debug APK build (`build/wrong-way-debug.apk`).
- **Phase 8–10 — QA & Store Readiness:** Generated `512×512` Store icon & `1024×500` feature graphic, and authored `docs/architecture.md`, `docs/qa-plan.md`, `docs/store-listing.md`, `docs/privacy-policy.md`, `docs/tester-guide.md`, and `docs/release-checklist.md`.

### Fixed
- **QA-001:** Prevented `DirectionButton` from renaming its node at runtime in `_ready()`, which broke `GameplayScreen` child lookups.
