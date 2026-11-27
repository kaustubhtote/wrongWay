# Google Play Store Listing & Policy Preparation — WRONG WAY!

## App Identity & Versioning

- **App Name:** WRONG WAY!
- **Package ID:** `io.github.kaustubhtote.wrongway`
- **Initial Version:** `versionName = "1.0.0"`, `versionCode = 1`
- **Versioning Plan:** Increment `versionCode` monotonically by +1 on every internal/closed/production upload (`1`, `2`, `3`, ...); follow SemVer (`1.0.1` patches, `1.1.0` feature updates).
- **Support Email:** `[SUPPORT_EMAIL_PLACEHOLDER]` *(Publisher must provide a monitored support email before submission.)*
- **Privacy Policy URL:** `[PRIVACY_POLICY_URL_PLACEHOLDER]` *(Host `docs/privacy-policy.md` at a public HTTPS URL before Play Console review.)*

---

## Store Copy

### Short Description (68 / 80 chars)
> See LEFT, tap RIGHT! Fast offline neon arcade opposite-direction game.

### Full Description
> **Think fast—and tap the WRONG WAY!**
>
> **WRONG WAY!** is a crisp, 100% offline neon arcade reaction game that flips your instincts upside down. When an arrow and word flash on screen, your brain wants to tap that direction—but you must tap the **exact opposite direction** (`UP ↔ DOWN`, `LEFT ↔ RIGHT`) before the timer bar runs out!
>
> **TWO ARCADE MODES**
> • **Classic Mode:** Start with 3 lives and survive as long as you can. Every correct opposite tap scores +1 and builds your streak, while the response window speeds up from 1.80s down to 0.75s!
> • **60s Rush Mode:** Race against a 60-second clock! Chain fast combos to rack up points—wrong taps or timeouts cost 1 point (never below zero).
>
> **DESIGNED FOR FAIR PLAY & FOCUS**
> • **100% Offline:** No internet required, no accounts, no ads, and no tracking.
> • **Clear Readability:** High-contrast neon visuals pairing directional words with bold vector arrows—never relying on color alone.
> • **Pause-Safe:** Switching apps or taking a call automatically pauses the clock and prompt deadline.
> • **Customizable Comfort:** Toggle sound effects, haptic feedback, and reduced motion anytime.
>
> Train your focus, beat your personal bests, and share your top runs!

### Release Notes (`1.0.0`)
> Initial release of WRONG WAY!
> • Classic (3-lives) and 60s Rush arcade modes
> • Adaptive prompt speed (1.80s to 0.75s floor)
> • Offline personal bests & recent run history
> • Sound, haptics, and reduced-motion accessibility options

---

## Store Graphics & Screenshots Checklist

- [x] **App Icon (`512×512` PNG):** `assets/store/app_icon_512.png` (generated from `assets/icons/app_icon.svg`)
- [x] **Feature Graphic (`1024×500` PNG):** `assets/store/feature_graphic_1024x500.png`
- [ ] **Phone Screenshots (min 2, recommended 4–6 genuine 9:16 captures from final build):**
  1. Home screen
  2. Mode Select screen
  3. Active Gameplay (showing prompt + timer bar + 2×2 buttons)
  4. Result screen with score & accuracy
  5. Best Scores / Settings screen

---

## Play Console Declarations Guidance

- **Ads:** **No** — My app does not contain ads.
- **In-App Purchases:** **No** — Free offline game with no paid entries, loot boxes, or gambling mechanics.
- **Target Audience:** General audience / Ages 13+ or All Ages (ensure family-policy compliance if targeting children under 13; recommended `13+` / `Everyone` IARC rating without child-directed store badge unless explicitly desired).
- **Content Rating (IARC):** Minimal/none for violence, fear, gambling, user interaction, or location sharing → Expected rating: **Everyone / PEGI 3**.
- **Data Safety:**
  - Does your app collect or share any required user data types? **No.**
  - All settings and high scores are stored strictly locally on-device (`user://`), never transmitted off-device, and the Android `INTERNET` permission is disabled.
- **Target API Policy Check:**
  - Google Play requires new app submissions from **31 August 2026** onward to target **Android 16 (API level 36)** or higher. Verify the current Play Console target-API deadline and export using Gradle build (`target_sdk = 36`) before uploading the release AAB.
