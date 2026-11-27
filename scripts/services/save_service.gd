class_name SaveService
extends RefCounted
## Versioned local persistence under user:// with schema migration and corruption recovery.

const DEFAULT_DIR := "user://"
const SETTINGS_FILE := "settings.json"
const RECORDS_FILE := "records.json"

var _base_dir: String = DEFAULT_DIR


func _init(base_dir: String = DEFAULT_DIR) -> void:
	_base_dir = base_dir if base_dir.ends_with("/") else base_dir + "/"
	if _base_dir != DEFAULT_DIR:
		DirAccess.make_dir_recursive_absolute(_base_dir)


func load_settings() -> PlayerSettings:
	var data := _read_json_dict(_base_dir + SETTINGS_FILE)
	if data.is_empty():
		return PlayerSettings.new()
	var migrated := _migrate_settings_dict(data)
	return PlayerSettings.from_dict(migrated)


func save_settings(settings: PlayerSettings) -> bool:
	return _write_json_dict(_base_dir + SETTINGS_FILE, settings.to_dict())


func load_records() -> ScoreRecord:
	var data := _read_json_dict(_base_dir + RECORDS_FILE)
	if data.is_empty():
		return ScoreRecord.new()
	var migrated := _migrate_records_dict(data)
	return ScoreRecord.from_dict(migrated)


func save_records(records: ScoreRecord) -> bool:
	return _write_json_dict(_base_dir + RECORDS_FILE, records.to_dict())


func _migrate_settings_dict(data: Dictionary) -> Dictionary:
	var version := int(data.get("schema_version", 0))
	if version >= PlayerSettings.CURRENT_SCHEMA_VERSION:
		return data
	# Legacy v0 -> v1 migration
	return {
		"schema_version": PlayerSettings.CURRENT_SCHEMA_VERSION,
		"sound_enabled": bool(data.get("sound_enabled", data.get("sound", true))),
		"haptics_enabled": bool(data.get("haptics_enabled", data.get("haptics", true))),
		"reduced_motion": bool(data.get("reduced_motion", false)),
		"tutorial_completed": bool(data.get("tutorial_completed", data.get("seen_tutorial", false))),
	}


func _migrate_records_dict(data: Dictionary) -> Dictionary:
	var version := int(data.get("schema_version", 0))
	if version >= ScoreRecord.CURRENT_SCHEMA_VERSION:
		return data
	# Legacy v0 -> v1 migration
	return {
		"schema_version": ScoreRecord.CURRENT_SCHEMA_VERSION,
		"classic_best": maxi(0, int(data.get("classic_best", data.get("best_classic", 0)))),
		"classic_best_streak": maxi(0, int(data.get("classic_best_streak", 0))),
		"rush_best": maxi(0, int(data.get("rush_best", data.get("best_rush", 0)))),
		"rush_best_streak": maxi(0, int(data.get("rush_best_streak", 0))),
		"recent_results": data.get("recent_results", []) if data.get("recent_results", []) is Array else [],
	}


func _read_json_dict(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var raw := file.get_as_text()
	file.close()
	if raw.strip_edges().is_empty():
		return {}
	var json := JSON.new()
	if json.parse(raw) != OK:
		return {}
	if json.data is Dictionary:
		return json.data
	return {}


func _write_json_dict(path: String, payload: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()
	return true
