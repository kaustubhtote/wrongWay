class_name GameController
extends Node
## Manages round lifecycle, countdown, prompt deadlines, single-resolution input, and pause freeze.

signal countdown_tick(seconds_left: int)
signal countdown_finished
signal round_started(state: RoundState)
signal prompt_issued(prompt: DirectionPrompt)
signal prompt_resolved(outcome: int, prompt: DirectionPrompt, tapped_direction: int, state: RoundState)
signal state_updated(state: RoundState)
signal round_ended(result: SessionResult)
signal pause_changed(is_paused: bool)

var config: GameConfig = GameConfig.create_classic()
var state: RoundState = RoundState.new()
var _prompt_generator: PromptGenerator = PromptGenerator.new()
var _countdown_remaining: float = 0.0
var _last_countdown_int: int = 0
var _sequence_index: int = 0
var _status_before_pause: int = GameEnums.RoundStatus.IDLE
var _session_counter: int = 0


func _process(delta: float) -> void:
	step(delta)


func start_round(p_config: GameConfig, rng_seed: int = -1, skip_countdown: bool = false) -> void:
	config = p_config
	state = RoundState.create_for_config(config)
	_prompt_generator = PromptGenerator.new(config.max_consecutive_repeats, rng_seed)
	_sequence_index = 0
	_status_before_pause = GameEnums.RoundStatus.IDLE

	if skip_countdown or config.countdown_seconds <= 0:
		_begin_active_play()
	else:
		state.status = GameEnums.RoundStatus.COUNTDOWN
		_countdown_remaining = float(config.countdown_seconds) * config.countdown_step_duration
		_last_countdown_int = config.countdown_seconds
		countdown_tick.emit(_last_countdown_int)
		state_updated.emit(state)


func step(delta: float) -> void:
	if delta <= 0.0:
		return

	if state.status == GameEnums.RoundStatus.COUNTDOWN:
		_countdown_remaining -= delta
		if _countdown_remaining <= 0.0:
			countdown_finished.emit()
			_begin_active_play()
		else:
			var step_dur := maxf(0.05, config.countdown_step_duration)
			var whole := int(ceil(_countdown_remaining / step_dur))
			whole = clampi(whole, 1, config.countdown_seconds)
			if whole != _last_countdown_int:
				_last_countdown_int = whole
				countdown_tick.emit(whole)
		return

	if state.status != GameEnums.RoundStatus.ACTIVE:
		return

	state.elapsed_time += delta
	if state.mode == GameEnums.GameMode.RUSH:
		state.remaining_time = maxf(0.0, config.rush_duration_seconds - state.elapsed_time)
		if ScoringService.should_end_round(state, config):
			state_updated.emit(state)
			_finish_round()
			return

	if state.current_prompt != null and not state.current_prompt.resolved:
		if state.elapsed_time >= state.current_prompt.response_deadline:
			_resolve_timeout()
			return

	state_updated.emit(state)


func submit_direction(tapped_direction: int, expected_prompt_id: int = -1) -> int:
	if state.status != GameEnums.RoundStatus.ACTIVE:
		return GameEnums.InputOutcome.IGNORED
	var prompt := state.current_prompt
	if prompt == null or prompt.resolved:
		return GameEnums.InputOutcome.IGNORED
	if expected_prompt_id >= 0 and prompt.id != expected_prompt_id:
		return GameEnums.InputOutcome.IGNORED
	if state.elapsed_time > prompt.response_deadline:
		return GameEnums.InputOutcome.IGNORED
	if not (tapped_direction in GameEnums.ALL_DIRECTIONS):
		return GameEnums.InputOutcome.IGNORED

	prompt.resolved = true
	var outcome := GameEnums.InputOutcome.WRONG
	if tapped_direction == prompt.correct_direction:
		outcome = GameEnums.InputOutcome.CORRECT
		ScoringService.apply_correct(state, config)
	else:
		ScoringService.apply_wrong(state, config)

	prompt_resolved.emit(outcome, prompt, tapped_direction, state)
	state_updated.emit(state)

	if ScoringService.should_end_round(state, config):
		_finish_round()
	else:
		_issue_next_prompt()
	return outcome


func pause_game() -> void:
	if state.status == GameEnums.RoundStatus.ACTIVE or state.status == GameEnums.RoundStatus.COUNTDOWN:
		_status_before_pause = state.status
		state.status = GameEnums.RoundStatus.PAUSED
		pause_changed.emit(true)
		state_updated.emit(state)


func resume_game() -> void:
	if state.status == GameEnums.RoundStatus.PAUSED:
		state.status = _status_before_pause
		_status_before_pause = GameEnums.RoundStatus.IDLE
		pause_changed.emit(false)
		state_updated.emit(state)


func abort_to_idle() -> void:
	state.status = GameEnums.RoundStatus.IDLE
	state.current_prompt = null
	_status_before_pause = GameEnums.RoundStatus.IDLE


func get_remaining_prompt_window() -> float:
	if state.current_prompt == null or state.current_prompt.resolved:
		return 0.0
	return maxf(0.0, state.current_prompt.response_deadline - state.elapsed_time)


func _begin_active_play() -> void:
	state.status = GameEnums.RoundStatus.ACTIVE
	state.elapsed_time = 0.0
	if config.mode == GameEnums.GameMode.RUSH:
		state.remaining_time = config.rush_duration_seconds
	round_started.emit(state)
	_issue_next_prompt()
	state_updated.emit(state)


func _issue_next_prompt() -> void:
	var window := DifficultyService.compute_response_window(state.correct_count, config)
	var prompt := _prompt_generator.next_prompt(_sequence_index, state.elapsed_time, window)
	_sequence_index += 1
	state.current_prompt = prompt
	prompt_issued.emit(prompt)


func _resolve_timeout() -> void:
	var prompt := state.current_prompt
	if prompt == null or prompt.resolved:
		return
	prompt.resolved = true
	ScoringService.apply_timeout(state, config)
	prompt_resolved.emit(GameEnums.InputOutcome.TIMEOUT, prompt, -1, state)
	state_updated.emit(state)

	if ScoringService.should_end_round(state, config):
		_finish_round()
	else:
		_issue_next_prompt()


func _finish_round() -> void:
	state.status = GameEnums.RoundStatus.ENDED
	if state.current_prompt != null:
		state.current_prompt.resolved = true

	_session_counter += 1
	var res := SessionResult.new()
	res.session_id = "sess_%d_%d" % [int(Time.get_unix_time_from_system()), _session_counter]
	res.mode = state.mode
	res.score = state.score
	res.correct_count = state.correct_count
	res.incorrect_count = state.incorrect_count
	res.timeout_count = state.timeout_count
	res.accuracy = ScoringService.compute_accuracy(state.correct_count, state.incorrect_count, state.timeout_count)
	res.best_streak = state.best_streak
	res.duration = state.elapsed_time
	res.timestamp = int(Time.get_unix_time_from_system())
	round_ended.emit(res)
