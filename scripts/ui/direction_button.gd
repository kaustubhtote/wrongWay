class_name DirectionButton
extends Button
## Large neon directional touch control (64dp+ equivalent) with vector arrow and text label.

signal direction_pressed(direction: int)

@export var direction: int = GameEnums.Direction.UP:
	set(value):
		direction = value
		_sync_visuals()

@export var accent_color: Color = NeonTheme.CYAN:
	set(value):
		accent_color = value
		_sync_visuals()

var reduced_motion: bool = false

@onready var _arrow: ArrowGlyph = %ArrowGlyph
@onready var _label: Label = %DirectionLabel


func _ready() -> void:
	custom_minimum_size = Vector2(260, 152)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	focus_mode = Control.FOCUS_ALL
	pressed.connect(_on_pressed)
	_sync_visuals()


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled


func flash_feedback(is_correct: bool) -> void:
	var flash_col := NeonTheme.CORRECT_GREEN if is_correct else NeonTheme.ERROR_CORAL
	NeonTheme.apply_neon_button(self, flash_col, NeonTheme.PANEL_SECONDARY, 24)
	if _arrow:
		_arrow.arrow_color = flash_col
	if not reduced_motion:
		pivot_offset = size * 0.5
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.06)
		tween.tween_property(self, "scale", Vector2.ONE, 0.10)
	var timer := get_tree().create_timer(0.22)
	timer.timeout.connect(_sync_visuals)


func _on_pressed() -> void:
	direction_pressed.emit(direction)


func _sync_visuals() -> void:
	if not is_node_ready():
		return
	var dir_name := GameEnums.direction_to_label(direction)
	tooltip_text = "Tap %s" % dir_name
	NeonTheme.apply_neon_button(self, accent_color, NeonTheme.PANEL_SECONDARY, 24)
	if _arrow:
		_arrow.direction = direction
		_arrow.arrow_color = accent_color
	if _label:
		_label.text = dir_name
		_label.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
