extends ScreenBase
## Best Scores & Recent Sessions screen.

@onready var _bests_card: PanelContainer = %BestsCard
@onready var _classic_label: Label = %ClassicBestLabel
@onready var _rush_label: Label = %RushBestLabel
@onready var _recent_card: PanelContainer = %RecentCard
@onready var _recent_list: VBoxContainer = %RecentList
@onready var _empty_label: Label = %EmptyLabel
@onready var _back_btn: Button = %BackButton


func _ready() -> void:
	_bests_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 22, 2, 0.16))
	_recent_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.VIOLET, 22, 2, 0.14))
	_classic_label.add_theme_color_override("font_color", NeonTheme.CYAN)
	_rush_label.add_theme_color_override("font_color", NeonTheme.VIOLET)
	_empty_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	NeonTheme.apply_neon_button(_back_btn, NeonTheme.TEXT_MUTED, NeonTheme.PANEL_PRIMARY, 22)
	_back_btn.pressed.connect(func(): navigate_requested.emit("home", {}))


func set_records(classic_best: int, classic_streak: int, rush_best: int, rush_streak: int, recent_runs: Array) -> void:
	if not is_node_ready():
		return
	_classic_label.text = "CLASSIC BEST: %d   (Best Streak: %d)" % [classic_best, classic_streak]
	_rush_label.text = "60s RUSH BEST: %d   (Best Streak: %d)" % [rush_best, rush_streak]

	for child in _recent_list.get_children():
		child.queue_free()

	_empty_label.visible = recent_runs.is_empty()
	for entry in recent_runs:
		var lbl := Label.new()
		var mode_name := GameEnums.mode_to_label(int(entry.get("mode", GameEnums.GameMode.CLASSIC)))
		var sc := int(entry.get("score", 0))
		var acc := float(entry.get("accuracy", 0.0))
		var strk := int(entry.get("best_streak", 0))
		lbl.text = "%s  —  Score %d  •  %.0f%%  •  Streak %d" % [mode_name, sc, acc, strk]
		lbl.add_theme_font_size_override("font_size", 19)
		lbl.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
		_recent_list.add_child(lbl)
