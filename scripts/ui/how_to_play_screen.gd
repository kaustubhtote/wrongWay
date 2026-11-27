extends ScreenBase
## Interactive / clear How-To-Play tutorial screen explaining the opposite-direction rule.

signal tutorial_completed

@onready var _example_card: PanelContainer = %ExampleCard
@onready var _rules_card: PanelContainer = %RulesCard
@onready var _prompt_arrow: ArrowGlyph = %PromptArrow
@onready var _tap_arrow: ArrowGlyph = %TapArrow
@onready var _up_arrow: ArrowGlyph = %UpArrow
@onready var _down_arrow: ArrowGlyph = %DownArrow
@onready var _got_it_btn: Button = %GotItButton

var _return_screen: String = "home"


func _ready() -> void:
	_example_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 20, 2, 0.16))
	_rules_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_SECONDARY, NeonTheme.VIOLET, 20, 2, 0.14))

	_prompt_arrow.direction = GameEnums.Direction.LEFT
	_prompt_arrow.arrow_color = NeonTheme.ERROR_CORAL
	_tap_arrow.direction = GameEnums.Direction.RIGHT
	_tap_arrow.arrow_color = NeonTheme.CORRECT_GREEN
	_up_arrow.direction = GameEnums.Direction.UP
	_up_arrow.arrow_color = NeonTheme.CYAN
	_down_arrow.direction = GameEnums.Direction.DOWN
	_down_arrow.arrow_color = NeonTheme.CORRECT_GREEN

	NeonTheme.apply_neon_button(_got_it_btn, NeonTheme.CORRECT_GREEN, NeonTheme.PANEL_SECONDARY, 26)
	_got_it_btn.pressed.connect(_on_got_it)


func on_enter(params: Dictionary = {}) -> void:
	_return_screen = str(params.get("return_to", "home"))


func _on_got_it() -> void:
	tutorial_completed.emit()
	navigate_requested.emit(_return_screen, {})
