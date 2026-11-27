extends ScreenBase
## Pre-round 3-2-1 countdown screen (does not consume game clock).

@onready var _mode_label: Label = %ModeLabel
@onready var _count_card: PanelContainer = %CountCard
@onready var _count_label: Label = %CountLabel
@onready var _tip_label: Label = %TipLabel

var _reduced_motion: bool = false


func _ready() -> void:
	_count_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 28, 3, 0.24))
	_mode_label.add_theme_color_override("font_color", NeonTheme.VIOLET)
	_count_label.add_theme_color_override("font_color", NeonTheme.CYAN)
	_tip_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)


func set_reduced_motion(enabled: bool) -> void:
	_reduced_motion = enabled


func set_mode(mode: int) -> void:
	if is_node_ready():
		_mode_label.text = GameEnums.mode_to_label(mode)


func set_countdown_value(seconds_left: int) -> void:
	if not is_node_ready():
		return
	_count_label.text = str(maxi(1, seconds_left))
	if not _reduced_motion:
		_count_label.pivot_offset = _count_label.size * 0.5
		_count_label.scale = Vector2(1.18, 1.18)
		var tween := create_tween()
		tween.tween_property(_count_label, "scale", Vector2.ONE, 0.22)
