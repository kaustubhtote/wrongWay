class_name GameEnums
## Core enumerations and direction helpers shared across domain and UI layers.

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

enum GameMode {
	CLASSIC,
	RUSH,
}

enum RoundStatus {
	IDLE,
	COUNTDOWN,
	ACTIVE,
	PAUSED,
	ENDED,
}

enum InputOutcome {
	CORRECT,
	WRONG,
	TIMEOUT,
	IGNORED,
}

const ALL_DIRECTIONS: Array[int] = [
	Direction.UP,
	Direction.DOWN,
	Direction.LEFT,
	Direction.RIGHT,
]


static func direction_to_label(dir: int) -> String:
	match dir:
		Direction.UP:
			return "UP"
		Direction.DOWN:
			return "DOWN"
		Direction.LEFT:
			return "LEFT"
		Direction.RIGHT:
			return "RIGHT"
		_:
			return "UNKNOWN"


static func direction_to_symbol(dir: int) -> String:
	match dir:
		Direction.UP:
			return "▲"
		Direction.DOWN:
			return "▼"
		Direction.LEFT:
			return "◀"
		Direction.RIGHT:
			return "▶"
		_:
			return "?"


static func mode_to_label(mode: int) -> String:
	match mode:
		GameMode.CLASSIC:
			return "CLASSIC"
		GameMode.RUSH:
			return "60s RUSH"
		_:
			return "UNKNOWN"


static func mode_to_key(mode: int) -> String:
	match mode:
		GameMode.CLASSIC:
			return "classic"
		GameMode.RUSH:
			return "rush"
		_:
			return "classic"


static func key_to_mode(key: String) -> int:
	if key.to_lower() == "rush":
		return GameMode.RUSH
	return GameMode.CLASSIC
