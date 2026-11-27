class_name DirectionPrompt
extends RefCounted
## Immutable-intent prompt issued to the player with a single-resolution guard.

var id: int = 0
var displayed_direction: int = GameEnums.Direction.UP
var correct_direction: int = GameEnums.Direction.DOWN
var created_elapsed: float = 0.0
var response_window: float = 1.8
var response_deadline: float = 1.8
var sequence_index: int = 0
var resolved: bool = false


func _init(
	p_id: int = 0,
	p_displayed: int = GameEnums.Direction.UP,
	p_correct: int = GameEnums.Direction.DOWN,
	p_created_elapsed: float = 0.0,
	p_response_window: float = 1.8,
	p_sequence_index: int = 0
) -> void:
	id = p_id
	displayed_direction = p_displayed
	correct_direction = p_correct
	created_elapsed = p_created_elapsed
	response_window = p_response_window
	response_deadline = p_created_elapsed + p_response_window
	sequence_index = p_sequence_index
	resolved = false
