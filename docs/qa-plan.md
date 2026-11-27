# QA Plan & Test Report — WRONG WAY!

## 1. Automated Verification

Command (also enforced in `.github/workflows/ci.yml`):
```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
```

### Automated Coverage Matrix
| Area | File | Verified Scenarios |
|---|---|---|
| Opposite mapping | `tests/test_domain.gd` | UP↔DOWN and LEFT↔RIGHT |
| Prompt generator | `tests/test_domain.gd` | Enum validity, max-2 consecutive repeat limiter (500 prompts), deterministic RNG seed |
| Difficulty bounds | `tests/test_domain.gd` | Starts at 1.80s, monotonic decrease, hard floor 0.75s, clamped negative input |
| Scoring & accuracy | `tests/test_domain.gd` | Single-increment scoring, 0-answer accuracy = 0.0%, mixed accuracy |
| Classic rules | `tests/test_domain.gd` | Single resolution per prompt, duplicate tap ignored, 1 life per wrong/timeout, ends on 3rd mistake |
| 60s Rush rules | `tests/test_domain.gd` | Zero-floor penalty (never < 0), ends at 60.0s |
| Pause & deadlines | `tests/test_domain.gd` | Countdown consumes 0 game time; pause freezes round clock, deadline, and input |
| Late input | `tests/test_domain.gd` | Input past `response_deadline` returns `IGNORED` and cannot score |
| Persistence | `tests/test_persistence.gd` | Missing file defaults, settings/records round-trip, recent list cap (20), corrupt JSON recovery, v0→v1 migration |
| UI & Navigation | `tests/test_ui_flow.gd` | `Main.tscn` load, screen routing, Android back handling, 2×2 button min size (`>=260×152`), countdown→gameplay→pause→resume→restart |

---

## 2. Android Device QA Matrix (Manual Execution Required on Physical Hardware / Emulators)

> **Rule:** Do not declare production release-ready while any **Blocker**, **Critical**, or **High** severity defect remains open.

| Device Tier | Example Profile | Screen & Aspect | Android / API | Navigation Mode | Key Checks | Status |
|---|---|---|---|---|---|---|
| Low-end | 2–3 GB RAM, entry SoC | 5.0"–5.5", 720×1280 (16:9) | Android 7.0–9.0 (API 24–28) | 3-button nav | Cold start < 3s, 60fps UI, 2×2 buttons >= 48dp/64dp+, bottom safe area | Pending device run |
| Mid-range | 4–6 GB RAM, Snapdragon 6/7 | 6.4", 1080×2400 (20:9) | Android 11–13 (API 30–33) | Gesture nav | Tall aspect scaling (`expand`), gesture pill clearance, audio/haptics | Pending device run |
| Recent | 8–12 GB RAM, 120Hz OLED | 6.7", 1440×3120 + punch-hole | Android 14–16 (API 34–36) | Gesture nav | Display cutout safe area (`SafeAreaMargin`), crisp vector arrows | Pending device run |

### Interruption & Lifecycle Checklist
- [ ] **Background / Home button during Countdown:** Auto-pauses; resuming restores countdown without losing game time.
- [ ] **Background / App Switcher during Active Classic/Rush:** Auto-pauses and opens `PauseOverlay`; prompt deadline and 60s timer remain frozen.
- [ ] **Incoming Call / Notification Shade:** Focus loss triggers pause; zero unfair timeout penalty.
- [ ] **Android Back Button:** Gameplay → Pause; Pause → Resume; Sub-screens → Home; Home → Clean exit.
- [ ] **Airplane / Offline Mode:** Full gameplay, local high-score persistence, and clipboard share fallback operate with zero errors or network prompts.
- [ ] **Accessibility:** High contrast text + vector arrow + word labels verified; Reduced Motion toggle disables scale/fade tweens.

---

## 3. Defect Log

| ID | Severity | Summary | Device / OS | Reproduction Steps | Status | Fix Verification |
|---|---|---|---|---|---|---|
| QA-001 | High | `DirectionButton` renamed node in `_ready()`, breaking `GameplayScreen` `@onready` lookups | Headless / All | Instantiate `Main.tscn` -> `GameplayScreen._ready()` | **Fixed** | Removed runtime node rename in `direction_button.gd`; verified `2083 passed, 0 failed` |
| *(Add device QA findings here)* | — | — | — | — | — | — |
