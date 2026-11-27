extends RefCounted
## Phase 3 & 6 domain unit tests (PromptGenerator, DifficultyService, ScoringService, GameController).


static func run(t) -> void:
	_test_opposite_mappings(t)
	_test_prompt_repeat_limiter_and_determinism(t)
	_test_difficulty_bounds(t)
	_test_scoring_and_accuracy(t)
	_test_classic_three_mistakes_and_single_resolution(t)
	_test_rush_60s_and_non_negative_score(t)
	_test_pause_and_countdown_freeze(t)
	_test_late_input_rejected(t)


static func _test_opposite_mappings(t) -> void:
	t.assert_eq(PromptGenerator.get_opposite_direction(GameEnums.Direction.UP), GameEnums.Direction.DOWN, "UP -> DOWN")
	t.assert_eq(PromptGenerator.get_opposite_direction(GameEnums.Direction.DOWN), GameEnums.Direction.UP, "DOWN -> UP")
	t.assert_eq(PromptGenerator.get_opposite_direction(GameEnums.Direction.LEFT), GameEnums.Direction.RIGHT, "LEFT -> RIGHT")
	t.assert_eq(PromptGenerator.get_opposite_direction(GameEnums.Direction.RIGHT), GameEnums.Direction.LEFT, "RIGHT -> LEFT")


static func _test_prompt_repeat_limiter_and_determinism(t) -> void:
	var g1 := PromptGenerator.new(2, 424242)
	var g2 := PromptGenerator.new(2, 424242)
	var prev := -1
	var run_len := 0
	for i in 500:
		var p1 := g1.next_prompt(i, float(i), 1.5)
		var p2 := g2.next_prompt(i, float(i), 1.5)
		t.assert_true(p1.displayed_direction in GameEnums.ALL_DIRECTIONS, "Displayed direction valid enum")
		t.assert_eq(p1.correct_direction, PromptGenerator.get_opposite_direction(p1.displayed_direction), "Correct is opposite")
		t.assert_eq(p1.displayed_direction, p2.displayed_direction, "Seeded prompt deterministic")
		if p1.displayed_direction == prev:
			run_len += 1
		else:
			prev = p1.displayed_direction
			run_len = 1
		t.assert_true(run_len <= 2, "Never more than 2 identical prompts in a row")


static func _test_difficulty_bounds(t) -> void:
	var cfg := GameConfig.create_classic()
	var w0 := DifficultyService.compute_response_window(0, cfg)
	t.assert_approx(w0, 1.8, 0.0001, "Starts at 1.8s")
	var w10 := DifficultyService.compute_response_window(10, cfg)
	t.assert_true(w10 < w0 and w10 >= 0.75, "Decreases monotonically inside bounds")
	var w_high := DifficultyService.compute_response_window(1000, cfg)
	t.assert_approx(w_high, 0.75, 0.0001, "Hard floor at 0.75s")
	var w_neg := DifficultyService.compute_response_window(-5, cfg)
	t.assert_approx(w_neg, 1.8, 0.0001, "Negative correct count clamped to base 1.8s")


static func _test_scoring_and_accuracy(t) -> void:
	t.assert_approx(ScoringService.compute_accuracy(0, 0, 0), 0.0, 0.0001, "Zero-answer accuracy is 0.0")
	t.assert_approx(ScoringService.compute_accuracy(3, 1, 0), 75.0, 0.0001, "3/4 accuracy is 75.0")


static func _test_classic_three_mistakes_and_single_resolution(t) -> void:
	var ctrl := GameController.new()
	var cfg := GameConfig.create_classic()
	ctrl.start_round(cfg, 101, true)
	var first_prompt := ctrl.state.current_prompt
	t.assert_true(first_prompt != null, "Initial prompt issued")

	var out1 := ctrl.submit_direction(first_prompt.correct_direction, first_prompt.id)
	t.assert_eq(out1, GameEnums.InputOutcome.CORRECT, "Correct answer accepted")
	t.assert_eq(ctrl.state.score, 1, "Score incremented once")
	var dup := ctrl.submit_direction(first_prompt.correct_direction, first_prompt.id)
	t.assert_eq(dup, GameEnums.InputOutcome.IGNORED, "Duplicate input for resolved prompt rejected")
	t.assert_eq(ctrl.state.score, 1, "Duplicate input did not double-score")

	# Mistake 1: wrong answer consumes 1 life exactly once.
	var p2 := ctrl.state.current_prompt
	var out_wrong := ctrl.submit_direction(p2.displayed_direction, p2.id)
	t.assert_eq(out_wrong, GameEnums.InputOutcome.WRONG, "Wrong tap detected")
	t.assert_eq(ctrl.state.lives, 2, "2 lives remaining after 1st mistake")
	t.assert_eq(ctrl.state.current_streak, 0, "Streak reset on mistake")
	t.assert_eq(ctrl.submit_direction(p2.displayed_direction, p2.id), GameEnums.InputOutcome.IGNORED, "Duplicate wrong tap ignored")
	t.assert_eq(ctrl.state.lives, 2, "Life consumed only once")

	# Mistake 2: timeout consumes 1 life.
	ctrl.step(2.0)
	t.assert_eq(ctrl.state.lives, 1, "1 life remaining after timeout")
	t.assert_eq(ctrl.state.timeout_count, 1, "Timeout count incremented")
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ACTIVE, "Still active before 3rd mistake")

	# Mistake 3: wrong answer ends Classic round.
	var p4 := ctrl.state.current_prompt
	ctrl.submit_direction(p4.displayed_direction, p4.id)
	t.assert_eq(ctrl.state.lives, 0, "0 lives after 3rd mistake")
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ENDED, "Classic ends after 3rd mistake")
	ctrl.free()


static func _test_rush_60s_and_non_negative_score(t) -> void:
	var ctrl := GameController.new()
	var cfg := GameConfig.create_rush()
	ctrl.start_round(cfg, 202, true)

	var p1 := ctrl.state.current_prompt
	ctrl.submit_direction(p1.displayed_direction, p1.id)
	t.assert_eq(ctrl.state.score, 0, "Rush penalty never makes score negative")

	var p2 := ctrl.state.current_prompt
	ctrl.submit_direction(p2.correct_direction, p2.id)
	t.assert_eq(ctrl.state.score, 1, "Rush correct scores +1")
	var p3 := ctrl.state.current_prompt
	ctrl.submit_direction(p3.displayed_direction, p3.id)
	t.assert_eq(ctrl.state.score, 0, "Rush wrong subtracts 1")

	for _i in 60:
		if ctrl.state.status == GameEnums.RoundStatus.ENDED:
			break
		ctrl.step(1.0)
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ENDED, "Rush ends at 60 seconds")
	t.assert_approx(ctrl.state.remaining_time, 0.0, 0.001, "Rush remaining time reaches 0.0")
	ctrl.free()


static func _test_pause_and_countdown_freeze(t) -> void:
	var ctrl := GameController.new()
	var cfg := GameConfig.create_rush()
	ctrl.start_round(cfg, 303, false)
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.COUNTDOWN, "Starts in countdown")
	ctrl.step(0.5)
	t.assert_approx(ctrl.state.remaining_time, 60.0, 0.0001, "Countdown does not consume Rush game time")
	ctrl.step(2.0)
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ACTIVE, "Countdown finishes into ACTIVE")

	var deadline_before := ctrl.state.current_prompt.response_deadline
	var rem_before := ctrl.state.remaining_time
	ctrl.pause_game()
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.PAUSED, "Status is PAUSED")
	ctrl.step(10.0)
	t.assert_approx(ctrl.state.remaining_time, rem_before, 0.0001, "Pause freezes round timer")
	t.assert_approx(ctrl.state.current_prompt.response_deadline, deadline_before, 0.0001, "Pause freezes prompt deadline")
	t.assert_eq(ctrl.submit_direction(ctrl.state.current_prompt.correct_direction), GameEnums.InputOutcome.IGNORED, "Input ignored while paused")

	ctrl.resume_game()
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ACTIVE, "Resumes to ACTIVE")
	ctrl.free()


static func _test_late_input_rejected(t) -> void:
	var ctrl := GameController.new()
	var cfg := GameConfig.create_classic()
	ctrl.start_round(cfg, 404, true)
	var p := ctrl.state.current_prompt
	ctrl.state.elapsed_time = p.response_deadline + 0.05
	var outcome := ctrl.submit_direction(p.correct_direction, p.id)
	t.assert_eq(outcome, GameEnums.InputOutcome.IGNORED, "Late input after deadline cannot score")
	t.assert_eq(ctrl.state.score, 0, "Late input leaves score 0")
	ctrl.free()
