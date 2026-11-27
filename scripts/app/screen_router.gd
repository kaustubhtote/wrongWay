class_name ScreenRouter
extends Node
## Coordinates full-screen navigation, modal pause overlay, and Android back button.

signal screen_changed(screen_id: String)

var _screens: Dictionary = {}
var _current_id: String = ""
var _pause_overlay: Control = null
var _reduced_motion: bool = false


func register_screen(screen_id: String, screen: Control) -> void:
	_screens[screen_id] = screen
	screen.visible = false
	if screen is ScreenBase:
		var base := screen as ScreenBase
		if not base.navigate_requested.is_connected(navigate_to):
			base.navigate_requested.connect(navigate_to)


func set_pause_overlay(overlay: Control) -> void:
	_pause_overlay = overlay
	if _pause_overlay:
		_pause_overlay.visible = false


func set_reduced_motion(enabled: bool) -> void:
	_reduced_motion = enabled


func get_current_screen_id() -> String:
	return _current_id


func get_screen(screen_id: String) -> Control:
	return _screens.get(screen_id, null)


func navigate_to(screen_id: String, params: Dictionary = {}) -> void:
	if not _screens.has(screen_id):
		push_warning("ScreenRouter: unknown screen '%s'" % screen_id)
		return

	if _pause_overlay:
		_pause_overlay.visible = false

	if _current_id != "" and _screens.has(_current_id):
		var prev: Control = _screens[_current_id]
		if prev is ScreenBase:
			(prev as ScreenBase).on_exit()
		prev.visible = false

	_current_id = screen_id
	var next: Control = _screens[screen_id]
	next.visible = true
	if not _reduced_motion:
		next.modulate.a = 0.0
		var tween := next.create_tween()
		tween.tween_property(next, "modulate:a", 1.0, 0.14)
	else:
		next.modulate.a = 1.0

	if next is ScreenBase:
		(next as ScreenBase).on_enter(params)

	screen_changed.emit(screen_id)


func show_pause_overlay(show_overlay: bool) -> void:
	if _pause_overlay:
		_pause_overlay.visible = show_overlay


func handle_back_action() -> bool:
	if _pause_overlay and _pause_overlay.visible:
		if _pause_overlay.has_method("request_resume"):
			_pause_overlay.call("request_resume")
			return true

	if _current_id != "" and _screens.has(_current_id):
		var current: Control = _screens[_current_id]
		if current is ScreenBase and (current as ScreenBase).handle_back():
			return true

	match _current_id:
		"mode_select", "how_to_play", "settings", "best_scores", "result":
			navigate_to("home")
			return true
		"countdown":
			navigate_to("mode_select")
			return true
		"home":
			return false
		_:
			return true
