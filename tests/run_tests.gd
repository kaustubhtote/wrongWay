extends SceneTree
## Project-native headless test runner for WRONG WAY!

const DomainTests = preload("res://tests/test_domain.gd")
const PersistenceTests = preload("res://tests/test_persistence.gd")
const UiFlowTests = preload("res://tests/test_ui_flow.gd")

var _passed: int = 0
var _failed: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	print("=== WRONG WAY! Headless Test Suite ===")
	DomainTests.run(self)
	PersistenceTests.run(self)
	await UiFlowTests.run(self, self)
	await process_frame
	print("Summary: %d passed, %d failed" % [_passed, _failed])
	if _failed > 0:
		for msg in _failures:
			push_error(msg)
		quit(1)
	else:
		quit(0)


func assert_true(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
	else:
		_failed += 1
		var msg := "[FAIL] %s" % label
		_failures.append(msg)
		print(msg)


func assert_eq(actual, expected, label: String) -> void:
	if actual == expected:
		_passed += 1
	else:
		_failed += 1
		var msg := "[FAIL] %s: expected <%s>, got <%s>" % [label, str(expected), str(actual)]
		_failures.append(msg)
		print(msg)


func assert_approx(actual: float, expected: float, eps: float, label: String) -> void:
	if absf(actual - expected) <= eps:
		_passed += 1
	else:
		_failed += 1
		var msg := "[FAIL] %s: expected ~%s, got %s" % [label, str(expected), str(actual)]
		_failures.append(msg)
		print(msg)
