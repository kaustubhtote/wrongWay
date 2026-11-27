class_name ShareService
extends RefCounted
## Formats session share text and falls back gracefully to clipboard when native share is unavailable.


static func format_share_text(result: SessionResult) -> String:
	var mode_name := GameEnums.mode_to_label(result.mode)
	return "I scored %d in WRONG WAY! (%s • %.1f%% accuracy • %d streak) — tap the opposite direction!" % [
		result.score,
		mode_name,
		result.accuracy,
		result.best_streak,
	]


static func share_result(result: SessionResult) -> String:
	if result == null:
		return ""
	var text := format_share_text(result)
	# Optional native share singleton if added in a future build; safe clipboard fallback by default.
	if Engine.has_singleton("SharePlugin"):
		var plugin = Engine.get_singleton("SharePlugin")
		if plugin != null and plugin.has_method("shareText"):
			plugin.call("shareText", "WRONG WAY! Score", text)
			return "Share sheet opened!"

	DisplayServer.clipboard_set(text)
	return "Score summary copied to clipboard!"
