# Architecture — WRONG WAY!

## Design Principles

- **Offline-first & privacy-preserving:** Zero network permissions, zero ads, zero analytics SDKs.
- **Separation of concerns:** Pure domain models and services have no UI dependencies and are unit-tested headlessly.
- **Deterministic testability:** `PromptGenerator` accepts an explicit RNG seed, and `GameController.step(delta)` can be driven deterministically in tests without waiting on wall-clock timers.
- **Responsive portrait UI:** `720×1280` reference viewport with `canvas_items` stretch and `expand` aspect, `SafeAreaMargin` display cutout insets, and `64dp+` (`260×152` ref px) 2×2 touch targets.

## Module Breakdown

### Models (`scripts/models/`)
- `GameEnums` (`game_enums.gd`): `Direction`, `GameMode`, `RoundStatus`, `InputOutcome`, plus display/key mapping helpers.
- `GameConfig` (`game_config.gd`): Configurable mode parameters (`starting_lives = 3`, `rush_duration_seconds = 60.0`, `base_response_window = 1.8`, `min_response_window = 0.75`, `window_step_per_correct = 0.02`, `max_consecutive_repeats = 2`).
- `DirectionPrompt` (`direction_prompt.gd`): `id`, `displayed_direction`, `correct_direction`, `created_elapsed`, `response_window`, `response_deadline`, `sequence_index`, and single-resolution `resolved` flag.
- `RoundState` (`round_state.gd`): Live round status, score, lives, elapsed/remaining time, streaks, outcome counts, and `current_prompt`.
- `SessionResult` (`session_result.gd`): Completed session metrics, accuracy, duration, Unix timestamp, and `is_new_record`.
- `ScoreRecord` (`score_record.gd`): Versioned Classic/Rush personal bests, best streaks, and capped recent results (`MAX_RECENT_RESULTS = 20`).
- `PlayerSettings` (`player_settings.gd`): Versioned sound, haptics, reduced motion, and tutorial completion preferences.

### Services (`scripts/services/`)
- `PromptGenerator` (`prompt_generator.gd`): Opposite-direction mapping (`UP↔DOWN`, `LEFT↔RIGHT`), max-2 consecutive identical prompt guard, and deterministic RNG seeding.
- `DifficultyService` (`difficulty_service.gd`): Linear ramp from `1.80s` down by `0.02s` per correct answer with hard floor at `0.75s`.
- `ScoringService` (`scoring_service.gd`): Score, life, streak, zero-floor Rush penalty, zero-answer-safe accuracy, and round-end checks.
- `SaveService` (`save_service.gd`): Versioned JSON persistence under `user://` (`settings.json`, `records.json`), v0→v1 migration, and corrupt/missing file recovery.
- `AudioService` (`audio_service.gd`): Procedural 16-bit PCM synth `AudioStreamWAV` tones (no external licensed audio needed).
- `HapticsService` (`haptics_service.gd`): Mobile vibration wrapper gated by settings.
- `ShareService` (`share_service.gd`): Formatted summary string with native singleton hook and safe clipboard fallback.

### Game & Navigation (`scripts/game/`, `scripts/app/`, `scripts/ui/`)
- `GameController` (`game_controller.gd`): Owns round lifecycle, non-time-consuming `COUNTDOWN`, single-resolution `submit_direction()`, timeout evaluation, and `PAUSED` freeze on both round timer and prompt deadlines.
- `ScreenRouter` (`screen_router.gd`): Screen registry, transition animations (respecting `reduced_motion`), modal `PauseOverlay`, and Android back-button routing.
- `main.gd` (`scripts/app/main.gd`): Connects UI signals to `GameController` and services; automatically pauses active rounds on `NOTIFICATION_APPLICATION_PAUSED`, `NOTIFICATION_APPLICATION_FOCUS_OUT`, and `NOTIFICATION_WM_WINDOW_FOCUS_OUT`.

## Round State Flow

```text
IDLE ──(start_round)──▶ COUNTDOWN ──(countdown ends)──▶ ACTIVE ──(3 mistakes / 60s)──▶ ENDED
                            │                              │
                     (pause/bg)                     (pause/bg/back)
                            ▼                              ▼
                          PAUSED ◀────────────────────── PAUSED
```
