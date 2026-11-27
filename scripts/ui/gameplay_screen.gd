extends ScreenBase
## Gameplay presentation screen: HUD, centre prompt card, deadline bar, and 2x2 controls.

signal direction_submitted(direction: int)
signal pause_requested

@onready var _hud_card: PanelContainer = %HudCard
@onready var _mode_label: Label = %ModeLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _status_label: Label = %StatusLabel
@onready var _streak_label: Label = %StreakLabel
@onready var _pause_btn: Button = %PauseButton

@onready var _prompt_card: PanelContainer = %PromptCard
@onready var _prompt_hint: Label = %PromptHintLabel
@onready var _prompt_arrow: ArrowGlyph = %PromptArrow
@onready var _prompt_word: Label = %PromptWordLabel
@onready var _window_bar: ProgressBar = %WindowBar
@onready var _feedback_label: Label = %FeedbackLabel

@onready var _btn_up: DirectionButton = $SafeArea/VBox/ButtonGrid/BtnUp
@onready var _btn_down: DirectionButton = $SafeArea/VBox/ButtonGrid/BtnDown
@onready var _btn_left: DirectionButton = $SafeArea/VBox/ButtonGrid/BtnLeft
@onready var _btn_right: DirectionButton = $SafeArea/VBox/ButtonGrid/BtnRight

var _reduced_motion: bool = false
var _buttons_by_dir: Dictionary = {}


func _ready() -> void:
	_hud_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, Color(NeonTheme.CYAN.r, NeonTheme.CYAN.g, NeonTheme.CYAN.b, 0.35), 18, 2, 0.12))
	_prompt_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.VIOLET, 26, 3, 0.22))
	NeonTheme.apply_neon_button(_pause_btn, NeonTheme.TEXT_MUTED, NeonTheme.PANEL_SECONDARY, 22)

	_mode_label.add_theme_color_override("font_color", NeonTheme.VIOLET)
	_score_label.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
	_status_label.add_theme_color_override("font_color", NeonTheme.CYAN)
	_streak_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	_prompt_hint.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	_prompt_word.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
	_feedback_label.text = ""

	_setup_progress_bar()

	_btn_up.direction = GameEnums.Direction.UP
	_btn_up.accent_color = NeonTheme.CYAN
	_btn_down.direction = GameEnums.Direction.DOWN
	_btn_down.accent_color = NeonTheme.CYAN
	_btn_left.direction = GameEnums.Direction.LEFT
	_btn_left.accent_color = NeonTheme.VIOLET
	_btn_right.direction = GameEnums.Direction.RIGHT
	_btn_right.accent_color = NeonTheme.VIOLET

	_buttons_by_dir = {
		GameEnums.Direction.UP: _btn_up,
		GameEnums.Direction.DOWN: _btn_down,
		GameEnums.Direction.LEFT: _btn_left,
		GameEnums.Direction.RIGHT: _btn_right,
	}

	for btn in _buttons_by_dir.values():
		btn.direction_pressed.connect(_on_direction_pressed)

	_pause_btn.pressed.connect(func(): pause_requested.emit())


func _setup_progress_bar() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = NeonTheme.PANEL_SECONDARY
	bg.set_corner_radius_all(8)
	var fill := StyleBoxFlat.new()
	fill.bg_color = NeonTheme.CYAN
	fill.set_corner_radius_all(8)
	_window_bar.add_theme_stylebox_override("background", bg)
	_window_bar.add_theme_stylebox_override("fill", fill)


func set_reduced_motion(enabled: bool) -> void:
	_reduced_motion = enabled
	for btn in _buttons_by_dir.values():
		btn.set_reduced_motion(enabled)


func handle_back() -> bool:
	pause_requested.emit()
	return true


func update_hud(mode: int, score: int, lives: int, max_lives: int, remaining_time: float, streak: int) -> void:
	if not is_node_ready():
		return
	_mode_label.text = GameEnums.mode_to_label(mode)
	_score_label.text = "SCORE: %d" % score
	_streak_label.text = "STREAK: %d" % streak
	if mode == GameEnums.GameMode.CLASSIC:
		var hearts := ""
		for i in max_lives:
			hearts += "♥ " if i < lives else "♡ "
		_status_label.text = "LIVES: %s" % hearts.strip_edges()
		_status_label.add_theme_color_override("font_color", NeonTheme.ERROR_CORAL if lives <= 1 else NeonTheme.CYAN)
	else:
		_status_label.text = "TIME: %.1fs" % maxf(0.0, remaining_time)
		_status_label.add_theme_color_override("font_color", NeonTheme.ERROR_CORAL if remaining_time <= 10.0 else NeonTheme.CYAN)


func show_prompt(displayed_dir: int, window_duration: float) -> void:
	if not is_node_ready():
		return
	_prompt_arrow.direction = displayed_dir
	_prompt_arrow.arrow_color = NeonTheme.CYAN
	_prompt_word.text = GameEnums.direction_to_label(displayed_dir)
	_window_bar.max_value = maxf(0.01, window_duration)
	_window_bar.value = window_duration

	if not _reduced_motion:
		_prompt_card.pivot_offset = _prompt_card.size * 0.5
		_prompt_card.scale = Vector2(0.95, 0.95)
		var tween := create_tween()
		tween.tween_property(_prompt_card, "scale", Vector2.ONE, 0.10)


func update_prompt_timer(remaining_window: float) -> void:
	if is_node_ready():
		_window_bar.value = maxf(0.0, remaining_window)


func show_feedback(outcome: int, expected_dir: int, tapped_dir: int = -1) -> void:
	if not is_node_ready():
		return
	var expected_name := GameEnums.direction_to_label(expected_dir)
	match outcome:
		GameEnums.InputOutcome.CORRECT:
			_feedback_label.text = "✓ CORRECT! +1"
			_feedback_label.add_theme_color_override("font_color", NeonTheme.CORRECT_GREEN)
			_flash_prompt_border(NeonTheme.CORRECT_GREEN)
			if _buttons_by_dir.has(tapped_dir):
				_buttons_by_dir[tapped_dir].flash_feedback(true)
		GameEnums.InputOutcome.WRONG:
			_feedback_label.text = "✕ WRONG! Tap %s" % expected_name
			_feedback_label.add_theme_color_override("font_color", NeonTheme.ERROR_CORAL)
			_flash_prompt_border(NeonTheme.ERROR_CORAL)
			if _buttons_by_dir.has(tapped_dir):
				_buttons_by_dir[tapped_dir].flash_feedback(false)
		GameEnums.InputOutcome.TIMEOUT:
			_feedback_label.text = "⏱ TIME OUT! Tap %s" % expected_name
			_feedback_label.add_theme_color_override("font_color", NeonTheme.ERROR_CORAL)
			_flash_prompt_border(NeonTheme.ERROR_CORAL)


func clear_feedback() -> void:
	if is_node_ready():
		_feedback_label.text = ""
		_prompt_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.VIOLET, 26, 3, 0.22))


func _flash_prompt_border(color: Color) -> void:
	_prompt_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, color, 26, 3, 0.28))
	var timer := get_tree().create_timer(0.24)
	timer.timeout.connect(func():
		if is_instance_valid(_prompt_card):
			_prompt_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.VIOLET, 26, 3, 0.22))
	)


func _on_direction_pressed(dir: int) -> void:
	direction_submitted.emit(dir)
