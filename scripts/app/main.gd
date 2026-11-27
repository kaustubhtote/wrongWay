extends Control
## Root application coordinator connecting UI screens, GameController, and local services.

@onready var _router: ScreenRouter = %ScreenRouter
@onready var _controller: GameController = %GameController
@onready var _audio: AudioService = %AudioService

@onready var _splash: ScreenBase = %SplashScreen
@onready var _home: ScreenBase = %HomeScreen
@onready var _mode_select: ScreenBase = %ModeSelectScreen
@onready var _how_to_play: ScreenBase = %HowToPlayScreen
@onready var _countdown: ScreenBase = %CountdownScreen
@onready var _gameplay: ScreenBase = %GameplayScreen
@onready var _result: ScreenBase = %ResultScreen
@onready var _settings_screen: ScreenBase = %SettingsScreen
@onready var _best_scores: ScreenBase = %BestScoresScreen
@onready var _pause_overlay: Control = %PauseOverlay

var _save_service: SaveService = SaveService.new()
var _haptics: HapticsService = HapticsService.new()
var _settings: PlayerSettings = PlayerSettings.new()
var _records: ScoreRecord = ScoreRecord.new()
var _last_result: SessionResult = null
var _active_mode: int = GameEnums.GameMode.CLASSIC


func _ready() -> void:
	theme = NeonTheme.create_base_theme()
	_load_persisted_state()
	_register_screens()
	_wire_signals()
	_apply_settings_to_ui()
	_refresh_score_views()
	_router.navigate_to("splash")


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if not _router.handle_back_action():
				get_tree().quit()
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			_handle_app_interruption()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _router.handle_back_action():
			get_viewport().set_input_as_handled()


func _load_persisted_state() -> void:
	_settings = _save_service.load_settings()
	_records = _save_service.load_records()


func _register_screens() -> void:
	_router.register_screen("splash", _splash)
	_router.register_screen("home", _home)
	_router.register_screen("mode_select", _mode_select)
	_router.register_screen("how_to_play", _how_to_play)
	_router.register_screen("countdown", _countdown)
	_router.register_screen("gameplay", _gameplay)
	_router.register_screen("result", _result)
	_router.register_screen("settings", _settings_screen)
	_router.register_screen("best_scores", _best_scores)
	_router.set_pause_overlay(_pause_overlay)


func _wire_signals() -> void:
	_router.screen_changed.connect(_on_screen_changed)

	# Home -> ModeSelect or first-time HowToPlay
	_home.navigate_requested.disconnect(_router.navigate_to)
	_home.navigate_requested.connect(_on_home_navigate)

	_mode_select.mode_selected.connect(_start_mode)
	_how_to_play.tutorial_completed.connect(_on_tutorial_completed)

	# Gameplay inputs & pause
	_gameplay.direction_submitted.connect(_on_direction_submitted)
	_gameplay.pause_requested.connect(_on_pause_requested)

	_pause_overlay.resume_requested.connect(_on_resume_requested)
	_pause_overlay.restart_requested.connect(func():
		_router.show_pause_overlay(false)
		_start_mode(_active_mode)
	)
	_pause_overlay.how_to_play_requested.connect(func():
		_router.show_pause_overlay(false)
		_router.navigate_to("how_to_play", {"return_to": "gameplay"})
	)
	_pause_overlay.home_requested.connect(func():
		_router.show_pause_overlay(false)
		_controller.abort_to_idle()
		_router.navigate_to("home")
	)

	# Result actions
	_result.replay_requested.connect(_start_mode)
	_result.share_requested.connect(_on_share_requested)

	# Settings
	_settings_screen.settings_changed.connect(_on_settings_changed)

	# GameController lifecycle
	_controller.countdown_tick.connect(_on_countdown_tick)
	_controller.countdown_finished.connect(func(): _audio.play_countdown(true))
	_controller.round_started.connect(_on_round_started)
	_controller.prompt_issued.connect(_on_prompt_issued)
	_controller.prompt_resolved.connect(_on_prompt_resolved)
	_controller.state_updated.connect(_on_state_updated)
	_controller.round_ended.connect(_on_round_ended)


func _on_home_navigate(screen_id: String, params: Dictionary) -> void:
	if screen_id == "mode_select" and not _settings.tutorial_completed:
		_router.navigate_to("how_to_play", {"return_to": "mode_select"})
		return
	_router.navigate_to(screen_id, params)


func _on_screen_changed(screen_id: String) -> void:
	if screen_id == "gameplay" and _controller.state.status == GameEnums.RoundStatus.PAUSED:
		_router.show_pause_overlay(true)


func _on_tutorial_completed() -> void:
	if not _settings.tutorial_completed:
		_settings.tutorial_completed = true
		_save_service.save_settings(_settings)


func _start_mode(mode: int) -> void:
	_active_mode = mode
	var cfg := GameConfig.create_classic() if mode == GameEnums.GameMode.CLASSIC else GameConfig.create_rush()
	_countdown.set_mode(mode)
	_router.navigate_to("countdown")
	_controller.start_round(cfg)


func _on_countdown_tick(seconds_left: int) -> void:
	_countdown.set_countdown_value(seconds_left)
	_audio.play_countdown(false)


func _on_round_started(state: RoundState) -> void:
	_gameplay.clear_feedback()
	_router.navigate_to("gameplay")
	_sync_gameplay_hud(state)


func _on_prompt_issued(prompt: DirectionPrompt) -> void:
	_gameplay.show_prompt(prompt.displayed_direction, prompt.response_window)


func _on_direction_submitted(direction: int) -> void:
	_controller.submit_direction(direction)


func _on_prompt_resolved(outcome: int, prompt: DirectionPrompt, tapped_dir: int, state: RoundState) -> void:
	_gameplay.show_feedback(outcome, prompt.correct_direction, tapped_dir)
	match outcome:
		GameEnums.InputOutcome.CORRECT:
			_audio.play_correct(state.current_streak)
			_haptics.trigger_correct()
		GameEnums.InputOutcome.WRONG:
			_audio.play_wrong()
			_haptics.trigger_wrong()
		GameEnums.InputOutcome.TIMEOUT:
			_audio.play_timeout()
			_haptics.trigger_wrong()


func _on_state_updated(state: RoundState) -> void:
	if state.status == GameEnums.RoundStatus.ACTIVE:
		_sync_gameplay_hud(state)
		_gameplay.update_prompt_timer(_controller.get_remaining_prompt_window())


func _sync_gameplay_hud(state: RoundState) -> void:
	_gameplay.update_hud(
		state.mode,
		state.score,
		state.lives,
		state.max_lives,
		state.remaining_time,
		state.current_streak
	)


func _on_round_ended(result: SessionResult) -> void:
	_last_result = result
	var is_new_best := _records.apply_session(result)
	_save_service.save_records(_records)
	_refresh_score_views()
	if is_new_best:
		_audio.play_record()

	_router.navigate_to("result")
	_result.display_result({
		"mode": result.mode,
		"score": result.score,
		"best_score": _records.get_best_for_mode(result.mode),
		"accuracy": result.accuracy,
		"best_streak": result.best_streak,
		"correct_count": result.correct_count,
		"wrong_count": result.incorrect_count,
		"timeout_count": result.timeout_count,
		"is_new_record": is_new_best,
	})


func _on_pause_requested() -> void:
	_controller.pause_game()
	_router.show_pause_overlay(true)


func _on_resume_requested() -> void:
	_router.show_pause_overlay(false)
	_controller.resume_game()


func _handle_app_interruption() -> void:
	if _controller.state.status == GameEnums.RoundStatus.ACTIVE or _controller.state.status == GameEnums.RoundStatus.COUNTDOWN:
		_controller.pause_game()
		if _router.get_current_screen_id() == "gameplay":
			_router.show_pause_overlay(true)


func _on_share_requested() -> void:
	var msg := ShareService.share_result(_last_result)
	if not msg.is_empty():
		_result.show_share_feedback(msg)


func _on_settings_changed(sound_enabled: bool, haptics_enabled: bool, reduced_motion: bool) -> void:
	_settings.sound_enabled = sound_enabled
	_settings.haptics_enabled = haptics_enabled
	_settings.reduced_motion = reduced_motion
	_save_service.save_settings(_settings)
	_apply_settings_to_ui()
	_audio.play_tap()


func _apply_settings_to_ui() -> void:
	_audio.enabled = _settings.sound_enabled
	_haptics.enabled = _settings.haptics_enabled
	_router.set_reduced_motion(_settings.reduced_motion)
	_countdown.set_reduced_motion(_settings.reduced_motion)
	_gameplay.set_reduced_motion(_settings.reduced_motion)
	_settings_screen.set_values(_settings.sound_enabled, _settings.haptics_enabled, _settings.reduced_motion)


func _refresh_score_views() -> void:
	_home.set_best_scores(_records.classic_best, _records.rush_best)
	_mode_select.set_best_scores(_records.classic_best, _records.rush_best)
	var recent_dicts: Array = []
	for item in _records.recent_results:
		recent_dicts.append(item.to_dict())
	_best_scores.set_records(
		_records.classic_best,
		_records.classic_best_streak,
		_records.rush_best,
		_records.rush_best_streak,
		recent_dicts
	)
