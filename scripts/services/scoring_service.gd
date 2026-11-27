class_name ScoringService
extends RefCounted
## Pure scoring, lives, streak, accuracy, and round-end evaluation rules.


static func compute_accuracy(correct_count: int, incorrect_count: int, timeout_count: int) -> float:
	var total := maxi(0, correct_count) + maxi(0, incorrect_count) + maxi(0, timeout_count)
	if total <= 0:
		return 0.0
	return (float(correct_count) / float(total)) * 100.0


static func apply_correct(state: RoundState, config: GameConfig) -> void:
	state.score += maxi(1, config.points_per_correct)
	state.current_streak += 1
	state.best_streak = maxi(state.best_streak, state.current_streak)
	state.correct_count += 1


static func apply_wrong(state: RoundState, config: GameConfig) -> void:
	state.current_streak = 0
	state.incorrect_count += 1
	_apply_mistake_penalty(state, config)


static func apply_timeout(state: RoundState, config: GameConfig) -> void:
	state.current_streak = 0
	state.timeout_count += 1
	_apply_mistake_penalty(state, config)


static func _apply_mistake_penalty(state: RoundState, config: GameConfig) -> void:
	if state.mode == GameEnums.GameMode.CLASSIC:
		state.lives = maxi(0, state.lives - 1)
	else:
		state.score = maxi(0, state.score - maxi(0, config.rush_wrong_penalty))


static func should_end_round(state: RoundState, _config: GameConfig) -> bool:
	if state.mode == GameEnums.GameMode.CLASSIC:
		return state.lives <= 0
	return state.remaining_time <= 0.0
