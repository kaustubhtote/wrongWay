class_name PlayerSettings
extends RefCounted
## Persisted non-sensitive player preferences.

const CURRENT_SCHEMA_VERSION := 1

var schema_version: int = CURRENT_SCHEMA_VERSION
var sound_enabled: bool = true
var haptics_enabled: bool = true
var reduced_motion: bool = false
var tutorial_completed: bool = false


func to_dict() -> Dictionary:
	return {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"sound_enabled": sound_enabled,
		"haptics_enabled": haptics_enabled,
		"reduced_motion": reduced_motion,
		"tutorial_completed": tutorial_completed,
	}


static func from_dict(data: Dictionary) -> PlayerSettings:
	var s := PlayerSettings.new()
	s.schema_version = CURRENT_SCHEMA_VERSION
	s.sound_enabled = bool(data.get("sound_enabled", true))
	s.haptics_enabled = bool(data.get("haptics_enabled", true))
	s.reduced_motion = bool(data.get("reduced_motion", false))
	s.tutorial_completed = bool(data.get("tutorial_completed", false))
	return s
