class_name RoundState
extends RefCounted
## Live mutable state for an active, paused, or completed round.

var mode: int = GameEnums.GameMode.CLASSIC
var status: int = GameEnums.RoundStatus.IDLE
var score: int = 0
var lives: int = 3
var max_lives: int = 3
var elapsed_time: float = 0.0
var remaining_time: float = 0.0
var current_streak: int = 0
var best_streak: int = 0
var correct_count: int = 0
var incorrect_count: int = 0
var timeout_count: int = 0
var current_prompt: DirectionPrompt = null


static func create_for_config(config: GameConfig) -> RoundState:
	var st := RoundState.new()
	st.mode = config.mode
	st.status = GameEnums.RoundStatus.IDLE
	st.score = 0
	st.lives = config.starting_lives if config.mode == GameEnums.GameMode.CLASSIC else 0
	st.max_lives = config.starting_lives
	st.elapsed_time = 0.0
	st.remaining_time = config.rush_duration_seconds if config.mode == GameEnums.GameMode.RUSH else 0.0
	return st
