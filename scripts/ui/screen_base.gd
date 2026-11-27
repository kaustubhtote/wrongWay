class_name ScreenBase
extends Control
## Base class for full-screen views managed by ScreenRouter.

signal navigate_requested(screen_id: String, params: Dictionary)


func on_enter(_params: Dictionary = {}) -> void:
	pass


func on_exit() -> void:
	pass


## Override to consume Android back / Escape press; return true if handled.
func handle_back() -> bool:
	return false
