extends RefCounted
## Persistence tests: save/load round-trip, missing/corrupt file recovery, schema migration, and ShareService.


static func run(t) -> void:
	var test_dir := "user://test_persistence_%d/" % int(Time.get_unix_time_from_system())
	_test_missing_files_defaults(t, test_dir + "missing/")
	_test_settings_round_trip(t, test_dir + "settings_rt/")
	_test_records_round_trip_and_cap(t, test_dir + "records_rt/")
	_test_corrupt_json_recovery(t, test_dir + "corrupt/")
	_test_legacy_schema_migration(t, test_dir + "migrate/")
	_test_share_formatting(t)


static func _test_missing_files_defaults(t, dir_path: String) -> void:
	var svc := SaveService.new(dir_path)
	var s := svc.load_settings()
	t.assert_eq(s.sound_enabled, true, "Missing settings defaults sound true")
	t.assert_eq(s.haptics_enabled, true, "Missing settings defaults haptics true")
	t.assert_eq(s.reduced_motion, false, "Missing settings defaults reduced_motion false")
	t.assert_eq(s.tutorial_completed, false, "Missing settings defaults tutorial false")

	var r := svc.load_records()
	t.assert_eq(r.classic_best, 0, "Missing records defaults classic_best 0")
	t.assert_eq(r.rush_best, 0, "Missing records defaults rush_best 0")
	t.assert_eq(r.recent_results.size(), 0, "Missing records defaults empty recent list")


static func _test_settings_round_trip(t, dir_path: String) -> void:
	var svc := SaveService.new(dir_path)
	var s := PlayerSettings.new()
	s.sound_enabled = false
	s.haptics_enabled = false
	s.reduced_motion = true
	s.tutorial_completed = true
	t.assert_true(svc.save_settings(s), "save_settings returns true")

	var loaded := svc.load_settings()
	t.assert_eq(loaded.sound_enabled, false, "Round-trip sound_enabled")
	t.assert_eq(loaded.haptics_enabled, false, "Round-trip haptics_enabled")
	t.assert_eq(loaded.reduced_motion, true, "Round-trip reduced_motion")
	t.assert_eq(loaded.tutorial_completed, true, "Round-trip tutorial_completed")


static func _test_records_round_trip_and_cap(t, dir_path: String) -> void:
	var svc := SaveService.new(dir_path)
	var rec := ScoreRecord.new()
	for i in 25:
		var sr := SessionResult.new()
		sr.session_id = "s_%d" % i
		sr.mode = GameEnums.GameMode.CLASSIC if i % 2 == 0 else GameEnums.GameMode.RUSH
		sr.score = i + 1
		sr.accuracy = 80.0
		sr.best_streak = i
		rec.apply_session(sr)

	t.assert_true(svc.save_records(rec), "save_records returns true")
	var loaded := svc.load_records()
	t.assert_eq(loaded.classic_best, 25, "Classic best persisted")
	t.assert_eq(loaded.rush_best, 24, "Rush best persisted")
	t.assert_eq(loaded.recent_results.size(), ScoreRecord.MAX_RECENT_RESULTS, "Recent results capped at MAX_RECENT_RESULTS")


static func _test_corrupt_json_recovery(t, dir_path: String) -> void:
	var svc := SaveService.new(dir_path)
	var f1 := FileAccess.open(dir_path + SaveService.SETTINGS_FILE, FileAccess.WRITE)
	f1.store_string("{not valid json!!!")
	f1.close()

	var f2 := FileAccess.open(dir_path + SaveService.RECORDS_FILE, FileAccess.WRITE)
	f2.store_string("[1, 2, 3]")
	f2.close()

	var s := svc.load_settings()
	t.assert_eq(s.sound_enabled, true, "Corrupt settings JSON recovers to safe default")
	var r := svc.load_records()
	t.assert_eq(r.classic_best, 0, "Non-dictionary records JSON recovers to safe default")


static func _test_legacy_schema_migration(t, dir_path: String) -> void:
	var svc := SaveService.new(dir_path)
	var f1 := FileAccess.open(dir_path + SaveService.SETTINGS_FILE, FileAccess.WRITE)
	f1.store_string(JSON.stringify({
		"sound": false,
		"haptics": true,
		"seen_tutorial": true,
	}))
	f1.close()

	var f2 := FileAccess.open(dir_path + SaveService.RECORDS_FILE, FileAccess.WRITE)
	f2.store_string(JSON.stringify({
		"best_classic": 19,
		"best_rush": 42,
	}))
	f2.close()

	var s := svc.load_settings()
	t.assert_eq(s.schema_version, PlayerSettings.CURRENT_SCHEMA_VERSION, "Migrated settings version")
	t.assert_eq(s.sound_enabled, false, "Migrated legacy sound key")
	t.assert_eq(s.tutorial_completed, true, "Migrated legacy seen_tutorial key")

	var r := svc.load_records()
	t.assert_eq(r.schema_version, ScoreRecord.CURRENT_SCHEMA_VERSION, "Migrated records version")
	t.assert_eq(r.classic_best, 19, "Migrated legacy best_classic")
	t.assert_eq(r.rush_best, 42, "Migrated legacy best_rush")


static func _test_share_formatting(t) -> void:
	var sr := SessionResult.new()
	sr.mode = GameEnums.GameMode.RUSH
	sr.score = 33
	sr.accuracy = 91.5
	sr.best_streak = 12
	var txt := ShareService.format_share_text(sr)
	t.assert_true(txt.contains("33") and txt.contains("60s RUSH") and txt.contains("91.5%"), "Share text includes score, mode, and accuracy")
