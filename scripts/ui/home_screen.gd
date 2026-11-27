extends ScreenBase
## Home hub screen with primary Play CTA and secondary navigation.

@onready var _hero_card: PanelContainer = %HeroCard
@onready var _title_label: Label = %TitleLabel
@onready var _rule_label: Label = %RuleLabel
@onready var _best_summary_label: Label = %BestSummaryLabel
@onready var _left_arrow: ArrowGlyph = %LeftArrow
@onready var _right_arrow: ArrowGlyph = %RightArrow
@onready var _play_btn: Button = %PlayButton
@onready var _how_btn: Button = %HowToPlayButton
@onready var _scores_btn: Button = %BestScoresButton
@onready var _settings_btn: Button = %SettingsButton

var _classic_best: int = 0
var _rush_best: int = 0


func _ready() -> void:
	_hero_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, Color(NeonTheme.CYAN.r, NeonTheme.CYAN.g, NeonTheme.CYAN.b, 0.4), 24, 2, 0.18))
	_title_label.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
	_rule_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	_best_summary_label.add_theme_color_override("font_color", NeonTheme.CYAN)
	_left_arrow.direction = GameEnums.Direction.LEFT
	_left_arrow.arrow_color = NeonTheme.ERROR_CORAL
	_right_arrow.direction = GameEnums.Direction.RIGHT
	_right_arrow.arrow_color = NeonTheme.CORRECT_GREEN

	NeonTheme.apply_neon_button(_play_btn, NeonTheme.CYAN, NeonTheme.PANEL_SECONDARY, 30)
	NeonTheme.apply_neon_button(_how_btn, NeonTheme.VIOLET, NeonTheme.PANEL_PRIMARY, 22)
	NeonTheme.apply_neon_button(_scores_btn, NeonTheme.CYAN, NeonTheme.PANEL_PRIMARY, 22)
	NeonTheme.apply_neon_button(_settings_btn, NeonTheme.TEXT_MUTED, NeonTheme.PANEL_PRIMARY, 22)

	_play_btn.pressed.connect(func(): navigate_requested.emit("mode_select", {}))
	_how_btn.pressed.connect(func(): navigate_requested.emit("how_to_play", {}))
	_scores_btn.pressed.connect(func(): navigate_requested.emit("best_scores", {}))
	_settings_btn.pressed.connect(func(): navigate_requested.emit("settings", {}))
	_refresh_summary()


func set_best_scores(classic_best: int, rush_best: int) -> void:
	_classic_best = classic_best
	_rush_best = rush_best
	if is_node_ready():
		_refresh_summary()


func on_enter(_params: Dictionary = {}) -> void:
	_refresh_summary()


func _refresh_summary() -> void:
	_best_summary_label.text = "CLASSIC BEST: %d   |   60s RUSH BEST: %d" % [_classic_best, _rush_best]
