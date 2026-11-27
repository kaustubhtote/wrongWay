class_name SessionResult
extends RefCounted
## Summary of a finished gameplay round.

var session_id: String = ""
var mode: int = GameEnums.GameMode.CLASSIC
var score: int = 0
var accuracy: float = 0.0
var correct_count: int = 0
var incorrect_count: int = 0
var timeout_count: int = 0
var best_streak: int = 0
var duration: float = 0.0
var timestamp: int = 0
var is_new_record: bool = false


func to_dict() -> Dictionary:
	return {
		"session_id": session_id,
		"mode": mode,
		"score": score,
		"accuracy": accuracy,
		"correct_count": correct_count,
		"incorrect_count": incorrect_count,
		"timeout_count": timeout_count,
		"best_streak": best_streak,
		"duration": duration,
		"timestamp": timestamp,
		"is_new_record": is_new_record,
	}


static func from_dict(data: Dictionary) -> SessionResult:
	var res := SessionResult.new()
	res.session_id = str(data.get("session_id", ""))
	var raw_mode := int(data.get("mode", GameEnums.GameMode.CLASSIC))
	res.mode = raw_mode if raw_mode in [GameEnums.GameMode.CLASSIC, GameEnums.GameMode.RUSH] else GameEnums.GameMode.CLASSIC
	res.score = maxi(0, int(data.get("score", 0)))
	res.accuracy = clampf(float(data.get("accuracy", 0.0)), 0.0, 100.0)
	res.correct_count = maxi(0, int(data.get("correct_count", 0)))
	res.incorrect_count = maxi(0, int(data.get("incorrect_count", 0)))
	res.timeout_count = maxi(0, int(data.get("timeout_count", 0)))
	res.best_streak = maxi(0, int(data.get("best_streak", 0)))
	res.duration = maxf(0.0, float(data.get("duration", 0.0)))
	res.timestamp = maxi(0, int(data.get("timestamp", 0)))
	res.is_new_record = bool(data.get("is_new_record", false))
	return res
