extends Node

const MIX_RATE: int = 22050
const LOOP_SECONDS: float = 3.5

var state: Dictionary = {
	"muted": false,
	"bgm": 0.45,
	"rain": 0.35,
	"fire": 0.0,
	"keyboard": 0.0,
	"wind": 0.15,
}

var _unlocked: bool = false
var _is_focusing_desk: bool = false

var _bgm_player: AudioStreamPlayer
var _sfx_players: Dictionary = {}
var _rain_player: AudioStreamPlayer
var _fire_player: AudioStreamPlayer
var _wind_player: AudioStreamPlayer

var _crackle_streams: Array = []
var _thock_streams: Array = []
var _pop_players: Array = []
var _pop_cursor: int = 0

var _crackle_timer: Timer
var _keyboard_timer: Timer
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_setup_audio_nodes()
	_generate_procedural_streams()
	_setup_timers()
	_apply_all_volumes()


func _load_wav(res_path: String, loop: bool = false) -> AudioStream:
	var stream: AudioStream = null
	if ResourceLoader.exists(res_path):
		var loaded := ResourceLoader.load(res_path)
		if loaded is AudioStream:
			stream = loaded
	if stream == null:
		var abs_path := ProjectSettings.globalize_path(res_path)
		if FileAccess.file_exists(abs_path):
			stream = AudioStreamWAV.load_from_file(abs_path)
	if stream == null and FileAccess.file_exists(res_path):
		var buf := FileAccess.get_file_as_bytes(res_path)
		if not buf.is_empty():
			stream = AudioStreamWAV.load_from_buffer(buf)
	if stream is AudioStreamWAV and loop:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		var total_frames := int(round(wav.get_length() * float(wav.mix_rate)))
		if total_frames > 0:
			wav.loop_end = total_frames
	return stream


func _setup_audio_nodes() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BgmPlayer"
	_bgm_player.stream = _load_wav("res://sounds/bgm.wav", true)
	add_child(_bgm_player)

	var sfx_defs := {
		"step": {"path": "res://sounds/step.wav", "vol": 0.16},
		"interact": {"path": "res://sounds/interact.wav", "vol": 0.32},
		"solve": {"path": "res://sounds/solve.wav", "vol": 0.35},
		"fanfare": {"path": "res://sounds/fanfare.wav", "vol": 0.40},
	}
	for sfx_name in sfx_defs.keys():
		var info: Dictionary = sfx_defs[sfx_name]
		var p := AudioStreamPlayer.new()
		p.name = "Sfx_%s" % sfx_name
		p.stream = _load_wav(str(info["path"]), false)
		p.volume_db = linear_to_db(float(info["vol"]))
		add_child(p)
		_sfx_players[sfx_name] = p

	_rain_player = AudioStreamPlayer.new()
	_rain_player.name = "RainPlayer"
	add_child(_rain_player)

	_fire_player = AudioStreamPlayer.new()
	_fire_player.name = "FirePlayer"
	add_child(_fire_player)

	_wind_player = AudioStreamPlayer.new()
	_wind_player.name = "WindPlayer"
	add_child(_wind_player)

	for i in range(6):
		var pop := AudioStreamPlayer.new()
		pop.name = "PopPlayer_%d" % i
		add_child(pop)
		_pop_players.append(pop)


func _samples_to_wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var count := samples.size()
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in range(count):
		var clamped := clampf(samples[i], -1.0, 1.0)
		var pcm := int(round(clamped * 32767.0))
		bytes.encode_s16(i * 2, pcm)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = count
	return wav


func _crossfade_loop(samples: PackedFloat32Array) -> void:
	var n := samples.size()
	var fade := mini(int(MIX_RATE * 0.12), int(float(n) * 0.25))
	for i in range(fade):
		var t := float(i) / float(fade)
		samples[i] = samples[i] * t + samples[n - fade + i] * (1.0 - t)


func _generate_procedural_streams() -> void:
	var n := int(float(MIX_RATE) * LOOP_SECONDS)

	# 1. Rain (Filtered Pink Noise around ~1150 Hz)
	var rain := PackedFloat32Array()
	rain.resize(n)
	var b0 := 0.0
	var b1 := 0.0
	var b2 := 0.0
	var b3 := 0.0
	var b4 := 0.0
	var b5 := 0.0
	var b6 := 0.0
	var lp_r := 0.0
	var hp_r := 0.0
	var prev_in_r := 0.0
	var alpha_lp_r := 0.38
	var alpha_hp_r := 0.85
	for i in range(n):
		var white := _rng.randf_range(-1.0, 1.0)
		b0 = 0.99886 * b0 + white * 0.0555179
		b1 = 0.99332 * b1 + white * 0.0750759
		b2 = 0.96900 * b2 + white * 0.1538520
		b3 = 0.86650 * b3 + white * 0.3104856
		b4 = 0.55000 * b4 + white * 0.5329522
		b5 = -0.7616 * b5 - white * 0.0168980
		var pink := (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.06
		b6 = white * 0.115926
		hp_r = alpha_hp_r * (hp_r + pink - prev_in_r)
		prev_in_r = pink
		lp_r = lp_r + alpha_lp_r * (hp_r - lp_r)
		rain[i] = clampf(lp_r * 1.4, -0.95, 0.95)
	_crossfade_loop(rain)
	_rain_player.stream = _samples_to_wav(rain, true)

	# 2. Fireplace (Warm Low-Pass Brown Noise ~280 Hz)
	var fire := PackedFloat32Array()
	fire.resize(n)
	var last_out := 0.0
	var lp_f := 0.0
	var alpha_f := 0.075
	for i in range(n):
		var white := _rng.randf_range(-1.0, 1.0)
		last_out = (last_out + 0.02 * white) / 1.02
		var brown := last_out * 1.8
		lp_f = lp_f + alpha_f * (brown - lp_f)
		fire[i] = clampf(lp_f * 1.6, -0.95, 0.95)
	_crossfade_loop(fire)
	_fire_player.stream = _samples_to_wav(fire, true)

	# 3. Night Wind (LFO-Modulated Low-Pass Brown Noise)
	var wind := PackedFloat32Array()
	wind.resize(n)
	var last_w := 0.0
	var lp_w := 0.0
	for i in range(n):
		var t := float(i) / float(MIX_RATE)
		var white := _rng.randf_range(-1.0, 1.0)
		last_w = (last_w + 0.02 * white) / 1.02
		var lfo := 0.5 + 0.5 * sin(TAU * (1.0 / LOOP_SECONDS) * t)
		var alpha_w := lerpf(0.05, 0.14, lfo)
		lp_w = lp_w + alpha_w * (last_w * 1.6 - lp_w)
		wind[i] = clampf(lp_w * 1.35, -0.95, 0.95)
	_crossfade_loop(wind)
	_wind_player.stream = _samples_to_wav(wind, true)

	# 4. Crackle pop short SFX variations (35ms)
	var pop_len := int(float(MIX_RATE) * 0.035)
	for v in range(4):
		var pop := PackedFloat32Array()
		pop.resize(pop_len)
		var f0 := 1400.0 + float(v) * 420.0
		var phase := 0.0
		for i in range(pop_len):
			var t := float(i) / float(MIX_RATE)
			var u := clampf(t / 0.03, 0.0, 1.0)
			var freq := f0 * pow(220.0 / f0, u)
			phase += freq / float(MIX_RATE)
			var tri := 1.0 - 4.0 * absf(fposmod(phase, 1.0) - 0.5)
			var env := 0.08 * pow(0.0125, u)
			pop[i] = tri * env
		_crackle_streams.append(_samples_to_wav(pop, false))

	# 5. Mechanical keyboard ASMR thock variations (50ms)
	var thock_len := int(float(MIX_RATE) * 0.05)
	for v in range(6):
		var thock := PackedFloat32Array()
		thock.resize(thock_len)
		var f0 := 260.0 + float(v) * 18.0
		var phase := 0.0
		var lp_k := 0.0
		for i in range(thock_len):
			var t := float(i) / float(MIX_RATE)
			var u := clampf(t / 0.045, 0.0, 1.0)
			var freq := f0 * pow(95.0 / f0, clampf(t / 0.04, 0.0, 1.0))
			phase += freq / float(MIX_RATE)
			var tri := 1.0 - 4.0 * absf(fposmod(phase, 1.0) - 0.5)
			lp_k = lp_k + 0.25 * (tri - lp_k)
			var env := 0.22 * pow(0.006, u)
			thock[i] = lp_k * env
		_thock_streams.append(_samples_to_wav(thock, false))


func _setup_timers() -> void:
	_crackle_timer = Timer.new()
	_crackle_timer.wait_time = 0.18
	_crackle_timer.autostart = true
	_crackle_timer.timeout.connect(_on_crackle_tick)
	add_child(_crackle_timer)

	_keyboard_timer = Timer.new()
	_keyboard_timer.wait_time = 0.15
	_keyboard_timer.autostart = true
	_keyboard_timer.timeout.connect(_on_keyboard_tick)
	add_child(_keyboard_timer)


func _on_crackle_tick() -> void:
	if not _unlocked or bool(state.get("muted", false)):
		return
	var fire_vol := float(state.get("fire", 0.0))
	if fire_vol <= 0.02 or _rng.randf() > 0.45:
		return
	if _crackle_streams.is_empty():
		return
	var p: AudioStreamPlayer = _pop_players[_pop_cursor]
	_pop_cursor = (_pop_cursor + 1) % _pop_players.size()
	p.stream = _crackle_streams[_rng.randi() % _crackle_streams.size()]
	p.volume_db = linear_to_db(maxf(0.001, fire_vol * 0.85))
	p.play()


func _on_keyboard_tick() -> void:
	if not _unlocked or bool(state.get("muted", false)):
		return
	var kb_vol := float(state.get("keyboard", 0.0))
	if kb_vol <= 0.02:
		return
	var hit_chance := 0.72 if _is_focusing_desk else 0.48
	if _rng.randf() >= hit_chance:
		return
	if _thock_streams.is_empty():
		return
	var p: AudioStreamPlayer = _pop_players[_pop_cursor]
	_pop_cursor = (_pop_cursor + 1) % _pop_players.size()
	p.stream = _thock_streams[_rng.randi() % _thock_streams.size()]
	p.volume_db = linear_to_db(maxf(0.001, kb_vol * 0.65))
	p.play()


func unlock_audio() -> void:
	if _unlocked:
		return
	_unlocked = true
	_apply_all_volumes()


func apply_mixer_state(next_state: Dictionary) -> void:
	for k in state.keys():
		if next_state.has(k):
			state[k] = next_state[k]
	_apply_all_volumes()


func set_channel_volume(channel: String, vol: float) -> void:
	state[channel] = clampf(vol, 0.0, 1.0)
	_apply_all_volumes()


func set_master_mute(muted: bool) -> void:
	state["muted"] = muted
	_apply_all_volumes()


func set_focus_activity(focusing: bool) -> void:
	_is_focusing_desk = focusing


func _set_loop_player(player: AudioStreamPlayer, linear_vol: float) -> void:
	if player == null or player.stream == null:
		return
	if linear_vol <= 0.001:
		if player.playing:
			player.stop()
		return
	player.volume_db = linear_to_db(linear_vol)
	if _unlocked and not player.playing:
		player.play()


func _apply_all_volumes() -> void:
	var mute_factor := 0.0 if bool(state.get("muted", false)) else 1.0
	_set_loop_player(_bgm_player, float(state.get("bgm", 0.0)) * 0.55 * mute_factor)
	_set_loop_player(_rain_player, float(state.get("rain", 0.0)) * 0.55 * mute_factor)
	_set_loop_player(_fire_player, float(state.get("fire", 0.0)) * 0.70 * mute_factor)
	_set_loop_player(_wind_player, float(state.get("wind", 0.0)) * 0.35 * mute_factor)


func play_sfx(sfx_name: String) -> void:
	if bool(state.get("muted", false)):
		return
	unlock_audio()
	if _sfx_players.has(sfx_name):
		var p: AudioStreamPlayer = _sfx_players[sfx_name]
		if p != null and p.stream != null:
			p.play()
