extends Control
## Modal pause overlay freezing gameplay and offering Resume, Restart, How To Play, and Home.

signal resume_requested
signal restart_requested
signal how_to_play_requested
signal home_requested

@onready var _panel: PanelContainer = %PausePanel
@onready var _resume_btn: Button = %ResumeButton
@onready var _restart_btn: Button = %RestartButton
@onready var _how_btn: Button = %HowToPlayButton
@onready var _home_btn: Button = %HomeButton


func _ready() -> void:
	_panel.add_theme_stylebox_override("panel", NeonTheme.make_panel_style(NeonTheme.PANEL_PRIMARY, NeonTheme.CYAN, 24, 2, 0.22))
	NeonTheme.apply_neon_button(_resume_btn, NeonTheme.CORRECT_GREEN, NeonTheme.PANEL_SECONDARY, 26)
	NeonTheme.apply_neon_button(_restart_btn, NeonTheme.CYAN, NeonTheme.PANEL_SECONDARY, 22)
	NeonTheme.apply_neon_button(_how_btn, NeonTheme.VIOLET, NeonTheme.PANEL_PRIMARY, 22)
	NeonTheme.apply_neon_button(_home_btn, NeonTheme.ERROR_CORAL, NeonTheme.PANEL_PRIMARY, 22)

	_resume_btn.pressed.connect(request_resume)
	_restart_btn.pressed.connect(func(): restart_requested.emit())
	_how_btn.pressed.connect(func(): how_to_play_requested.emit())
	_home_btn.pressed.connect(func(): home_requested.emit())


func request_resume() -> void:
	resume_requested.emit()
