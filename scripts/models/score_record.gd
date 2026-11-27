class_name ScoreRecord
extends RefCounted
## Persisted personal best scores and capped recent session history.

const CURRENT_SCHEMA_VERSION := 1
const MAX_RECENT_RESULTS := 20

var schema_version: int = CURRENT_SCHEMA_VERSION
var classic_best: int = 0
var classic_best_streak: int = 0
var rush_best: int = 0
var rush_best_streak: int = 0
var recent_results: Array[SessionResult] = []


func apply_session(result: SessionResult) -> bool:
	var is_new_best := false
	if result.mode == GameEnums.GameMode.CLASSIC:
		if result.score > classic_best:
			classic_best = result.score
			is_new_best = true
		classic_best_streak = maxi(classic_best_streak, result.best_streak)
	else:
		if result.score > rush_best:
			rush_best = result.score
			is_new_best = true
		rush_best_streak = maxi(rush_best_streak, result.best_streak)

	result.is_new_record = is_new_best
	recent_results.push_front(result)
	while recent_results.size() > MAX_RECENT_RESULTS:
		recent_results.pop_back()
	return is_new_best


func get_best_for_mode(mode: int) -> int:
	return classic_best if mode == GameEnums.GameMode.CLASSIC else rush_best


func to_dict() -> Dictionary:
	var recent_dicts: Array = []
	for item in recent_results:
		recent_dicts.append(item.to_dict())
	return {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"classic_best": classic_best,
		"classic_best_streak": classic_best_streak,
		"rush_best": rush_best,
		"rush_best_streak": rush_best_streak,
		"recent_results": recent_dicts,
	}


static func from_dict(data: Dictionary) -> ScoreRecord:
	var rec := ScoreRecord.new()
	rec.schema_version = CURRENT_SCHEMA_VERSION
	rec.classic_best = maxi(0, int(data.get("classic_best", 0)))
	rec.classic_best_streak = maxi(0, int(data.get("classic_best_streak", 0)))
	rec.rush_best = maxi(0, int(data.get("rush_best", 0)))
	rec.rush_best_streak = maxi(0, int(data.get("rush_best_streak", 0)))

	var raw_recent = data.get("recent_results", [])
	if raw_recent is Array:
		for item in raw_recent:
			if item is Dictionary:
				rec.recent_results.append(SessionResult.from_dict(item))
				if rec.recent_results.size() >= MAX_RECENT_RESULTS:
					break
	return rec
