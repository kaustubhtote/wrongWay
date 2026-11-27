extends ScreenBase
## Post-round summary screen displaying score, accuracy, best score, streak, and actions.

signal replay_requested(mode: int)
signal share_requested

@onready var _card: PanelContainer = %SummaryCard
@onready var _mode_label: Label = %ModeLabel
@onready var _record_badge: Label = %RecordBadge
@onready var _score_label: Label = %ScoreLabel
@onready var _best_label: Label = %BestLabel
@onready var _accuracy_label: Label = %AccuracyLabel
@onready var _streak_label: Label = %StreakLabel
@onready var _breakdown_label: Label = %BreakdownLabel
@onready var _share_feedback: Label = %ShareFeedbackLabel
@onready var _replay_btn: Button = %ReplayButton
@onready var _share_btn: Button = %ShareButton
@onready var _home_btn: Button = %HomeButton

var _last_mode: int = GameEnums.GameMode.CLASSIC


func _ready() -> void:
	_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 24, 2, 0.18))
	_mode_label.add_theme_color_override("font_color", NeonTheme.VIOLET)
	_record_badge.add_theme_color_override("font_color", NeonTheme.CORRECT_GREEN)
	_score_label.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
	_best_label.add_theme_color_override("font_color", NeonTheme.CYAN)
	_breakdown_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	_share_feedback.add_theme_color_override("font_color", NeonTheme.CORRECT_GREEN)

	NeonTheme.apply_neon_button(_replay_btn, NeonTheme.CYAN, NeonTheme.PANEL_SECONDARY, 26)
	NeonTheme.apply_neon_button(_share_btn, NeonTheme.VIOLET, NeonTheme.PANEL_PRIMARY, 22)
	NeonTheme.apply_neon_button(_home_btn, NeonTheme.TEXT_MUTED, NeonTheme.PANEL_PRIMARY, 22)

	_replay_btn.pressed.connect(func(): replay_requested.emit(_last_mode))
	_share_btn.pressed.connect(func(): share_requested.emit())
	_home_btn.pressed.connect(func(): navigate_requested.emit("home", {}))


func display_result(data: Dictionary) -> void:
	_last_mode = int(data.get("mode", GameEnums.GameMode.CLASSIC))
	var score := int(data.get("score", 0))
	var best_score := int(data.get("best_score", score))
	var accuracy := float(data.get("accuracy", 0.0))
	var best_streak := int(data.get("best_streak", 0))
	var correct := int(data.get("correct_count", 0))
	var wrong := int(data.get("wrong_count", 0))
	var timeouts := int(data.get("timeout_count", 0))
	var is_new_record := bool(data.get("is_new_record", false))

	if not is_node_ready():
		return
	_mode_label.text = "%s RESULT" % GameEnums.mode_to_label(_last_mode)
	_record_badge.visible = is_new_record
	_score_label.text = str(score)
	_best_label.text = "BEST SCORE: %d" % best_score
	_accuracy_label.text = "ACCURACY: %.1f%%" % accuracy
	_streak_label.text = "LONGEST STREAK: %d" % best_streak
	_breakdown_label.text = "Correct: %d   •   Wrong: %d   •   Timeout: %d" % [correct, wrong, timeouts]
	_share_feedback.text = ""


func show_share_feedback(message: String) -> void:
	if is_node_ready():
		_share_feedback.text = message
