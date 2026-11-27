class_name GameConfig
extends Resource
## Configuration parameters for Classic and 60-Second Rush rounds.

@export var mode: int = GameEnums.GameMode.CLASSIC
@export var starting_lives: int = 3
@export var rush_duration_seconds: float = 60.0
@export var base_response_window: float = 1.8
@export var min_response_window: float = 0.75
@export var window_step_per_correct: float = 0.02
@export var points_per_correct: int = 1
@export var rush_wrong_penalty: int = 1
@export var max_consecutive_repeats: int = 2
@export var countdown_seconds: int = 3
@export var countdown_step_duration: float = 0.7


static func create_classic() -> GameConfig:
	var cfg := GameConfig.new()
	cfg.mode = GameEnums.GameMode.CLASSIC
	return cfg


static func create_rush() -> GameConfig:
	var cfg := GameConfig.new()
	cfg.mode = GameEnums.GameMode.RUSH
	return cfg
