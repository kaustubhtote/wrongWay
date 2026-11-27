class_name SafeAreaMargin
extends MarginContainer
## Applies Android/iOS display cutout & system bar safe-area insets plus base padding.

@export var base_left: int = 24
@export var base_top: int = 20
@export var base_right: int = 24
@export var base_bottom: int = 24


func _ready() -> void:
	_apply_safe_area()
	get_tree().root.size_changed.connect(_apply_safe_area)


func _apply_safe_area() -> void:
	var safe_rect: Rect2i = DisplayServer.get_display_safe_area()
	var win_size: Vector2i = DisplayServer.window_get_size()
	var left_inset := 0
	var top_inset := 0
	var right_inset := 0
	var bottom_inset := 0

	if win_size.x > 0 and win_size.y > 0 and safe_rect.size.x > 0 and safe_rect.size.y > 0:
		var vp_size := get_viewport_rect().size
		if vp_size.x <= 0.0:
			vp_size = Vector2(720.0, 1280.0)
		var scale_x := vp_size.x / float(win_size.x)
		var scale_y := vp_size.y / float(win_size.y)
		left_inset = maxi(0, int(round(float(safe_rect.position.x) * scale_x)))
		top_inset = maxi(0, int(round(float(safe_rect.position.y) * scale_y)))
		right_inset = maxi(0, int(round(float(win_size.x - safe_rect.end.x) * scale_x)))
		bottom_inset = maxi(0, int(round(float(win_size.y - safe_rect.end.y) * scale_y)))

	add_theme_constant_override("margin_left", base_left + mini(left_inset, 96))
	add_theme_constant_override("margin_top", base_top + mini(top_inset, 140))
	add_theme_constant_override("margin_right", base_right + mini(right_inset, 96))
	add_theme_constant_override("margin_bottom", base_bottom + mini(bottom_inset, 140))
