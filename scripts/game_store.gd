extends Node

signal state_changed
signal layout_changed
signal players_changed
signal chat_updated
signal pomodoro_updated
signal toast_shown(msg: String)
signal screen_changed(screen: String)
signal auth_changed
signal lobby_stats_updated(general_count: int)
signal update_state_changed

const POMODORO_DURATIONS: Dictionary = {
	"focus": 25 * 60,
	"short_break": 5 * 60,
	"long_break": 15 * 60,
}

const AUTH_STORAGE_FILE: String = "user://cozy_auth_session_v1.json"
const HOST_KEY_FILE: String = "user://cozy_host_key.txt"
const PROFILE_FILE: String = "user://cozy_player_profile_v2.json"
const TODOS_FILE: String = "user://cozy_todos.json"
const MIXER_FILE: String = "user://cozy_audio_mixer.json"
const GITHUB_REPO: String = "phanphuong1512/cozy-focus-godot"
const LATEST_MANIFEST_URL: String = "https://github.com/phanphuong1512/cozy-focus-godot/releases/latest/download/latest.json"
const GITHUB_RELEASE_PAGE_URL: String = "https://github.com/phanphuong1512/cozy-focus-godot/releases/latest"

# Auth state
var user: Dictionary = {}
var current_screen: String = "login"
var auth_error: String = ""
var is_waiting_google: bool = false
var general_players_count: int = -1

# Connection & Room
var connected: bool = false
var room_code: String = "GENERAL"
var host_key: String = ""
var my_player_id: String = "local-player"
var is_host: bool = true
var layout: Dictionary = {}
var players: Dictionary = {}
var ghost_previews: Dictionary = {}
var chat_messages: Array = []
var toast_message: String = ""

# Local player info
var local_player: Dictionary = {}

# Build / Decor mode
var build_mode: bool = false
var build_tab: String = "workspace"
var active_floor_brush: String = ""
var active_wall_brush: String = ""
var selected_catalog_id: String = ""
var moving_item_uid: String = ""
var place_flipped: bool = false

# Focus & Productivity
var pomodoro: Dictionary = {}
var completed_pomodoros: int = 0
var todos: Array = []
var pinned_todo_id: String = ""

# Audio Mixer
var audio_mixer: Dictionary = {}

# UI Panels & Desktop Companion
var show_audio_mixer: bool = false
var show_focus_panel: bool = true
var show_room_modal: bool = false
var show_profile_modal: bool = false
var has_customized_character: bool = false
var mini_mode: bool = false
var always_on_top: bool = false
var is_fullscreen: bool = false

# Auto-Updater state
var app_version: String = "1.0.0"
var update_available: bool = false
var latest_version: String = ""
var update_notes: String = ""
var update_download_url: String = ""
var update_dismissed_version: String = ""
var update_downloading: bool = false
var update_progress_pct: int = 0
var update_error: String = ""

# Internal networking & timers
var _ws: WebSocketPeer = null
var _socket_connected: bool = false
var _had_connection: bool = false
var _warned_offline: bool = false
var _reconnect_timer: float = 0.0
var _should_connect: bool = false
var _last_position_emit_ms: int = 0
var _toast_timer: Timer
var _pomodoro_timer: Timer

var _oauth_state: String = ""
var _oauth_started_ms: int = 0
var _oauth_poll_timer: Timer
var _oauth_http: HTTPRequest
var _lobby_poll_timer: Timer
var _lobby_http: HTTPRequest
var _update_checking: bool = false
var _update_check_http: HTTPRequest
var _update_download_http: HTTPRequest
var _update_check_timer: Timer
var _update_download_path: String = ""


func now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


func _ready() -> void:
	randomize()
	app_version = str(ProjectSettings.get_setting("application/config/version", "1.0.0")).strip_edges()
	if app_version.is_empty():
		app_version = "1.0.0"
	_init_persistent_state()
	_setup_timers_and_http()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		check_for_updates()


func _init_persistent_state() -> void:
	host_key = _get_or_create_host_key()

	var stored_user: Variant = _load_json(AUTH_STORAGE_FILE, null)
	if stored_user is Dictionary and not (stored_user as Dictionary).is_empty():
		user = stored_user
		current_screen = "lobby"
	else:
		user = {}
		current_screen = "login"

	has_customized_character = FileAccess.file_exists(PROFILE_FILE)
	var saved_profile: Dictionary = _load_json(PROFILE_FILE, {
		"name": "Người chơi",
		"outfit": "c1",
		"customAvatar": GameData.DEFAULT_CUSTOM_AVATAR.duplicate(true),
		"tintColor": "#a78bfa",
	})
	if str(saved_profile.get("name", "")) == "Kaito" or str(saved_profile.get("name", "")).strip_edges().is_empty():
		saved_profile["name"] = "Người chơi"
		_save_json(PROFILE_FILE, saved_profile)

	if not (saved_profile.get("customAvatar") is Dictionary):
		saved_profile["customAvatar"] = GameData.DEFAULT_CUSTOM_AVATAR.duplicate(true)

	var default_todos: Array = [
		{
			"id": "todo-sample-1",
			"text": "Hoàn thành 1 phiên Focus 25 phút cùng nhau ✨",
			"completed": false,
			"createdAt": now_ms(),
		}
	]
	var loaded_todos: Variant = _load_json(TODOS_FILE, default_todos)
	todos = loaded_todos if loaded_todos is Array else default_todos

	var default_mixer := {
		"muted": false,
		"bgm": 0.45,
		"rain": 0.35,
		"fire": 0.0,
		"keyboard": 0.0,
		"wind": 0.15,
	}
	var loaded_mixer: Variant = _load_json(MIXER_FILE, default_mixer)
	audio_mixer = loaded_mixer if loaded_mixer is Dictionary else default_mixer
	SoundEngine.apply_mixer_state(audio_mixer)

	var default_gen := GameData.create_default_room_layout("GENERAL", host_key)
	var loaded_layout: Variant = _load_json("user://cozy_offline_layout_v2_GENERAL.json", default_gen)
	layout = loaded_layout if loaded_layout is Dictionary else default_gen

	local_player = {
		"id": "local-player",
		"name": str(saved_profile.get("name", "Người chơi")),
		"outfit": str(saved_profile.get("outfit", "c1")),
		"customAvatar": saved_profile.get("customAvatar", GameData.DEFAULT_CUSTOM_AVATAR).duplicate(true),
		"tintColor": str(saved_profile.get("tintColor", "#a78bfa")),
		"gx": 4.5,
		"gy": 5.5,
		"facing": "se",
		"isMoving": false,
		"isRunning": false,
		"activity": "idle",
		"statusText": "✨ Đang chill trong phòng",
	}
	players = {"local-player": local_player}

	if not user.is_empty() and str(user.get("name", "")) != "" and str(local_player["name"]) == "Người chơi":
		local_player["name"] = str(user["name"])

	pomodoro = {
		"isRunning": false,
		"mode": "focus",
		"remainingSec": POMODORO_DURATIONS["focus"],
		"totalSec": POMODORO_DURATIONS["focus"],
		"syncedWithRoom": true,
		"updatedAt": now_ms(),
	}

	show_profile_modal = not has_customized_character


func _setup_timers_and_http() -> void:
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.wait_time = 3.2
	_toast_timer.timeout.connect(func():
		toast_message = ""
		toast_shown.emit("")
		state_changed.emit()
	)
	add_child(_toast_timer)

	_pomodoro_timer = Timer.new()
	_pomodoro_timer.wait_time = 1.0
	_pomodoro_timer.autostart = true
	_pomodoro_timer.timeout.connect(tick_pomodoro)
	add_child(_pomodoro_timer)

	_oauth_http = HTTPRequest.new()
	_oauth_http.request_completed.connect(_on_oauth_poll_completed)
	add_child(_oauth_http)

	_oauth_poll_timer = Timer.new()
	_oauth_poll_timer.wait_time = 1.2
	_oauth_poll_timer.timeout.connect(_on_oauth_poll_tick)
	add_child(_oauth_poll_timer)

	_lobby_http = HTTPRequest.new()
	_lobby_http.request_completed.connect(_on_lobby_poll_completed)
	add_child(_lobby_http)

	_lobby_poll_timer = Timer.new()
	_lobby_poll_timer.wait_time = 4.0
	_lobby_poll_timer.autostart = true
	_lobby_poll_timer.timeout.connect(_on_lobby_poll_tick)
	add_child(_lobby_poll_timer)
	if current_screen == "lobby":
		call_deferred("_on_lobby_poll_tick")

	_update_check_http = HTTPRequest.new()
	_update_check_http.timeout = 12.0
	_update_check_http.request_completed.connect(_on_update_check_completed)
	add_child(_update_check_http)

	_update_download_http = HTTPRequest.new()
	_update_download_http.timeout = 300.0
	_update_download_http.use_threads = true
	_update_download_http.request_completed.connect(_on_update_download_completed)
	add_child(_update_download_http)

	_update_check_timer = Timer.new()
	_update_check_timer.wait_time = 60.0
	_update_check_timer.autostart = true
	_update_check_timer.timeout.connect(check_for_updates)
	add_child(_update_check_timer)

	if DisplayServer.get_name() != "headless":
		get_tree().create_timer(2.5).timeout.connect(check_for_updates)


func _process(delta: float) -> void:
	if update_downloading and _update_download_http != null:
		var total_bytes := _update_download_http.get_body_size()
		if total_bytes > 0:
			var downloaded_bytes := _update_download_http.get_downloaded_bytes()
			var pct := clampi(int(round(float(downloaded_bytes) / float(total_bytes) * 100.0)), 0, 100)
			if pct != update_progress_pct:
				update_progress_pct = pct
				update_state_changed.emit()

	if not _should_connect:
		return

	if _ws == null:
		_reconnect_timer -= delta
		if _reconnect_timer <= 0.0:
			_connect_websocket()
		return

	_ws.poll()
	var ws_state := _ws.get_ready_state()
	if ws_state == WebSocketPeer.STATE_OPEN:
		while _ws.get_available_packet_count() > 0:
			var pkt := _ws.get_packet().get_string_from_utf8()
			_handle_engine_io_packet(pkt)
	elif ws_state == WebSocketPeer.STATE_CLOSED:
		var was_conn := connected or _socket_connected
		_ws = null
		_socket_connected = false
		if connected:
			connected = false
			state_changed.emit()
		if not was_conn and not _warned_offline:
			_warned_offline = true
			show_toast("Đang kết nối tới máy chủ, vui lòng đợi...")
		_reconnect_timer = 2.5


func _get_or_create_host_key() -> String:
	if FileAccess.file_exists(HOST_KEY_FILE):
		var f := FileAccess.open(HOST_KEY_FILE, FileAccess.READ)
		if f != null:
			var content := f.get_as_text().strip_edges()
			if not content.is_empty():
				return content
	var created := "host-%s" % _random_id(8)
	var fw := FileAccess.open(HOST_KEY_FILE, FileAccess.WRITE)
	if fw != null:
		fw.store_string(created)
	return created


func _random_id(length: int) -> String:
	const CHARS := "abcdefghijklmnopqrstuvwxyz0123456789"
	var out := ""
	for i in range(length):
		out += CHARS[randi() % CHARS.length()]
	return out


func _load_json(path: String, fallback: Variant) -> Variant:
	if not FileAccess.file_exists(path):
		return fallback
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return fallback
	var text := f.get_as_text()
	if text.is_empty():
		return fallback
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		return fallback
	return parsed


func _save_json(path: String, value: Variant) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(value))


# ===================================================================
# AUTH ACTIONS
# ===================================================================

func login_with_user(u: Dictionary) -> void:
	var clean_user := u.duplicate(true)
	clean_user["isGuest"] = false
	user = clean_user
	_save_json(AUTH_STORAGE_FILE, user)
	auth_error = ""
	if str(user.get("name", "")) != "" and str(local_player.get("name", "")) == "Người chơi":
		update_local_profile({"name": str(user["name"])})
	set_screen("lobby")
	auth_changed.emit()


func login_as_guest(guest_name: String = "Khách Chill") -> void:
	var clean_name := guest_name.strip_edges()
	if clean_name.is_empty():
		clean_name = "Khách Chill"
	user = {
		"uid": "guest_%s" % _random_id(8),
		"name": clean_name,
		"email": "",
		"avatarUrl": "res://sprites/characters/c1/avatar.png",
		"isGuest": true,
	}
	_save_json(AUTH_STORAGE_FILE, user)
	auth_error = ""
	update_local_profile({"name": clean_name})
	set_screen("lobby")
	auth_changed.emit()


func logout() -> void:
	cancel_google_login()
	if FileAccess.file_exists(AUTH_STORAGE_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(AUTH_STORAGE_FILE))
	user = {}
	auth_error = ""
	if _socket_connected:
		emit_socket("room:leave")
	set_screen("login")
	auth_changed.emit()


func set_screen(screen: String) -> void:
	current_screen = screen
	if screen == "lobby":
		_on_lobby_poll_tick()
	screen_changed.emit(screen)
	state_changed.emit()


func clear_auth_error() -> void:
	auth_error = ""
	auth_changed.emit()


func start_google_login() -> void:
	auth_error = ""
	_oauth_state = "%d_%s" % [now_ms(), _random_id(8)]
	_oauth_started_ms = now_ms()
	var start_url := "%s/auth/google/start?state=%s" % [GameData.SERVER_URL, _oauth_state.uri_encode()]
	var err := OS.shell_open(start_url)
	if err != OK:
		auth_error = "Không thể mở trình duyệt để đăng nhập Google."
		is_waiting_google = false
		auth_changed.emit()
		return
	is_waiting_google = true
	_oauth_poll_timer.start()
	auth_changed.emit()


func cancel_google_login() -> void:
	is_waiting_google = false
	_oauth_poll_timer.stop()
	auth_changed.emit()


func _on_oauth_poll_tick() -> void:
	if not is_waiting_google:
		_oauth_poll_timer.stop()
		return
	if now_ms() - _oauth_started_ms > 3 * 60 * 1000:
		cancel_google_login()
		auth_error = "Hết thời gian chờ đăng nhập Google. Vui lòng thử lại."
		auth_changed.emit()
		return
	if _oauth_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var url := "%s/api/auth/google/status?state=%s" % [GameData.SERVER_URL, _oauth_state.uri_encode()]
	_oauth_http.request(url)


func _on_oauth_poll_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if not is_waiting_google or result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	var st := str(data.get("status", ""))
	if st == "success" and data.get("user") is Dictionary:
		cancel_google_login()
		login_with_user(data["user"])
	elif st == "error":
		cancel_google_login()
		auth_error = str(data.get("error", "Đăng nhập Google thất bại."))
		auth_changed.emit()


func _on_lobby_poll_tick() -> void:
	if current_screen != "lobby":
		return
	if _lobby_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	_lobby_http.request("%s/api/room-details" % GameData.SERVER_URL)


func _on_lobby_poll_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if parsed is Dictionary and parsed.has("GENERAL"):
		var gen: Variant = parsed["GENERAL"]
		if gen is Dictionary and gen.has("playerCount"):
			general_players_count = int(gen["playerCount"])
			lobby_stats_updated.emit(general_players_count)


# ===================================================================
# SOCKET.IO v4 CLIENT
# ===================================================================

func _connect_websocket() -> void:
	_ws = WebSocketPeer.new()
	var ws_url := GameData.SERVER_URL.replace("https://", "wss://").replace("http://", "ws://")
	ws_url = ws_url.trim_suffix("/") + "/socket.io/?EIO=4&transport=websocket"
	var err := _ws.connect_to_url(ws_url)
	if err != OK:
		_ws = null
		_reconnect_timer = 3.0


func emit_socket(event_name: String, payload: Variant = null) -> void:
	if not _socket_connected or _ws == null or _ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	var arr: Array = [event_name] if payload == null else [event_name, payload]
	_ws.send_text("42" + JSON.stringify(arr))


func _handle_engine_io_packet(pkt: String) -> void:
	if pkt.is_empty():
		return
	if pkt == "2":
		if _ws != null:
			_ws.send_text("3")
		return
	if pkt.begins_with("0"):
		if _ws != null:
			_ws.send_text("40")
		return
	if pkt.begins_with("40"):
		_socket_connected = true
		connected = true
		if _had_connection or _warned_offline:
			show_toast("Đã kết nối lại máy chủ")
		_had_connection = true
		_warned_offline = false
		if current_screen == "game":
			var clean := room_code
			var is_personal := _is_personal_code(clean)
			emit_socket("room:join", {
				"roomCode": clean,
				"hostKey": host_key,
				"player": local_player,
				"isPersonal": is_personal,
			})
		state_changed.emit()
		return
	if pkt.begins_with("41"):
		_socket_connected = false
		connected = false
		state_changed.emit()
		return
	if pkt.begins_with("42"):
		var bracket := pkt.find("[")
		if bracket < 0:
			return
		var json_str := pkt.substr(bracket)
		var parsed: Variant = JSON.parse_string(json_str)
		if parsed is Array and (parsed as Array).size() >= 1:
			var arr := parsed as Array
			var ev := str(arr[0])
			var data: Variant = arr[1] if arr.size() > 1 else {}
			_dispatch_socket_event(ev, data)


func _dispatch_socket_event(ev: String, data: Variant) -> void:
	match ev:
		"room:init":
			if not (data is Dictionary):
				return
			var payload: Dictionary = data
			room_code = str(payload.get("roomCode", room_code))
			my_player_id = str(payload.get("myId", my_player_id))
			is_host = bool(payload.get("isHost", false))
			if payload.get("layout") is Dictionary:
				layout = payload["layout"]
			if payload.get("players") is Dictionary:
				players = payload["players"]
			if players.has(my_player_id) and players[my_player_id] is Dictionary:
				local_player = players[my_player_id]
			else:
				local_player["id"] = my_player_id
			ghost_previews = {}
			if bool(pomodoro.get("syncedWithRoom", true)) and payload.get("pomodoro") is Dictionary:
				pomodoro = payload["pomodoro"]
				pomodoro_updated.emit()
			_save_json("user://cozy_offline_layout_v2_%s.json" % room_code, layout)
			layout_changed.emit()
			players_changed.emit()
			state_changed.emit()

		"player:joined":
			if data is Dictionary and data.get("player") is Dictionary:
				var p: Dictionary = data["player"]
				players[str(p.get("id", ""))] = p
				show_toast("👋 %s vừa vào phòng!" % str(p.get("name", "Khách")))
				players_changed.emit()

		"player:updated":
			if data is Dictionary and data.get("patch") is Dictionary:
				var pid := str(data.get("playerId", ""))
				var patch: Dictionary = data["patch"]
				players[pid] = patch
				if pid == my_player_id:
					local_player = patch
				players_changed.emit()

		"player:left":
			if data is Dictionary:
				var pid := str(data.get("playerId", ""))
				players.erase(pid)
				ghost_previews.erase(pid)
				players_changed.emit()

		"player:chatted":
			if data is Dictionary:
				var msg: Dictionary = data
				chat_messages.append(msg)
				if chat_messages.size() > 40:
					chat_messages = chat_messages.slice(chat_messages.size() - 40)
				var pid := str(msg.get("playerId", ""))
				var bubble := {
					"text": str(msg.get("text", "")),
					"expiresAt": int(msg.get("timestamp", now_ms())) + 5500,
				}
				if players.has(pid) and players[pid] is Dictionary:
					players[pid]["chatBubble"] = bubble
				if pid == my_player_id:
					local_player["chatBubble"] = bubble
				chat_updated.emit()
				players_changed.emit()

		"player:emoted":
			if data is Dictionary:
				var pid := str(data.get("playerId", ""))
				var emote := {
					"icon": str(data.get("icon", "❤️")),
					"expiresAt": int(data.get("expiresAt", now_ms() + 2600)),
				}
				if players.has(pid) and players[pid] is Dictionary:
					players[pid]["emote"] = emote
				if pid == my_player_id:
					local_player["emote"] = emote
				players_changed.emit()

		"room:layout_updated":
			if data is Dictionary:
				layout = data
				is_host = str(layout.get("hostId", "")) == host_key
				if not can_build():
					build_mode = false
				_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
				layout_changed.emit()
				state_changed.emit()

		"room:item_toggled":
			if data is Dictionary:
				var uid := str(data.get("uid", ""))
				var toggled := bool(data.get("toggled", false))
				var items: Array = layout.get("items", [])
				for item in items:
					if item is Dictionary and str(item.get("uid", "")) == uid:
						item["toggled"] = toggled
						break
				layout_changed.emit()

		"room:preview_updated":
			if data is Dictionary:
				var pid := str(data.get("playerId", ""))
				var prev: Variant = data.get("preview")
				if prev is Dictionary:
					ghost_previews[pid] = prev
				else:
					ghost_previews.erase(pid)

		"pomodoro:updated":
			if data is Dictionary and bool(pomodoro.get("syncedWithRoom", true)):
				pomodoro = data
				pomodoro_updated.emit()
				state_changed.emit()

		"room:kicked":
			var reason := "Bạn đã được chủ phòng mời ra khỏi phòng"
			if data is Dictionary and not str(data.get("reason", "")).is_empty():
				reason = str(data["reason"])
			show_toast(reason)

		"room:toast":
			if data is Dictionary and data.has("message"):
				show_toast(str(data["message"]))


# ===================================================================
# ROOM & UI STATE ACTIONS
# ===================================================================

func _is_personal_code(code: String) -> bool:
	return code.begins_with("ROOM_") or code.begins_with("MY_") or code.begins_with("P_")


func show_toast(msg: String) -> void:
	toast_message = msg
	_toast_timer.start()
	toast_shown.emit(msg)
	state_changed.emit()


func set_show_audio_mixer(v: bool) -> void:
	show_audio_mixer = v
	state_changed.emit()


func set_show_focus_panel(v: bool) -> void:
	show_focus_panel = v
	state_changed.emit()


func set_show_room_modal(v: bool) -> void:
	show_room_modal = v
	state_changed.emit()


func set_show_profile_modal(v: bool) -> void:
	show_profile_modal = v
	state_changed.emit()


func init_network(target_room: String = "") -> void:
	var clean := target_room.strip_edges().to_upper().substr(0, 24)
	if clean.is_empty():
		clean = room_code if not room_code.is_empty() else "GENERAL"
	room_code = clean
	_should_connect = true

	if _socket_connected:
		if current_screen == "game":
			emit_socket("room:join", {
				"roomCode": clean,
				"hostKey": host_key,
				"player": local_player,
				"isPersonal": _is_personal_code(clean),
			})
		return

	if _ws == null:
		_connect_websocket()


func join_room(target_room: String, is_personal_opt: bool = false) -> void:
	var clean := target_room.strip_edges().to_upper().substr(0, 24)
	if clean.is_empty():
		clean = "GENERAL"
	build_mode = false
	selected_catalog_id = ""
	moving_item_uid = ""
	room_code = clean

	var is_personal := is_personal_opt or _is_personal_code(clean)
	if _socket_connected:
		emit_socket("room:join", {
			"roomCode": clean,
			"hostKey": host_key,
			"player": local_player,
			"isPersonal": is_personal,
		})
		show_toast("Đang vào phòng #%s" % clean)
	else:
		var fallback_layout := (
			GameData.create_personal_room_layout(clean, host_key, str(local_player.get("name", "Chủ phòng")))
			if is_personal
			else GameData.create_default_room_layout(clean, host_key)
		)
		var offline_path := "user://cozy_offline_layout_v2_%s.json" % clean
		var loaded: Variant = _load_json(offline_path, fallback_layout)
		layout = loaded if loaded is Dictionary else fallback_layout
		players = {my_player_id: local_player}
		is_host = str(layout.get("hostId", "")) == host_key
		init_network(clean)
		show_toast("Chưa kết nối máy chủ, sẽ tự vào phòng #%s khi kết nối xong" % clean)
		layout_changed.emit()
		players_changed.emit()
		state_changed.emit()


func leave_room_to_lobby() -> void:
	emit_socket("room:leave")
	build_mode = false
	selected_catalog_id = ""
	moving_item_uid = ""
	players = {}
	ghost_previews = {}
	set_screen("lobby")


# ===================================================================
# PLAYER ACTIONS
# ===================================================================

func update_local_profile(patch: Dictionary) -> void:
	for k in patch.keys():
		local_player[k] = patch[k]
	_save_json(PROFILE_FILE, {
		"name": local_player.get("name", "Người chơi"),
		"outfit": local_player.get("outfit", "c1"),
		"customAvatar": local_player.get("customAvatar", GameData.DEFAULT_CUSTOM_AVATAR),
		"tintColor": local_player.get("tintColor", "#a78bfa"),
	})
	has_customized_character = true
	players[my_player_id] = local_player
	emit_socket("player:update", patch)
	players_changed.emit()
	state_changed.emit()


func move_local_player(patch: Dictionary) -> void:
	var is_seated := not str(local_player.get("seatedOnItemUid", "")).is_empty() or str(local_player.get("activity", "idle")) == "sit_floor"
	var next_activity: String = str(local_player.get("activity", "idle"))
	if not is_seated:
		next_activity = "walking" if bool(patch.get("isMoving", false)) else "idle"

	var status_text: String = str(local_player.get("statusText", ""))
	if pinned_todo_id.is_empty():
		match next_activity:
			"focus_desk": status_text = "🔥 Đang Focus"
			"chill_sofa": status_text = "☕ Đang Chill"
			"sit_floor": status_text = "🧘 Đang ngồi bệt"
			_: status_text = "✨ Đang dạo phòng"

	for k in patch.keys():
		local_player[k] = patch[k]
	local_player["activity"] = next_activity
	local_player["statusText"] = status_text

	SoundEngine.set_focus_activity(next_activity == "focus_desk")
	players[my_player_id] = local_player

	var t_ms := Time.get_ticks_msec()
	if t_ms - _last_position_emit_ms >= 45 or not bool(patch.get("isMoving", false)):
		_last_position_emit_ms = t_ms
		emit_socket("player:update", {
			"gx": snappedf(float(local_player.get("gx", 4.5)), 0.01),
			"gy": snappedf(float(local_player.get("gy", 5.5)), 0.01),
			"facing": local_player.get("facing", "se"),
			"isMoving": bool(local_player.get("isMoving", false)),
			"isRunning": bool(local_player.get("isRunning", false)),
			"activity": next_activity,
			"statusText": status_text,
		})


func seat_at_item(item_uid: String, slot_id: String, gx: float, gy: float, activity: String, facing: String) -> void:
	var status_text := str(local_player.get("statusText", ""))
	if pinned_todo_id.is_empty():
		if activity == "focus_desk":
			status_text = "💻 Đang ngồi Focus"
		elif activity == "sit_floor":
			status_text = "🧘 Đang ngồi thảm Chill"
		else:
			status_text = "🛋️ Đang ngồi Chill"

	local_player["gx"] = gx
	local_player["gy"] = gy
	local_player["facing"] = facing
	local_player["isMoving"] = false
	local_player["isRunning"] = false
	local_player["activity"] = activity
	local_player["seatedOnItemUid"] = item_uid
	local_player["seatSlotId"] = slot_id
	local_player["statusText"] = status_text

	SoundEngine.set_focus_activity(activity == "focus_desk")
	SoundEngine.play_sfx("interact")

	players[my_player_id] = local_player
	emit_socket("player:update", {
		"gx": gx,
		"gy": gy,
		"facing": facing,
		"isMoving": false,
		"isRunning": false,
		"activity": activity,
		"seatedOnItemUid": item_uid,
		"seatSlotId": slot_id,
		"statusText": status_text,
	})
	players_changed.emit()
	state_changed.emit()


func sit_on_floor() -> void:
	if str(local_player.get("activity", "idle")) == "sit_floor" or not str(local_player.get("seatedOnItemUid", "")).is_empty():
		stand_up()
		return

	var status_text := str(local_player.get("statusText", ""))
	if pinned_todo_id.is_empty():
		status_text = "🧘 Đang ngồi chill dưới sàn"

	local_player["facing"] = "se"
	local_player["isMoving"] = false
	local_player["isRunning"] = false
	local_player["activity"] = "sit_floor"
	local_player.erase("seatedOnItemUid")
	local_player.erase("seatSlotId")
	local_player["statusText"] = status_text

	SoundEngine.set_focus_activity(false)
	SoundEngine.play_sfx("interact")

	players[my_player_id] = local_player
	emit_socket("player:update", {
		"facing": "se",
		"isMoving": false,
		"isRunning": false,
		"activity": "sit_floor",
		"seatedOnItemUid": null,
		"seatSlotId": null,
		"statusText": status_text,
	})
	players_changed.emit()
	state_changed.emit()


func stand_up() -> void:
	if str(local_player.get("seatedOnItemUid", "")).is_empty() and str(local_player.get("activity", "idle")) != "sit_floor":
		return

	var status_text := str(local_player.get("statusText", ""))
	if pinned_todo_id.is_empty():
		status_text = "✨ Đang dạo phòng"

	local_player["activity"] = "idle"
	local_player.erase("seatedOnItemUid")
	local_player.erase("seatSlotId")
	local_player["statusText"] = status_text

	SoundEngine.set_focus_activity(false)
	players[my_player_id] = local_player
	emit_socket("player:update", {
		"activity": "idle",
		"seatedOnItemUid": null,
		"seatSlotId": null,
		"statusText": status_text,
	})
	players_changed.emit()
	state_changed.emit()


func send_chat(text: String) -> void:
	var clean := text.strip_edges().substr(0, 140)
	if clean.is_empty():
		return
	SoundEngine.play_sfx("interact")
	if _socket_connected:
		emit_socket("player:chat", {"text": clean})
	else:
		var t := now_ms()
		var msg := {
			"id": "local-%d" % t,
			"playerId": my_player_id,
			"name": local_player.get("name", "Người chơi"),
			"tintColor": local_player.get("tintColor", "#a78bfa"),
			"text": clean,
			"timestamp": t,
		}
		chat_messages.append(msg)
		if chat_messages.size() > 40:
			chat_messages = chat_messages.slice(chat_messages.size() - 40)
		var bubble := {"text": clean, "expiresAt": t + 5500}
		local_player["chatBubble"] = bubble
		players[my_player_id] = local_player
		chat_updated.emit()
		players_changed.emit()


func send_emote(icon: String) -> void:
	SoundEngine.play_sfx("solve")
	if _socket_connected:
		emit_socket("player:emote", {"icon": icon})
	else:
		var emote := {"icon": icon, "expiresAt": now_ms() + 2600}
		local_player["emote"] = emote
		players[my_player_id] = local_player
		players_changed.emit()


# ===================================================================
# DECOR / BUILD ACTIONS
# ===================================================================

func can_build() -> bool:
	return is_host or bool(layout.get("allowGuestBuild", false))


func toggle_build_mode(force_val: int = -1) -> void:
	if not can_build():
		show_toast("🔒 Chỉ Chủ phòng mới có quyền xây & trang trí!")
		return
	var next := (not build_mode) if force_val < 0 else (force_val > 0)
	if not next:
		emit_preview(null)
	build_mode = next
	if not next:
		selected_catalog_id = ""
		active_floor_brush = ""
		active_wall_brush = ""
	moving_item_uid = ""
	state_changed.emit()


func set_build_tab(tab: String) -> void:
	build_tab = tab
	if tab == "floor":
		if active_wall_brush.is_empty():
			if active_floor_brush.is_empty():
				active_floor_brush = "W"
		selected_catalog_id = ""
	else:
		active_floor_brush = ""
		active_wall_brush = ""
	moving_item_uid = ""
	state_changed.emit()


func set_active_floor_brush(brush: String) -> void:
	active_floor_brush = brush
	active_wall_brush = ""
	selected_catalog_id = ""
	moving_item_uid = ""
	state_changed.emit()


func set_active_wall_brush(brush: String) -> void:
	active_wall_brush = brush
	active_floor_brush = ""
	selected_catalog_id = ""
	moving_item_uid = ""
	state_changed.emit()


func select_catalog_item(catalog_id: String) -> void:
	selected_catalog_id = catalog_id
	active_floor_brush = ""
	active_wall_brush = ""
	moving_item_uid = ""
	place_flipped = false
	state_changed.emit()


func start_moving_item(uid: String) -> void:
	if uid.is_empty():
		moving_item_uid = ""
		emit_preview(null)
		state_changed.emit()
		return
	var items: Array = layout.get("items", [])
	var existing_flipped := false
	for item in items:
		if item is Dictionary and str(item.get("uid", "")) == uid:
			existing_flipped = bool(item.get("flipped", false))
			break
	moving_item_uid = uid
	selected_catalog_id = ""
	active_floor_brush = ""
	active_wall_brush = ""
	place_flipped = existing_flipped
	state_changed.emit()


func toggle_place_flipped() -> void:
	place_flipped = not place_flipped
	state_changed.emit()


func emit_preview(preview: Variant) -> void:
	if _socket_connected and can_build():
		emit_socket("room:preview_item", {"preview": preview})


func paint_tile(gx: int, gy: int, tile: String) -> void:
	if not can_build():
		return
	var floor_map: Array = layout.get("floorMap", [])
	if gy < 0 or gy >= floor_map.size():
		return
	var row := str(floor_map[gy])
	if gx < 0 or gx >= row.length():
		return
	if row[gx] == tile:
		return

	var max_floor := int(layout.get("maxFloorTiles", 0))
	if row[gx] == "." and tile != "." and max_floor > 0:
		if GameData.count_floor_tiles(floor_map) >= max_floor:
			show_toast("⚠️ Đã đạt giới hạn tối đa %d ô sàn!" % max_floor)
			return

	var next_row := row.substr(0, gx) + tile + row.substr(gx + 1)
	var next_floor_map: Array = floor_map.duplicate()
	next_floor_map[gy] = next_row
	layout["floorMap"] = next_floor_map

	SoundEngine.play_sfx("step")
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:update_floor", {"floorMap": next_floor_map})
	layout_changed.emit()
	state_changed.emit()


func toggle_wall_segment(wall_key: String, mode: String = "") -> void:
	if not can_build():
		return
	var current_walls: Array = []
	if layout.has("walls") and layout["walls"] is Array:
		current_walls = (layout["walls"] as Array).duplicate()
	else:
		current_walls = GameData.auto_generate_walls_from_floor(layout.get("floorMap", []), 200)

	var idx := current_walls.find(wall_key)
	if mode == "remove" or (mode != "add" and idx >= 0):
		if idx < 0:
			return
		current_walls.remove_at(idx)
	else:
		if idx >= 0:
			return
		var limit := int(layout.get("maxWallTiles", 200))
		if limit <= 0:
			limit = 200
		if current_walls.size() >= limit:
			show_toast("⚠️ Đã đạt giới hạn tối đa %d ô tường!" % limit)
			return
		current_walls.append(wall_key)

	layout["walls"] = current_walls
	SoundEngine.play_sfx("interact")
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:update_floor", {"walls": current_walls})
	layout_changed.emit()
	state_changed.emit()


func auto_build_walls() -> void:
	if not can_build():
		return
	var limit := int(layout.get("maxWallTiles", 200))
	if limit <= 0:
		limit = 200
	var next_walls := GameData.auto_generate_walls_from_floor(layout.get("floorMap", []), limit)
	layout["walls"] = next_walls
	SoundEngine.play_sfx("interact")
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:update_floor", {"walls": next_walls})
	show_toast("🧱 Đã tự động bo %d/%d ô tường theo hình dáng sàn!" % [next_walls.size(), limit])
	layout_changed.emit()
	state_changed.emit()


func expand_floor_grid() -> void:
	if not can_build():
		return
	var floor_map: Array = layout.get("floorMap", [])
	var h := floor_map.size()
	var w := 0
	for r in floor_map:
		w = maxi(w, str(r).length())
	if h >= 14 or w >= 14:
		show_toast("📐 Đã đạt kích thước tối đa 14x14!")
		return
	var next_map: Array = []
	for r in floor_map:
		next_map.append(str(r) + "W")
	next_map.append("W".repeat(w + 1))
	layout["floorMap"] = next_map
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:update_floor", {"floorMap": next_map})
	show_toast("📐 Đã mở rộng sàn lên %dx%d" % [w + 1, h + 1])
	layout_changed.emit()
	state_changed.emit()


func shrink_floor_grid() -> void:
	if not can_build():
		return
	var floor_map: Array = layout.get("floorMap", [])
	var h := floor_map.size()
	var w := 0
	for r in floor_map:
		w = maxi(w, str(r).length())
	if h <= 6 or w <= 6:
		show_toast("📐 Kích thước tối thiểu là 6x6!")
		return
	var next_map: Array = []
	for i in range(h - 1):
		var r := str(floor_map[i])
		next_map.append(r.substr(0, maxi(0, w - 1)))
	layout["floorMap"] = next_map
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:update_floor", {"floorMap": next_map})
	show_toast("📐 Đã thu gọn sàn xuống %dx%d" % [w - 1, h - 1])
	layout_changed.emit()
	state_changed.emit()


func set_wall_theme(wall_theme: String) -> void:
	if not can_build():
		return
	layout["wallTheme"] = wall_theme
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:update_floor", {"wallTheme": wall_theme})
	layout_changed.emit()
	state_changed.emit()


func set_lighting_mode(lighting_mode: String) -> void:
	layout["lightingMode"] = lighting_mode
	if can_build():
		_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
		emit_socket("room:update_floor", {"lightingMode": lighting_mode})
	layout_changed.emit()
	state_changed.emit()


func toggle_rain() -> void:
	var rain_enabled := not bool(layout.get("rainEnabled", false))
	layout["rainEnabled"] = rain_enabled
	if can_build():
		_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
		emit_socket("room:update_floor", {"rainEnabled": rain_enabled})
	layout_changed.emit()
	state_changed.emit()


func set_allow_guest_build(allow: bool) -> void:
	if not is_host:
		return
	layout["allowGuestBuild"] = allow
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:set_guest_build", {"allowGuestBuild": allow})
	show_toast(
		"🤝 Đã cho phép khách trong phòng cùng sửa nhà!"
		if allow
		else "🔒 Đã tắt quyền sửa nhà của khách."
	)
	state_changed.emit()


func place_or_update_item(item: Dictionary) -> void:
	if not can_build():
		return
	var items: Array = layout.get("items", [])
	var uid := str(item.get("uid", ""))
	var old_idx := -1
	for i in range(items.size()):
		if items[i] is Dictionary and str(items[i].get("uid", "")) == uid:
			old_idx = i
			break

	var max_items := int(layout.get("maxItems", 0))
	if old_idx < 0 and max_items > 0 and items.size() >= max_items:
		show_toast("⚠️ Đã đạt giới hạn tối đa %d đồ vật trong phòng!" % max_items)
		return

	SoundEngine.play_sfx("interact")
	var next_items: Array = items.duplicate(true)
	if old_idx >= 0:
		var old: Dictionary = next_items[old_idx]
		var dx := float(item.get("gx", 0.0)) - float(old.get("gx", 0.0))
		var dy := float(item.get("gy", 0.0)) - float(old.get("gy", 0.0))
		next_items[old_idx] = item
		for j in range(next_items.size()):
			var child: Dictionary = next_items[j]
			if str(child.get("parentSurfaceUid", "")) == uid:
				child["gx"] = snappedf(float(child.get("gx", 0.0)) + dx, 0.01)
				child["gy"] = snappedf(float(child.get("gy", 0.0)) + dy, 0.01)
	else:
		next_items.append(item)

	layout["items"] = next_items
	moving_item_uid = ""
	emit_preview(null)
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:place_item", {"item": item})
	layout_changed.emit()
	state_changed.emit()


func remove_item(uid: String) -> void:
	if not can_build():
		return
	SoundEngine.play_sfx("interact")
	var items: Array = layout.get("items", [])
	var removed_ids := {uid: true}
	for item in items:
		if item is Dictionary and str(item.get("parentSurfaceUid", "")) == uid:
			removed_ids[str(item.get("uid", ""))] = true

	var next_items: Array = []
	for item in items:
		if item is Dictionary and not removed_ids.has(str(item.get("uid", ""))):
			next_items.append(item)
	layout["items"] = next_items

	var seated_uid := str(local_player.get("seatedOnItemUid", ""))
	if not seated_uid.is_empty() and removed_ids.has(seated_uid):
		stand_up()

	if moving_item_uid == uid:
		moving_item_uid = ""
	emit_preview(null)
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:remove_item", {"uid": uid})
	layout_changed.emit()
	state_changed.emit()


func toggle_item_interaction(uid: String) -> void:
	var items: Array = layout.get("items", [])
	for item in items:
		if item is Dictionary and str(item.get("uid", "")) == uid:
			var meta := GameData.get_catalog_item(str(item.get("catalogId", "")))
			if str(meta.get("altSprite", "")).is_empty():
				return
			SoundEngine.play_sfx("interact")
			item["toggled"] = not bool(item.get("toggled", false))
			emit_socket("room:toggle_item", {"uid": uid})
			layout_changed.emit()
			return


func reset_default_room() -> void:
	if not is_host:
		return
	var is_personal := bool(layout.get("isPersonal", false))
	layout = (
		GameData.create_personal_room_layout(room_code, host_key, str(local_player.get("name", "Chủ phòng")))
		if is_personal
		else GameData.create_default_room_layout(room_code, host_key)
	)
	moving_item_uid = ""
	selected_catalog_id = ""
	_save_json("user://cozy_offline_layout_v2_%s.json" % str(layout.get("roomCode", room_code)), layout)
	emit_socket("room:reset_default")
	show_toast("🏡 Đã khôi phục căn hộ mẫu ấm cúng!")
	layout_changed.emit()
	state_changed.emit()


func kick_player(player_id: String) -> void:
	if not is_host:
		return
	emit_socket("room:kick_player", {"playerId": player_id})
	players.erase(player_id)
	show_toast("Đã mời người chơi ra khỏi phòng")
	players_changed.emit()
	state_changed.emit()


# ===================================================================
# POMODORO & TODOS
# ===================================================================

func start_pomodoro() -> void:
	pomodoro["isRunning"] = true
	pomodoro["updatedAt"] = now_ms()
	SoundEngine.play_sfx("interact")
	if bool(pomodoro.get("syncedWithRoom", true)):
		emit_socket("pomodoro:sync", {"pomodoro": pomodoro})
	pomodoro_updated.emit()
	state_changed.emit()


func pause_pomodoro() -> void:
	pomodoro["isRunning"] = false
	pomodoro["updatedAt"] = now_ms()
	if bool(pomodoro.get("syncedWithRoom", true)):
		emit_socket("pomodoro:sync", {"pomodoro": pomodoro})
	pomodoro_updated.emit()
	state_changed.emit()


func reset_pomodoro() -> void:
	var mode := str(pomodoro.get("mode", "focus"))
	var sec := int(POMODORO_DURATIONS.get(mode, 25 * 60))
	pomodoro["isRunning"] = false
	pomodoro["remainingSec"] = sec
	pomodoro["totalSec"] = sec
	pomodoro["updatedAt"] = now_ms()
	if bool(pomodoro.get("syncedWithRoom", true)):
		emit_socket("pomodoro:sync", {"pomodoro": pomodoro})
	pomodoro_updated.emit()
	state_changed.emit()


func switch_pomodoro_mode(mode: String) -> void:
	var sec := int(POMODORO_DURATIONS.get(mode, 25 * 60))
	pomodoro["mode"] = mode
	pomodoro["isRunning"] = false
	pomodoro["remainingSec"] = sec
	pomodoro["totalSec"] = sec
	pomodoro["updatedAt"] = now_ms()
	if bool(pomodoro.get("syncedWithRoom", true)):
		emit_socket("pomodoro:sync", {"pomodoro": pomodoro})
	pomodoro_updated.emit()
	state_changed.emit()


func toggle_pomodoro_room_sync() -> void:
	pomodoro["syncedWithRoom"] = not bool(pomodoro.get("syncedWithRoom", true))
	if bool(pomodoro["syncedWithRoom"]):
		emit_socket("pomodoro:sync", {"pomodoro": pomodoro})
	pomodoro_updated.emit()
	state_changed.emit()


func tick_pomodoro() -> void:
	if not bool(pomodoro.get("isRunning", false)):
		return
	var rem := int(pomodoro.get("remainingSec", 0))
	if rem <= 1:
		SoundEngine.play_sfx("fanfare")
		var cur_mode := str(pomodoro.get("mode", "focus"))
		var next_mode := "short_break" if cur_mode == "focus" else "focus"
		var next_sec := int(POMODORO_DURATIONS[next_mode])
		if cur_mode == "focus":
			completed_pomodoros += 1
		pomodoro["isRunning"] = false
		pomodoro["mode"] = next_mode
		pomodoro["remainingSec"] = next_sec
		pomodoro["totalSec"] = next_sec
		pomodoro["updatedAt"] = now_ms()
		show_toast(
			"🎉 Hoàn thành phiên Focus! Nghỉ giải lao chút nhé 💕"
			if cur_mode == "focus"
			else "⏰ Hết giờ nghỉ rồi! Quay lại Focus nào!"
		)
		pomodoro_updated.emit()
		state_changed.emit()
		return

	pomodoro["remainingSec"] = rem - 1
	pomodoro_updated.emit()


func add_todo(text: String) -> void:
	var clean := text.strip_edges()
	if clean.is_empty():
		return
	var item := {
		"id": "todo-%d-%s" % [now_ms(), _random_id(4)],
		"text": clean,
		"completed": false,
		"createdAt": now_ms(),
	}
	todos.insert(0, item)
	_save_json(TODOS_FILE, todos)
	state_changed.emit()


func toggle_todo(id: String) -> void:
	for t in todos:
		if t is Dictionary and str(t.get("id", "")) == id:
			t["completed"] = not bool(t.get("completed", false))
			if bool(t["completed"]):
				SoundEngine.play_sfx("solve")
			break
	_save_json(TODOS_FILE, todos)
	state_changed.emit()


func delete_todo(id: String) -> void:
	var next: Array = []
	for t in todos:
		if t is Dictionary and str(t.get("id", "")) != id:
			next.append(t)
	todos = next
	var was_pinned := (pinned_todo_id == id)
	if was_pinned:
		pinned_todo_id = ""
	_save_json(TODOS_FILE, todos)
	if was_pinned:
		pin_todo("")
	else:
		state_changed.emit()


func pin_todo(id: String) -> void:
	var target: Dictionary = {}
	if not id.is_empty():
		for t in todos:
			if t is Dictionary and str(t.get("id", "")) == id:
				target = t
				break

	var status_text := ""
	if not target.is_empty():
		status_text = "📝 %s" % str(target.get("text", "")).substr(0, 26)
		pinned_todo_id = str(target["id"])
	else:
		pinned_todo_id = ""
		status_text = (
			"💻 Đang ngồi Focus"
			if str(local_player.get("activity", "idle")) == "focus_desk"
			else "✨ Đang chill trong phòng"
		)

	local_player["statusText"] = status_text
	players[my_player_id] = local_player
	emit_socket("player:update", {"statusText": status_text})
	players_changed.emit()
	state_changed.emit()


# ===================================================================
# AUDIO MIXER
# ===================================================================

func set_channel_volume(channel: String, vol: float) -> void:
	SoundEngine.unlock_audio()
	var clamped := clampf(vol, 0.0, 1.0)
	audio_mixer[channel] = clamped
	SoundEngine.set_channel_volume(channel, clamped)
	_save_json(MIXER_FILE, audio_mixer)
	state_changed.emit()


func toggle_master_mute() -> void:
	SoundEngine.unlock_audio()
	var muted := not bool(audio_mixer.get("muted", false))
	audio_mixer["muted"] = muted
	SoundEngine.set_master_mute(muted)
	_save_json(MIXER_FILE, audio_mixer)
	state_changed.emit()


# ===================================================================
# DESKTOP COMPANION WINDOW CONTROLS
# ===================================================================

func is_embedded_display() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	if Engine.is_embedded_in_editor() or OS.has_feature("embedded"):
		return true
	var dname := DisplayServer.get_name().to_lower()
	if dname.contains("embed"):
		return true
	for arg in OS.get_cmdline_args():
		if arg == "--embedded" or arg.begins_with("--embedded"):
			return true
	return false


func toggle_fullscreen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if is_embedded_display():
		var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "--fullscreen"])
		var pid := OS.create_process(OS.get_executable_path(), args)
		if pid > 0:
			show_toast("🖥️ Đã mở cửa sổ Toàn Màn Hình Retina riêng! Bạn có thể đóng khung nhỏ này.")
		else:
			show_toast("⚠️ Hãy nhấn Cmd+S rồi chạy lại Project để thoát chế độ nhúng!")
		return
	var cur_mode := DisplayServer.window_get_mode()
	if cur_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or cur_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		is_fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		is_fullscreen = true
	state_changed.emit()


func toggle_always_on_top() -> void:
	always_on_top = not always_on_top
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, always_on_top)
	show_toast(
		"📌 Đã ghim cửa sổ nổi trên mọi ứng dụng (Always-on-top)"
		if always_on_top
		else "📌 Đã bỏ ghim cửa sổ nổi"
	)
	state_changed.emit()


func toggle_mini_mode() -> void:
	mini_mode = not mini_mode
	if DisplayServer.get_name() != "headless":
		if mini_mode:
			DisplayServer.window_set_size(Vector2i(420, 420))
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
			always_on_top = true
		else:
			DisplayServer.window_set_size(Vector2i(1280, 800))
	state_changed.emit()


# ===================================================================
# AUTO-UPDATER (GITHUB RELEASES)
# ===================================================================

func check_for_updates() -> void:
	if DisplayServer.get_name() == "headless" or OS.has_feature("web"):
		return
	if _update_checking or update_downloading or _update_check_http == null:
		return
	if _update_check_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	_update_checking = true
	var url := "%s?t=%d" % [LATEST_MANIFEST_URL, now_ms()]
	var headers := PackedStringArray([
		"Accept: application/json",
		"User-Agent: CozyFocusRoom-Godot",
	])
	var err := _update_check_http.request(url, headers)
	if err != OK:
		_update_checking = false


func _on_update_check_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_update_checking = false
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return

	var text := body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return

	var data: Dictionary = parsed
	var remote_v := str(data.get("version", "")).strip_edges().lstrip("vV")
	if remote_v.is_empty() or not is_newer_version(remote_v, app_version):
		if update_available:
			update_available = false
			update_state_changed.emit()
		return

	var plats_raw: Variant = data.get("platforms", {})
	var platforms: Dictionary = plats_raw if plats_raw is Dictionary else {}
	var chosen_url := _pick_platform_update_url(platforms)

	var prev_latest := latest_version
	latest_version = remote_v
	update_notes = str(data.get("notes", "")).strip_edges()
	update_download_url = chosen_url
	update_available = true
	update_error = ""
	if prev_latest != latest_version and update_dismissed_version != latest_version:
		update_dismissed_version = ""
	update_state_changed.emit()


func _pick_platform_update_url(platforms: Dictionary) -> String:
	var os_name := OS.get_name()
	var keys: Array[String] = []
	if os_name == "macOS":
		var arch := Engine.get_architecture_name().to_lower()
		if arch.contains("arm") or arch.contains("aarch64"):
			keys = ["darwin-aarch64", "macos-universal", "darwin-x86_64"]
		else:
			keys = ["darwin-x86_64", "macos-universal", "darwin-aarch64"]
	elif os_name == "Windows":
		keys = ["windows-x86_64"]
	elif os_name == "Linux":
		keys = ["linux-x86_64"]

	for k in keys:
		var entry_raw: Variant = platforms.get(k, null)
		if entry_raw is Dictionary:
			var entry: Dictionary = entry_raw
			var u := str(entry.get("url", "")).strip_edges()
			if not u.is_empty():
				return u
	return ""


func is_newer_version(remote_v: String, local_v: String) -> bool:
	var r_clean := remote_v.strip_edges().lstrip("vV").split("-")[0].split("+")[0]
	var l_clean := local_v.strip_edges().lstrip("vV").split("-")[0].split("+")[0]
	var r_parts := r_clean.split(".")
	var l_parts := l_clean.split(".")
	var count := maxi(r_parts.size(), l_parts.size())
	for i in range(count):
		var rv := int(r_parts[i]) if i < r_parts.size() and r_parts[i].is_valid_int() else 0
		var lv := int(l_parts[i]) if i < l_parts.size() and l_parts[i].is_valid_int() else 0
		if rv > lv:
			return true
		if rv < lv:
			return false
	return false


func dismiss_update() -> void:
	if update_downloading:
		return
	update_dismissed_version = latest_version
	update_state_changed.emit()


func start_update_download_and_install() -> void:
	if update_downloading:
		return
	if update_download_url.is_empty() or _update_download_http == null:
		OS.shell_open(GITHUB_RELEASE_PAGE_URL)
		return

	var update_dir := ProjectSettings.globalize_path("user://updates")
	DirAccess.make_dir_recursive_absolute(update_dir)

	var ext := ".zip"
	var lower_url := update_download_url.to_lower()
	if lower_url.ends_with(".exe"):
		ext = ".exe"
	elif lower_url.ends_with(".dmg"):
		ext = ".dmg"

	_update_download_path = update_dir.path_join("CozyFocusRoom_%s%s" % [latest_version, ext])
	if FileAccess.file_exists(_update_download_path):
		DirAccess.remove_absolute(_update_download_path)

	_update_download_http.download_file = _update_download_path
	update_downloading = true
	update_progress_pct = 0
	update_error = ""
	update_state_changed.emit()

	var headers := PackedStringArray(["User-Agent: CozyFocusRoom-Godot"])
	var err := _update_download_http.request(update_download_url, headers)
	if err != OK:
		update_downloading = false
		update_error = "Không thể khởi tạo tải bản cập nhật (lỗi %d)." % err
		update_state_changed.emit()


func _on_update_download_completed(result: int, response_code: int, _headers: PackedByteArray, _body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 400 or not FileAccess.file_exists(_update_download_path):
		update_downloading = false
		update_error = "Không thể tải bản cập nhật (HTTP %d). Vui lòng thử lại." % response_code
		update_state_changed.emit()
		return

	update_progress_pct = 100
	update_state_changed.emit()

	var os_name := OS.get_name()
	var exe_path := OS.get_executable_path()
	var is_editor := OS.has_feature("editor")

	if os_name == "macOS":
		var app_marker := ".app/Contents/MacOS/"
		var app_idx := exe_path.find(app_marker)
		if not is_editor and app_idx != -1 and _update_download_path.to_lower().ends_with(".zip"):
			var current_app := exe_path.substr(0, app_idx + 4)
			var script_path := ProjectSettings.globalize_path("user://updates/apply_update.sh")
			var script_content := (
				"#!/bin/sh\n" +
				"sleep 1\n" +
				"STAGE=\"$(mktemp -d)\"\n" +
				"ditto -x -k \"%s\" \"$STAGE\" || exit 1\n" +
				"NEW_APP=\"$(find \"$STAGE\" -maxdepth 2 -name '*.app' -print -quit)\"\n" +
				"[ -n \"$NEW_APP\" ] || exit 1\n" +
				"rm -rf \"%s.bak\"\n" +
				"mv \"%s\" \"%s.bak\" && mv \"$NEW_APP\" \"%s\" || { mv \"%s.bak\" \"%s\"; exit 1; }\n" +
				"rm -rf \"%s.bak\" \"$STAGE\"\n" +
				"xattr -cr \"%s\" 2>/dev/null || true\n" +
				"open -n \"%s\"\n"
			) % [
				_update_download_path,
				current_app,
				current_app, current_app, current_app, current_app, current_app,
				current_app,
				current_app,
				current_app,
			]
			var f := FileAccess.open(script_path, FileAccess.WRITE)
			if f != null:
				f.store_string(script_content)
				f.close()
				var pid := OS.create_process("/bin/sh", PackedStringArray([script_path]))
				if pid > 0:
					get_tree().quit()
					return
		var downloads_dir := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
		var open_target := _update_download_path
		if not downloads_dir.is_empty():
			var dest_path := downloads_dir.path_join(_update_download_path.get_file())
			if DirAccess.copy_absolute(_update_download_path, dest_path) == OK:
				open_target = dest_path
		update_downloading = false
		show_toast("✅ Đã tải bản cập nhật v%s! Đang mở gói cài đặt..." % latest_version)
		OS.shell_open(open_target)
		update_state_changed.emit()
		return

	if os_name == "Windows":
		if not is_editor and exe_path.to_lower().ends_with(".exe") and _update_download_path.to_lower().ends_with(".exe"):
			var win_script := ProjectSettings.globalize_path("user://updates/apply_update.bat")
			var win_dl := _update_download_path.replace("/", "\\")
			var win_exe := exe_path.replace("/", "\\")
			var bat_content := (
				"@echo off\r\n" +
				"timeout /t 2 /nobreak >nul\r\n" +
				"copy /y \"%s\" \"%s\" >nul\r\n" +
				"if %%errorlevel%%==0 (\r\n" +
				"  start \"\" \"%s\"\r\n" +
				") else (\r\n" +
				"  start \"\" \"%s\"\r\n" +
				")\r\n"
			) % [win_dl, win_exe, win_exe, win_dl]
			var wf := FileAccess.open(win_script, FileAccess.WRITE)
			if wf != null:
				wf.store_string(bat_content)
				wf.close()
				var wpid := OS.create_process("cmd.exe", PackedStringArray(["/c", win_script.replace("/", "\\")]))
				if wpid > 0:
					get_tree().quit()
					return
		update_downloading = false
		show_toast("✅ Đã tải bản cập nhật v%s! Đang mở file cài đặt..." % latest_version)
		OS.shell_open(_update_download_path)
		update_state_changed.emit()
		return

	update_downloading = false
	OS.shell_open(GITHUB_RELEASE_PAGE_URL)
	update_state_changed.emit()
