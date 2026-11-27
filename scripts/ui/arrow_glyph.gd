class_name ArrowGlyph
extends Control
## Crisp vector-drawn directional arrow with subtle layered neon glow.

@export var direction: int = GameEnums.Direction.UP:
	set(value):
		direction = value
		queue_redraw()

@export var arrow_color: Color = NeonTheme.CYAN:
	set(value):
		arrow_color = value
		queue_redraw()

@export var glow_enabled: bool = true:
	set(value):
		glow_enabled = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var s := size
	var side := minf(s.x, s.y)
	if side <= 4.0:
		return
	var center := s * 0.5
	var r := side * 0.36

	# Base arrow polygon pointing UP around origin.
	var pts := PackedVector2Array([
		Vector2(0.0, -r),
		Vector2(r * 0.85, -r * 0.05),
		Vector2(r * 0.34, -r * 0.05),
		Vector2(r * 0.34, r * 0.92),
		Vector2(-r * 0.34, r * 0.92),
		Vector2(-r * 0.34, -r * 0.05),
		Vector2(-r * 0.85, -r * 0.05),
	])

	var angle := 0.0
	match direction:
		GameEnums.Direction.UP:
			angle = 0.0
		GameEnums.Direction.RIGHT:
			angle = PI * 0.5
		GameEnums.Direction.DOWN:
			angle = PI
		GameEnums.Direction.LEFT:
			angle = -PI * 0.5

	var transformed := PackedVector2Array()
	transformed.resize(pts.size())
	for i in pts.size():
		transformed[i] = center + pts[i].rotated(angle)

	if glow_enabled:
		var glow_outer := Color(arrow_color.r, arrow_color.g, arrow_color.b, 0.16)
		var glow_inner := Color(arrow_color.r, arrow_color.g, arrow_color.b, 0.32)
		var closed := PackedVector2Array(transformed)
		closed.append(transformed[0])
		draw_polyline(closed, glow_outer, maxf(6.0, side * 0.12), true)
		draw_polyline(closed, glow_inner, maxf(3.0, side * 0.06), true)

	draw_colored_polygon(transformed, arrow_color)
