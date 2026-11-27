extends ScreenBase
## Splash screen displaying the neon WRONG WAY! emblem before transitioning to Home.

@onready var _card: PanelContainer = %SplashCard
@onready var _title: Label = %TitleLabel
@onready var _subtitle: Label = %SubtitleLabel
@onready var _hint: Label = %HintLabel
@onready var _left_arrow: ArrowGlyph = %LeftArrow
@onready var _right_arrow: ArrowGlyph = %RightArrow

var _timer: SceneTreeTimer = null
var _advanced: bool = false


func _ready() -> void:
	_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, Color(NeonTheme.CYAN.r, NeonTheme.CYAN.g, NeonTheme.CYAN.b, 0.45), 28, 2, 0.2))
	_title.add_theme_color_override("font_color", NeonTheme.TEXT_PRIMARY)
	_subtitle.add_theme_color_override("font_color", NeonTheme.CYAN)
	_hint.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	_left_arrow.direction = GameEnums.Direction.LEFT
	_left_arrow.arrow_color = NeonTheme.ERROR_CORAL
	_right_arrow.direction = GameEnums.Direction.RIGHT
	_right_arrow.arrow_color = NeonTheme.CYAN


func on_enter(_params: Dictionary = {}) -> void:
	_advanced = false
	_timer = get_tree().create_timer(1.1)
	_timer.timeout.connect(_advance)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance()
	elif event is InputEventScreenTouch and event.pressed:
		_advance()


func _advance() -> void:
	if _advanced or not visible:
		return
	_advanced = true
	navigate_requested.emit("home", {})
