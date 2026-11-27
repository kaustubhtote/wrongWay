class_name DifficultyService
extends RefCounted
## Computes fair, bounded prompt response windows based on player progress.


static func compute_response_window(correct_count: int, config: GameConfig) -> float:
	var safe_correct := maxi(0, correct_count)
	var base := maxf(config.min_response_window, config.base_response_window)
	var floor_win := maxf(0.1, config.min_response_window)
	var step := maxf(0.0, config.window_step_per_correct)
	var raw := base - (float(safe_correct) * step)
	return clampf(raw, floor_win, base)
