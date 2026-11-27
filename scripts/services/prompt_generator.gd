class_name PromptGenerator
extends RefCounted
## Generates opposite-direction prompts with repeat limiting and deterministic RNG injection.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _max_consecutive_repeats: int = 2
var _last_displayed: int = -1
var _consecutive_count: int = 0
var _next_id: int = 1


func _init(max_consecutive_repeats: int = 2, seed_value: int = -1) -> void:
	_max_consecutive_repeats = maxi(1, max_consecutive_repeats)
	if seed_value >= 0:
		set_seed(seed_value)
	else:
		_rng.randomize()


func set_seed(seed_value: int) -> void:
	_rng.seed = seed_value
	reset_history()


func reset_history() -> void:
	_last_displayed = -1
	_consecutive_count = 0
	_next_id = 1


static func get_opposite_direction(direction: int) -> int:
	match direction:
		GameEnums.Direction.UP:
			return GameEnums.Direction.DOWN
		GameEnums.Direction.DOWN:
			return GameEnums.Direction.UP
		GameEnums.Direction.LEFT:
			return GameEnums.Direction.RIGHT
		GameEnums.Direction.RIGHT:
			return GameEnums.Direction.LEFT
		_:
			push_error("PromptGenerator: invalid direction %d" % direction)
			return GameEnums.Direction.UP


func next_prompt(sequence_index: int, created_elapsed: float, response_window: float) -> DirectionPrompt:
	var candidates: Array[int] = []
	for dir in GameEnums.ALL_DIRECTIONS:
		if dir == _last_displayed and _consecutive_count >= _max_consecutive_repeats:
			continue
		candidates.append(dir)

	var idx := _rng.randi_range(0, candidates.size() - 1)
	var displayed: int = candidates[idx]
	if displayed == _last_displayed:
		_consecutive_count += 1
	else:
		_last_displayed = displayed
		_consecutive_count = 1

	var opposite := get_opposite_direction(displayed)
	var prompt := DirectionPrompt.new(_next_id, displayed, opposite, created_elapsed, response_window, sequence_index)
	_next_id += 1
	return prompt
