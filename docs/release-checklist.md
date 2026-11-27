# Google Play Release Checklist — WRONG WAY!

## 1. Automated & Engineering Gates
- [x] Pinned Godot `4.7.2-stable` (`gl_compatibility`) configured in `project.godot` and `.github/workflows/ci.yml`.
- [x] Headless import & automated QA suite (`tests/run_tests.gd`) passes with exit code `0`.
- [x] Offline-only configuration: `permissions/internet=false`, zero ads/analytics SDKs, zero secrets in repo.
- [ ] Local debug APK built and smoke-tested on Android hardware (`build/wrong-way-debug.apk`).
- [ ] Device QA matrix (`docs/qa-plan.md`) completed with **zero** open Blocker/Critical/High defects.

## 2. Release Signing & Play App Signing (Human Publisher Only)
> **Security Rule:** Never commit `.keystore`, `.jks`, `.p12`, passwords, or Play Console credentials to Git.

1. **Generate Upload Keystore locally (outside repo):**
   ```powershell
   keytool -genkeypair -v -keystore C:\secure\wrongway-upload.jks -alias wrongway-upload -keyalg RSA -keysize 2048 -validity 10000
   ```
2. **Back up safely:** Store the `.jks` file and passwords in an encrypted password manager / offline backup. Losing the upload key requires contacting Google Play Support for an upload key reset.
3. **Play App Signing:** Opt into **Google Play App Signing** in Play Console (mandatory for new apps). Google manages the final app-signing key; your local keystore signs the upload `.aab`.
4. **Configure Godot Gradle Release AAB Export (locally, without committing secrets):**
   - Set `gradle_build/use_gradle_build=true`, `gradle_build/export_format=1` (`.aab`), `gradle_build/min_sdk="24"`, `gradle_build/target_sdk="36"`.
   - Point release keystore path/user/password locally via Editor/environment or untracked local export config, and export `build/wrong-way-release.aab`.

## 3. Store Assets & Policy Verification (Human Publisher)
- [ ] Verify current Google Play target API policy (new submissions require **API 36+** from 31 August 2026).
- [ ] Host `docs/privacy-policy.md` at a live HTTPS URL and replace `[PRIVACY_POLICY_URL_PLACEHOLDER]`.
- [ ] Provide real support email (`[SUPPORT_EMAIL_PLACEHOLDER]`).
- [ ] Upload `assets/store/app_icon_512.png` (`512×512`), `assets/store/feature_graphic_1024x500.png` (`1024×500`), and **2–6 genuine screenshots** from the final build.
- [ ] Complete Play Console declarations: Ads (`No`), Data Safety (`No data collected/shared`), Content Rating (`IARC`), Target Audience.

## 4. Internal & Closed Testing Tracks (Human Publisher)
1. **Internal Testing Track:**
   - Upload signed release `.aab` (`versionCode = 1`, `versionName = "1.0.0"`).
   - Verify pre-launch report / Play Console bundle checks (`targetSdk`, 64-bit `arm64-v8a` support, permissions).
2. **Closed Testing Track:**
   - Create closed testing release and share opt-in link + `docs/tester-guide.md`.
   - **Personal Account Policy Check:** For personal developer accounts created after **13 November 2023**, current policy requires at least **12 opted-in testers continuously for 14 days** before applying for production access. Verify your exact Play Console dashboard requirement.
   - Collect real tester feedback and log/fix any defects in `docs/qa-plan.md`.

## 5. Production Access Application & Staged Rollout (Human Publisher)
- **Production Access Answers Template (fill strictly from actual testing):**
  - *How did you recruit testers and gather feedback?* -> Document actual closed-track tester count, opt-in duration, and feedback channels used.
  - *What feedback did testers provide and what changes did you make?* -> Summarize genuine defects/UX improvements from `docs/qa-plan.md`.
  - *How did you verify readiness for production?* -> Cite automated test suite results, Play Pre-Launch Report, and physical device QA results.
- **Staged Rollout:**
  - Start production rollout at **5% → 20% → 50% → 100%**.
  - Monitor **Android Vitals** (crash rate, ANR rate, slow rendering) and Play Console reviews at each stage before expanding rollout.

## 6. Human-Only Action Summary
The following steps **cannot** be automated by the coding agent and must be performed by the human publisher:
1. Logging into Google Play Console, verifying developer identity, and paying registration fees.
2. Generating and securely backing up the release upload keystore.
3. Accepting Play Console policy declarations, uploading store screenshots/AAB, and managing tester lists.
4. Submitting closed testing, production access application, and staged production rollout.
