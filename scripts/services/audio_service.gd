class_name AudioService
extends Node
## Lightweight procedural 16-bit PCM synth SFX service with zero external copyrighted assets.

const SAMPLE_RATE := 22050

var enabled: bool = true
var _players: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}


func _ready() -> void:
	for i in 4:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

	_streams["tap"] = _build_tone(520.0, 520.0, 0.045, 0.22)
	_streams["correct"] = _build_tone(660.0, 880.0, 0.09, 0.28)
	_streams["wrong"] = _build_tone(240.0, 140.0, 0.16, 0.30)
	_streams["timeout"] = _build_tone(320.0, 180.0, 0.20, 0.28)
	_streams["countdown"] = _build_tone(480.0, 480.0, 0.06, 0.22)
	_streams["go"] = _build_tone(720.0, 960.0, 0.12, 0.28)
	_streams["record"] = _build_tone(587.0, 1046.0, 0.24, 0.30)


func play_tap() -> void:
	_play("tap", 1.0)


func play_correct(streak: int = 1) -> void:
	var pitch := clampf(1.0 + float(mini(streak, 12)) * 0.02, 1.0, 1.24)
	_play("correct", pitch)


func play_wrong() -> void:
	_play("wrong", 1.0)


func play_timeout() -> void:
	_play("timeout", 1.0)


func play_countdown(is_go: bool = false) -> void:
	_play("go" if is_go else "countdown", 1.0)


func play_record() -> void:
	_play("record", 1.0)


func _play(key: String, pitch_scale: float) -> void:
	if not enabled or not _streams.has(key):
		return
	for player in _players:
		if not player.playing:
			player.stream = _streams[key]
			player.pitch_scale = pitch_scale
			player.play()
			return
	_players[0].stream = _streams[key]
	_players[0].pitch_scale = pitch_scale
	_players[0].play()


func _build_tone(freq_start: float, freq_end: float, duration_sec: float, amplitude: float) -> AudioStreamWAV:
	var count := maxi(1, int(float(SAMPLE_RATE) * duration_sec))
	var data := PackedByteArray()
	data.resize(count * 2)
	var phase := 0.0
	for i in count:
		var t := float(i) / float(count)
		var freq := lerpf(freq_start, freq_end, t)
		var env := (1.0 - t) * minf(1.0, t * 18.0)
		phase += TAU * freq / float(SAMPLE_RATE)
		var sample_val := sin(phase) * amplitude * env
		var pcm := clampi(int(round(sample_val * 32767.0)), -32768, 32767)
		data.encode_s16(i * 2, pcm)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav
