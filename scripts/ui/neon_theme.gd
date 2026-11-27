class_name NeonTheme
## Centralized neon arcade color palette, typography sizing, and StyleBox builders.

const BG_DARK := Color("#070B18")
const PANEL_PRIMARY := Color("#111A2D")
const PANEL_SECONDARY := Color("#17243B")
const CYAN := Color("#43D9FF")
const VIOLET := Color("#A78BFA")
const CORRECT_GREEN := Color("#35F5A1")
const ERROR_CORAL := Color("#FF3D6E")
const TEXT_PRIMARY := Color("#F3F7FF")
const TEXT_MUTED := Color("#8EA1C1")


static func make_panel_style(
	bg_color: Color = PANEL_PRIMARY,
	border_color: Color = Color(CYAN.r, CYAN.g, CYAN.b, 0.35),
	corner_radius: int = 20,
	border_width: int = 2,
	glow_alpha: float = 0.14
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	if glow_alpha > 0.0:
		style.shadow_color = Color(border_color.r, border_color.g, border_color.b, glow_alpha)
		style.shadow_size = 12
		style.shadow_offset = Vector2(0, 4)
	return style


static func make_button_style(
	bg_color: Color = PANEL_SECONDARY,
	border_color: Color = CYAN,
	corner_radius: int = 18,
	border_width: int = 2,
	glow_alpha: float = 0.18
) -> StyleBoxFlat:
	var style := make_panel_style(bg_color, border_color, corner_radius, border_width, glow_alpha)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style


static func apply_neon_button(
	button: Button,
	accent: Color = CYAN,
	fill: Color = PANEL_SECONDARY,
	font_size: int = 24
) -> void:
	var normal := make_button_style(fill, Color(accent.r, accent.g, accent.b, 0.72), 18, 2, 0.16)
	var hover := make_button_style(fill.lightened(0.08), accent, 18, 2, 0.28)
	var pressed := make_button_style(accent.darkened(0.72), accent, 18, 3, 0.32)
	var disabled := make_button_style(PANEL_PRIMARY, Color(TEXT_MUTED.r, TEXT_MUTED.g, TEXT_MUTED.b, 0.3), 18, 1, 0.0)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_hover_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_pressed_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_focus_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_disabled_color", TEXT_MUTED)
	button.add_theme_font_size_override("font_size", font_size)


static func create_base_theme() -> Theme:
	var theme := Theme.new()
	theme.set_color("font_color", "Label", TEXT_PRIMARY)
	theme.set_font_size("font_size", "Label", 22)
	theme.set_stylebox("panel", "PanelContainer", make_panel_style())

	var btn_normal := make_button_style(PANEL_SECONDARY, Color(CYAN.r, CYAN.g, CYAN.b, 0.65))
	var btn_hover := make_button_style(PANEL_SECONDARY.lightened(0.08), CYAN, 18, 2, 0.25)
	var btn_pressed := make_button_style(PANEL_PRIMARY, VIOLET, 18, 3, 0.28)
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("focus", "Button", btn_hover)
	theme.set_color("font_color", "Button", TEXT_PRIMARY)
	theme.set_font_size("font_size", "Button", 24)
	return theme
