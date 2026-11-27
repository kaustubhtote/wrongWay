extends ScreenBase
## Mode selection screen for Classic (3 lives) and 60-Second Rush.

signal mode_selected(mode: int)

@onready var _header_label: Label = %HeaderLabel
@onready var _sub_label: Label = %SubLabel
@onready var _classic_card: PanelContainer = %ClassicCard
@onready var _classic_best_label: Label = %ClassicBestLabel
@onready var _classic_btn: Button = %ClassicPlayButton
@onready var _rush_card: PanelContainer = %RushCard
@onready var _rush_best_label: Label = %RushBestLabel
@onready var _rush_btn: Button = %RushPlayButton
@onready var _back_btn: Button = %BackButton

var _classic_best: int = 0
var _rush_best: int = 0


func _ready() -> void:
	_header_label.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
	_sub_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	_classic_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 22, 2, 0.16))
	_rush_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.VIOLET, 22, 2, 0.16))
	_classic_best_label.add_theme_color_override("font_color", NeonTheme.CYAN)
	_rush_best_label.add_theme_color_override("font_color", NeonTheme.VIOLET)

	NeonTheme.apply_neon_button(_classic_btn, NeonTheme.CYAN, NeonTheme.PANEL_SECONDARY, 24)
	NeonTheme.apply_neon_button(_rush_btn, NeonTheme.VIOLET, NeonTheme.PANEL_SECONDARY, 24)
	NeonTheme.apply_neon_button(_back_btn, NeonTheme.TEXT_MUTED, NeonTheme.PANEL_PRIMARY, 22)

	_classic_btn.pressed.connect(func(): mode_selected.emit(GameEnums.GameMode.CLASSIC))
	_rush_btn.pressed.connect(func(): mode_selected.emit(GameEnums.GameMode.RUSH))
	_back_btn.pressed.connect(func(): navigate_requested.emit("home", {}))
	_refresh_labels()


func set_best_scores(classic_best: int, rush_best: int) -> void:
	_classic_best = classic_best
	_rush_best = rush_best
	if is_node_ready():
		_refresh_labels()


func on_enter(_params: Dictionary = {}) -> void:
	_refresh_labels()


func _refresh_labels() -> void:
	_classic_best_label.text = "BEST SCORE: %d" % _classic_best
	_rush_best_label.text = "BEST SCORE: %d" % _rush_best
