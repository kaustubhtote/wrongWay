class_name HapticsService
extends RefCounted
## Tactile vibration feedback respecting player preferences and desktop/headless safety.

var enabled: bool = true


func trigger_correct() -> void:
	_vibrate(18)


func trigger_wrong() -> void:
	_vibrate(55)


func trigger_tap() -> void:
	_vibrate(10)


func _vibrate(duration_ms: int) -> void:
	if not enabled:
		return
	if OS.has_feature("mobile") or OS.get_name() == "Android" or OS.get_name() == "iOS":
		Input.vibrate_handheld(duration_ms)
