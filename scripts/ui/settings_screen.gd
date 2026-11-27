extends ScreenBase
## Settings screen for sound, haptics, reduced motion, tutorial replay, and app info.

signal settings_changed(sound_enabled: bool, haptics_enabled: bool, reduced_motion: bool)

@onready var _card: PanelContainer = %SettingsCard
@onready var _sound_toggle: CheckButton = %SoundToggle
@onready var _haptics_toggle: CheckButton = %HapticsToggle
@onready var _motion_toggle: CheckButton = %ReducedMotionToggle
@onready var _tutorial_btn: Button = %ReplayTutorialButton
@onready var _version_label: Label = %VersionLabel
@onready var _back_btn: Button = %BackButton

var _suppress_signals: bool = false


func _ready() -> void:
	_card.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 22, 2, 0.16))
	_version_label.add_theme_color_override("font_color", NeonTheme.TEXT_MUTED)
	NeonTheme.apply_neon_button(_tutorial_btn, NeonTheme.VIOLET, NeonTheme.PANEL_SECONDARY, 22)
	NeonTheme.apply_neon_button(_back_btn, NeonTheme.TEXT_MUTED, NeonTheme.PANEL_PRIMARY, 22)

	_sound_toggle.toggled.connect(_on_any_toggle)
	_haptics_toggle.toggled.connect(_on_any_toggle)
	_motion_toggle.toggled.connect(_on_any_toggle)
	_tutorial_btn.pressed.connect(func(): navigate_requested.emit("how_to_play", {"return_to": "settings"}))
	_back_btn.pressed.connect(func(): navigate_requested.emit("home", {}))

	var ver := str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	_version_label.text = "WRONG WAY! v%s  •  100%% Offline  •  No Ads" % ver


func set_values(sound_enabled: bool, haptics_enabled: bool, reduced_motion: bool) -> void:
	if not is_node_ready():
		return
	_suppress_signals = true
	_sound_toggle.button_pressed = sound_enabled
	_haptics_toggle.button_pressed = haptics_enabled
	_motion_toggle.button_pressed = reduced_motion
	_suppress_signals = false


func _on_any_toggle(_pressed: bool) -> void:
	if _suppress_signals:
		return
	settings_changed.emit(
		_sound_toggle.button_pressed,
		_haptics_toggle.button_pressed,
		_motion_toggle.button_pressed
	)
