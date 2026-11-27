extends RefCounted
## Automated UI scene instantiation, navigation, pause, and restart flow tests.

const MainScene = preload("res://scenes/app/Main.tscn")


static func run(t, tree: SceneTree) -> void:
	var main := MainScene.instantiate()
	tree.root.add_child(main)
	await tree.process_frame

	var router: ScreenRouter = main.get_node("%ScreenRouter")
	var ctrl: GameController = main.get_node("%GameController")
	var pause_overlay: Control = main.get_node("%PauseOverlay")
	var gameplay: Control = main.get_node("%GameplayScreen")

	t.assert_eq(router.get_current_screen_id(), "splash", "Starts on splash screen")

	router.navigate_to("home")
	t.assert_eq(router.get_current_screen_id(), "home", "Navigates to home")

	router.navigate_to("mode_select")
	t.assert_eq(router.get_current_screen_id(), "mode_select", "Navigates to mode_select")
	t.assert_true(router.handle_back_action(), "Back from mode_select handled")
	t.assert_eq(router.get_current_screen_id(), "home", "Back returns from mode_select to home")

	var btn_up: Control = gameplay.get_node_or_null("SafeArea/VBox/ButtonGrid/BtnUp")
	t.assert_true(btn_up != null, "BtnUp exists in GameplayScreen")
	if btn_up != null:
		t.assert_true(btn_up.custom_minimum_size.x >= 260.0 and btn_up.custom_minimum_size.y >= 152.0, "DirectionButton meets 64dp+ touch target size")

	main.call("_start_mode", GameEnums.GameMode.CLASSIC)
	t.assert_eq(router.get_current_screen_id(), "countdown", "Mode start opens countdown")
	ctrl.step(3.0)
	t.assert_eq(router.get_current_screen_id(), "gameplay", "Countdown completion transitions to gameplay")
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ACTIVE, "GameController active on gameplay screen")

	t.assert_true(router.handle_back_action(), "Back on gameplay opens pause")
	t.assert_true(pause_overlay.visible, "Pause overlay visible")
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.PAUSED, "Gameplay paused via back action")

	t.assert_true(router.handle_back_action(), "Back on pause overlay resumes")
	t.assert_eq(pause_overlay.visible, false, "Pause overlay hidden after resume")
	t.assert_eq(ctrl.state.status, GameEnums.RoundStatus.ACTIVE, "Gameplay active after resume")

	pause_overlay.restart_requested.emit()
	t.assert_eq(router.get_current_screen_id(), "countdown", "Restart transitions to countdown")
	t.assert_eq(ctrl.state.score, 0, "Restart resets score to 0")

	tree.root.remove_child(main)
	main.queue_free()
	await tree.process_frame
