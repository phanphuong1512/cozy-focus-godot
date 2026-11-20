extends CanvasLayer

const TABS: Array = [
	{"id": "floor", "label": "🪵 Sàn & Tường"},
	{"id": "workspace", "label": "💻 Góc Học Tập"},
	{"id": "living_room", "label": "🛋️ Phòng Khách"},
	{"id": "decor", "label": "🎁 Đồ Để Bàn"},
	{"id": "kitchen", "label": "🍳 Nhà Bếp"},
	{"id": "bathroom", "label": "🛁 Phòng Tắm"},
]

const FLOOR_BRUSHES: Array = [
	{"id": "W", "label": "Sàn Gỗ Sồi", "color": "#d97706", "desc": "Ấm áp chuẩn Lo-Fi"},
	{"id": "C", "label": "Thảm Chill", "color": "#f9a8d4", "desc": "Sàn thảm khu ngồi"},
	{"id": "B", "label": "Gạch Men", "color": "#e2e8f0", "desc": "Khu bếp / tắm"},
	{"id": ".", "label": "Xóa Ô Sàn", "color": "#1e293b", "desc": "Tạo góc khuyết"},
]

const WALL_THEMES: Array = [
	{"id": "lofi_purple", "label": "Tím Lo-Fi", "color": "#4b3873"},
	{"id": "cream", "label": "Kem Ấm", "color": "#d6c7b2"},
	{"id": "sage", "label": "Xanh Sage", "color": "#6b8c7c"},
	{"id": "brick", "label": "Gạch Cổ Điển", "color": "#8f4f49"},
]

const POMODORO_MODES: Array = [
	{"id": "focus", "label": "Focus 25p"},
	{"id": "short_break", "label": "Nghỉ 5p"},
	{"id": "long_break", "label": "Nghỉ 15p"},
]

const EMOTES: Array = ["❤️", "✨", "🔥", "☕", "👏", "💤"]
const TINT_COLORS: Array = ["#f472b6", "#a78bfa", "#38bdf8", "#34d399", "#fbbf24", "#fb7185"]

const PREVIEW_TABS: Array = [
	{"id": "idle", "label": "Đứng"},
	{"id": "walking", "label": "Đi bộ"},
	{"id": "focus_desk", "label": "Gõ phím"},
	{"id": "chill_sofa", "label": "Chill"},
	{"id": "sit_floor", "label": "Ngồi bệt"},
]

const PREVIEW_FACINGS: Array = [
	{"id": "se", "label": "Trước Phải (SE)"},
	{"id": "sw", "label": "Trước Trái (SW)"},
	{"id": "nw", "label": "Sau Trái (NW)"},
	{"id": "ne", "label": "Sau Phải (NE)"},
]

const AUDIO_CHANNELS: Array = [
	{"id": "bgm", "label": "🎵 Nhạc Lo-Fi Chill"},
	{"id": "rain", "label": "🌧️ Tiếng Mưa Rơi"},
	{"id": "fire", "label": "🔥 Lửa Trại Ấm"},
	{"id": "keyboard", "label": "⌨️ Phím Cơ ASMR"},
	{"id": "wind", "label": "🌬️ Gió Đêm Dịu"},
]

var room_node: Node2D = null

var _root: Control
var _ui_theme: Theme

# Screens
var _login_root: Control
var _lobby_root: Control
var _game_hud: Control

# Login refs
var _login_error_box: PanelContainer
var _login_error_label: Label
var _login_google_btn: Button
var _login_waiting_box: PanelContainer
var _login_guest_btn: Button
var _login_guest_form: VBoxContainer
var _login_guest_input: LineEdit
var _show_guest_input: bool = false

# Lobby refs
var _lobby_user_name: Label
var _lobby_user_badge: Label
var _lobby_user_sub: Label
var _lobby_user_avatar: TextureRect
var _lobby_general_badge: Label
var _lobby_custom_room_input: LineEdit

# TopBar refs
var _topbar_panel: PanelContainer
var _mini_topbar_panel: PanelContainer
var _mini_status_dot: ColorRect
var _mini_room_label: Label
var _mini_timer_label: Label
var _mini_pin_btn: Button
var _top_status_dot: ColorRect
var _top_crown_label: Label
var _top_room_label: Label
var _top_conn_label: Label
var _top_count_label: Label
var _top_day_btn: Button
var _top_sunset_btn: Button
var _top_night_btn: Button
var _top_rain_btn: Button
var _top_decor_btn: Button
var _top_focus_btn: Button
var _top_audio_btn: Button
var _top_pin_btn: Button
var _top_full_btn: Button
var _embedded_banner_btn: Button

# FocusPanel refs
var _focus_panel: PanelContainer
var _focus_pomo_count: Label
var _focus_mode_btns: Dictionary = {}
var _focus_time_label: Label
var _focus_progress: ProgressBar
var _focus_play_btn: Button
var _focus_sync_btn: Button
var _focus_stand_btn: Button
var _todo_count_label: Label
var _todo_input: LineEdit
var _todo_list_vbox: VBoxContainer

# BuildCatalogDock refs
var _build_dock: PanelContainer
var _build_tab_btns: Dictionary = {}
var _build_count_label: Label
var _build_moving_box: PanelContainer
var _build_moving_label: Label
var _build_flip_btn: Button
var _build_guest_btn: Button
var _build_floor_area: VBoxContainer
var _build_catalog_scroll: ScrollContainer
var _build_catalog_hbox: HBoxContainer
var _build_floor_brush_btns: Dictionary = {}
var _build_wall_add_btn: Button
var _build_wall_rem_btn: Button
var _build_floor_budget_label: Label
var _build_wall_budget_label: Label
var _build_wall_theme_btns: Dictionary = {}
var _build_reset_btn: Button

# AudioMixer refs
var _audio_modal: PanelContainer
var _audio_mute_btn: Button
var _audio_sliders: Dictionary = {}
var _audio_pct_labels: Dictionary = {}

# ChatEmoteBar refs
var _chat_bar: VBoxContainer
var _chat_log_panel: PanelContainer
var _chat_log_vbox: VBoxContainer
var _chat_sit_btn: Button
var _chat_profile_avatar: TextureRect
var _chat_profile_name: Label
var _chat_input: LineEdit
var _show_chat_log: bool = false

# Zoom & Hover & Toast
var _zoom_pill: PanelContainer
var _zoom_label: Label
var _hover_hint_pill: PanelContainer
var _hover_hint_label: Label
var _toast_pill: PanelContainer
var _toast_label: Label

# Room Modal refs
var _room_modal: Control
var _room_modal_code: Label
var _room_modal_host_badge: Label
var _room_modal_count: Label
var _room_modal_guest_check: CheckButton
var _room_modal_reset_btn: Button
var _room_modal_input: LineEdit
var _room_modal_players_flow: HFlowContainer

# Profile Modal refs
var _profile_modal: Control
var _profile_title: Label
var _profile_close_btn: Button
var _profile_preview_tab_btns: Dictionary = {}
var _profile_preview_name: Label
var _profile_preview_badge: PanelContainer
var _profile_preview_tex: TextureRect
var _profile_facing_label: Label
var _profile_skin_grid: GridContainer
var _profile_skin_btns: Dictionary = {}
var _profile_custom_box: PanelContainer
var _profile_custom_tab_btns: Dictionary = {}
var _profile_custom_content: VBoxContainer
var _profile_name_input: LineEdit
var _profile_room_input: LineEdit
var _profile_color_btns: Dictionary = {}
var _profile_submit_btn: Button

var _draft_name: String = "Người chơi"
var _draft_outfit: String = "c1"
var _draft_custom_avatar: Dictionary = {}
var _draft_color: String = "#a78bfa"
var _draft_room: String = "GENERAL"
var _custom_tab: String = "hair"
var _preview_tab: String = "idle"
var _facing_idx: int = 0
var _walk_frame: int = 0
var _walk_timer: Timer
var _was_profile_modal_open: bool = false
var _was_room_modal_open: bool = false

# Update Banner refs
var _update_banner: PanelContainer
var _update_title_label: Label
var _update_notes_box: PanelContainer
var _update_notes_label: Label
var _update_progress_box: VBoxContainer
var _update_progress_label: Label
var _update_progress_bar: ProgressBar
var _update_error_label: Label
var _update_later_btn: Button
var _update_install_btn: Button
var _update_close_btn: Button


func _ready() -> void:
	layer = 10
	_init_theme()
	_build_root()
	_build_login_screen()
	_build_lobby_screen()
	_build_game_hud()
	_build_room_modal()
	_build_profile_modal()
	_build_toast_banner()
	_build_embedded_banner()
	_build_update_banner()

	_walk_timer = Timer.new()
	_walk_timer.wait_time = 0.15
	_walk_timer.autostart = true
	_walk_timer.timeout.connect(_on_walk_preview_tick)
	add_child(_walk_timer)

	GameStore.state_changed.connect(_refresh_all)
	GameStore.layout_changed.connect(_refresh_all)
	GameStore.players_changed.connect(_refresh_all)
	GameStore.chat_updated.connect(_refresh_chat_log)
	GameStore.pomodoro_updated.connect(_refresh_pomodoro)
	GameStore.toast_shown.connect(_refresh_toast)
	GameStore.screen_changed.connect(func(_s): _refresh_all())
	GameStore.auth_changed.connect(_refresh_all)
	GameStore.lobby_stats_updated.connect(func(_c): _refresh_lobby())
	GameStore.update_state_changed.connect(_refresh_update_banner)

	_refresh_all()


func bind_room(room: Node2D) -> void:
	room_node = room
	if room_node != null:
		room_node.zoom_changed.connect(_on_zoom_changed)
		room_node.hover_hint_changed.connect(_on_hover_hint_changed)


func _init_theme() -> void:
	_ui_theme = Theme.new()
	if DisplayServer.get_name() != "headless":
		var sf := SystemFont.new()
		sf.font_names = PackedStringArray([
			"Inter",
			"SF Pro Text",
			"Segoe UI",
			"Arial",
			"Helvetica Neue",
			"Apple Color Emoji",
			"Segoe UI Emoji",
		])
		sf.multichannel_signed_distance_field = false
		sf.generate_mipmaps = true
		sf.oversampling = 2.0
		sf.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
		_ui_theme.default_font = sf
	_ui_theme.default_font_size = 14


func _box(bg: Color, radius: int = 16, border: Color = Color.TRANSPARENT, border_w: int = 0, pad_x: int = 12, pad_y: int = 8) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if border_w > 0:
		sb.border_color = border
		sb.set_border_width_all(border_w)
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	return sb


func _btn(text: String, bg: Color, hover_bg: Color, radius: int = 14, border: Color = Color.TRANSPARENT, border_w: int = 0, pad_x: int = 12, pad_y: int = 6, font_size: int = 12, font_col: Color = Color.WHITE) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var eff_size := maxi(font_size + 1, 11) if font_size <= 13 else font_size
	b.add_theme_font_size_override("font_size", eff_size)
	b.add_theme_color_override("font_color", font_col)
	b.add_theme_color_override("font_hover_color", font_col)
	b.add_theme_color_override("font_pressed_color", font_col)
	b.add_theme_stylebox_override("normal", _box(bg, radius, border, border_w, pad_x, pad_y))
	b.add_theme_stylebox_override("hover", _box(hover_bg, radius, border, border_w, pad_x, pad_y))
	b.add_theme_stylebox_override("pressed", _box(hover_bg.darkened(0.1), radius, border, border_w, pad_x, pad_y))
	b.add_theme_stylebox_override("disabled", _box(bg.darkened(0.3), radius, border, border_w, pad_x, pad_y))
	return b


func _style_btn(b: Button, bg: Color, hover_bg: Color, radius: int = 12, border: Color = Color.TRANSPARENT, border_w: int = 0, pad_x: int = 10, pad_y: int = 6, font_col: Color = Color.WHITE) -> void:
	b.add_theme_color_override("font_color", font_col)
	b.add_theme_color_override("font_hover_color", font_col)
	b.add_theme_color_override("font_pressed_color", font_col)
	b.add_theme_stylebox_override("normal", _box(bg, radius, border, border_w, pad_x, pad_y))
	b.add_theme_stylebox_override("hover", _box(hover_bg, radius, border, border_w, pad_x, pad_y))
	b.add_theme_stylebox_override("pressed", _box(hover_bg.darkened(0.1), radius, border, border_w, pad_x, pad_y))


func _input_box(placeholder: String, max_len: int = 48) -> LineEdit:
	var le := LineEdit.new()
	le.placeholder_text = placeholder
	le.max_length = max_len
	le.add_theme_font_size_override("font_size", 13)
	le.add_theme_color_override("font_color", Color.WHITE)
	le.add_theme_color_override("font_placeholder_color", Color("#94a3b8"))
	le.add_theme_stylebox_override("normal", _box(Color(0, 0, 0, 0.38), 12, Color(1, 1, 1, 0.16), 1, 10, 6))
	le.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0.45), 12, Color("#f472b6"), 1, 10, 6))
	return le


func _lbl(text: String, size: int = 12, col: Color = Color.WHITE, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	var eff_size := maxi(size + 1, 11) if size <= 13 else size
	l.add_theme_font_size_override("font_size", eff_size)
	l.add_theme_color_override("font_color", col)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _build_root() -> void:
	_root = Control.new()
	_root.name = "UIRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = _ui_theme
	add_child(_root)


# ===================================================================
# 1. LOGIN SCREEN
# ===================================================================

func _build_login_screen() -> void:
	_login_root = Control.new()
	_login_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_login_root)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#100a1c")
	_login_root.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_login_root.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(430, 0)
	card.add_theme_stylebox_override("panel", _box(Color("#181126", 0.94), 24, Color("#f472b6", 0.35), 1, 28, 28))
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	# Logo
	var logo_center := CenterContainer.new()
	vbox.add_child(logo_center)
	var logo_box := PanelContainer.new()
	logo_box.custom_minimum_size = Vector2(64, 64)
	logo_box.add_theme_stylebox_override("panel", _box(Color("#1a1228"), 16, Color("#ec4899", 0.65), 2, 10, 10))
	logo_center.add_child(logo_box)
	var logo_tex := TextureRect.new()
	logo_tex.texture = GameData.get_texture("res://sprites/character/prop_bunny_heart.png")
	logo_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_box.add_child(logo_tex)

	var title := _lbl("Cozy Focus Room", 22, Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := _lbl("Không gian co-focus ấm cúng & bài trí phòng cá nhân", 12, Color("#fbcfe8", 0.85))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	# Feature highlights
	var feat_box := PanelContainer.new()
	feat_box.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.04), 16, Color(1, 1, 1, 0.08), 1, 12, 10))
	vbox.add_child(feat_box)
	var feat_v := VBoxContainer.new()
	feat_v.add_theme_constant_override("separation", 6)
	feat_box.add_child(feat_v)
	feat_v.add_child(_lbl("✨ Phòng cá nhân riêng biệt, tự do bài trí & lát sàn", 12, Color("#cbd5e1"), true))
	feat_v.add_child(_lbl("☕ Phòng chung #GENERAL học tập & làm việc cùng nhau", 12, Color("#cbd5e1"), true))
	feat_v.add_child(_lbl("🛡️ Đồng bộ tiến độ Pomodoro và danh sách công việc", 12, Color("#cbd5e1"), true))

	# Error banner
	_login_error_box = PanelContainer.new()
	_login_error_box.add_theme_stylebox_override("panel", _box(Color("#f43f5e", 0.16), 12, Color("#fb7185", 0.4), 1, 10, 8))
	_login_error_box.visible = false
	vbox.add_child(_login_error_box)
	var err_v := VBoxContainer.new()
	_login_error_box.add_child(err_v)
	_login_error_label = _lbl("", 12, Color("#fecdd3"), true)
	_login_error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	err_v.add_child(_login_error_label)
	var err_close := _btn("Đóng", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.15), 8, Color.TRANSPARENT, 0, 8, 3, 11, Color("#fda4af"))
	err_close.pressed.connect(func(): GameStore.clear_auth_error())
	err_v.add_child(err_close)

	# Google sign-in button
	_login_google_btn = _btn("🌐  Tiếp tục với Google  ↗", Color.WHITE, Color("#f1f5f9"), 20, Color.TRANSPARENT, 0, 16, 10, 13, Color("#1e293b"))
	_login_google_btn.pressed.connect(func(): GameStore.start_google_login())
	vbox.add_child(_login_google_btn)

	# Google waiting box
	_login_waiting_box = PanelContainer.new()
	_login_waiting_box.add_theme_stylebox_override("panel", _box(Color("#ec4899", 0.15), 16, Color("#f472b6", 0.4), 1, 12, 10))
	_login_waiting_box.visible = false
	vbox.add_child(_login_waiting_box)
	var wait_v := VBoxContainer.new()
	wait_v.add_theme_constant_override("separation", 6)
	_login_waiting_box.add_child(wait_v)
	var w1 := _lbl("⏳ Đang mở trình duyệt để xác thực Google...", 12, Color("#fce7f3"), true)
	w1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wait_v.add_child(w1)
	var w2 := _lbl("Sau khi chọn tài khoản Google trên trình duyệt, ứng dụng sẽ tự động đăng nhập.", 11, Color("#cbd5e1"), true)
	w2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wait_v.add_child(w2)
	var cancel_google := _btn("✕ Hủy", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 14, Color.TRANSPARENT, 0, 12, 4, 11, Color("#e2e8f0"))
	cancel_google.pressed.connect(func(): GameStore.cancel_google_login())
	wait_v.add_child(cancel_google)

	var div_lbl := _lbl("──────────  HOẶC  ──────────", 10, Color("#94a3b8"))
	div_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(div_lbl)

	# Guest button
	_login_guest_btn = _btn("👤  Chơi nhanh làm Khách (Không cần Google)", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.15), 20, Color(1, 1, 1, 0.15), 1, 16, 10, 12, Color("#e2e8f0"))
	_login_guest_btn.pressed.connect(func():
		_show_guest_input = true
		_refresh_login()
		_login_guest_input.grab_focus()
	)
	vbox.add_child(_login_guest_btn)

	# Guest input form
	_login_guest_form = VBoxContainer.new()
	_login_guest_form.add_theme_constant_override("separation", 8)
	_login_guest_form.visible = false
	vbox.add_child(_login_guest_form)

	_login_guest_input = _input_box("Nhập tên của bạn...", 20)
	_login_guest_input.text = "Khách Chill"
	_login_guest_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_login_guest_input.text_submitted.connect(func(txt: String): GameStore.login_as_guest(txt))
	_login_guest_form.add_child(_login_guest_input)

	var guest_btns := HBoxContainer.new()
	guest_btns.add_theme_constant_override("separation", 8)
	_login_guest_form.add_child(guest_btns)
	var go_btn := _btn("🚪 Vào Sảnh", Color("#db2777"), Color("#ec4899"), 18, Color.TRANSPARENT, 0, 14, 9, 12, Color.WHITE)
	go_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go_btn.pressed.connect(func(): GameStore.login_as_guest(_login_guest_input.text))
	guest_btns.add_child(go_btn)
	var cancel_g := _btn("Hủy", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.18), 18, Color.TRANSPARENT, 0, 14, 9, 12, Color("#cbd5e1"))
	cancel_g.pressed.connect(func():
		_show_guest_input = false
		_refresh_login()
	)
	guest_btns.add_child(cancel_g)

	var footer := _lbl("Cozy Focus Room v%s • Lo-Fi Pomodoro Desktop Companion (Godot 4.7)" % GameStore.app_version, 10, Color("#94a3b8"))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(footer)


# ===================================================================
# 2. LOBBY SCREEN
# ===================================================================

func _build_lobby_screen() -> void:
	_lobby_root = Control.new()
	_lobby_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_lobby_root)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#110a1c")
	_lobby_root.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lobby_root.add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	scroll.add_child(margin)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(center)

	var main_v := VBoxContainer.new()
	main_v.custom_minimum_size = Vector2(780, 0)
	main_v.add_theme_constant_override("separation", 20)
	center.add_child(main_v)

	# Header user bar
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", _box(Color("#1a1228", 0.85), 18, Color(1, 1, 1, 0.1), 1, 18, 12))
	main_v.add_child(header)

	var h_row := HBoxContainer.new()
	h_row.add_theme_constant_override("separation", 12)
	header.add_child(h_row)

	_lobby_user_avatar = TextureRect.new()
	_lobby_user_avatar.custom_minimum_size = Vector2(40, 40)
	_lobby_user_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lobby_user_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lobby_user_avatar.texture = GameData.get_texture("res://sprites/characters/c1/avatar.png")
	h_row.add_child(_lobby_user_avatar)

	var u_info := VBoxContainer.new()
	u_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h_row.add_child(u_info)
	var u_top := HBoxContainer.new()
	u_top.add_theme_constant_override("separation", 8)
	u_info.add_child(u_top)
	_lobby_user_name = _lbl("Người chơi", 14, Color.WHITE)
	u_top.add_child(_lobby_user_name)
	_lobby_user_badge = _lbl("Khách", 10, Color("#cbd5e1"))
	u_top.add_child(_lobby_user_badge)
	_lobby_user_sub = _lbl("", 11, Color("#94a3b8"))
	u_info.add_child(_lobby_user_sub)

	var outfit_btn := _btn("🎨 Đổi trang phục", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 16, Color(1, 1, 1, 0.12), 1, 14, 7, 12, Color("#e2e8f0"))
	outfit_btn.pressed.connect(func(): GameStore.set_show_profile_modal(true))
	h_row.add_child(outfit_btn)

	var logout_btn := _btn("🚪 Đăng xuất", Color("#f43f5e", 0.16), Color("#f43f5e", 0.28), 16, Color("#fb7185", 0.3), 1, 14, 7, 12, Color("#fecdd3"))
	logout_btn.pressed.connect(func(): GameStore.logout())
	h_row.add_child(logout_btn)

	# Title section
	var title_v := VBoxContainer.new()
	title_v.add_theme_constant_override("separation", 6)
	main_v.add_child(title_v)
	var badge_lbl := _lbl("✨ Sảnh Chờ Cozy Focus Room", 12, Color("#fbcfe8"))
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_v.add_child(badge_lbl)
	var h1 := _lbl("Chọn không gian học tập & thư giãn", 24, Color.WHITE)
	h1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_v.add_child(h1)
	var h_sub := _lbl("Bạn có thể tham gia vào phòng chung cùng mọi người hoặc mở không gian riêng của mình", 13, Color("#94a3b8"))
	h_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_v.add_child(h_sub)

	# Two main cards
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 18)
	main_v.add_child(cards)

	# Card 1: #GENERAL
	var card_gen := PanelContainer.new()
	card_gen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_gen.add_theme_stylebox_override("panel", _box(Color("#1d1330"), 22, Color("#f472b6", 0.35), 1, 22, 22))
	cards.add_child(card_gen)
	var cv1 := VBoxContainer.new()
	cv1.add_theme_constant_override("separation", 12)
	card_gen.add_child(cv1)
	var c1_top := HBoxContainer.new()
	cv1.add_child(c1_top)
	c1_top.add_child(_lbl("👥 Phòng Chung Lo-Fi  #GENERAL", 16, Color.WHITE))
	var spacer1 := Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c1_top.add_child(spacer1)
	_lobby_general_badge = _lbl("🟢 Trực tuyến", 11, Color("#6ee7b7"))
	c1_top.add_child(_lobby_general_badge)
	cv1.add_child(_lbl("Không gian co-focus công cộng học tập và làm việc cùng mọi người. Hỗ trợ Pomodoro đồng bộ toàn phòng và trò chuyện chill.", 12, Color("#cbd5e1"), true))
	var btn_gen := _btn("🚪 Vào Phòng Chung #GENERAL  →", Color("#db2777"), Color("#ec4899"), 16, Color.TRANSPARENT, 0, 16, 11, 13, Color.WHITE)
	btn_gen.pressed.connect(func():
		GameStore.set_screen("game")
		GameStore.join_room("GENERAL")
	)
	cv1.add_child(btn_gen)

	# Card 2: Personal room
	var card_pers := PanelContainer.new()
	card_pers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_pers.add_theme_stylebox_override("panel", _box(Color("#1e1433"), 22, Color("#a78bfa", 0.35), 1, 22, 22))
	cards.add_child(card_pers)
	var cv2 := VBoxContainer.new()
	cv2.add_theme_constant_override("separation", 12)
	card_pers.add_child(cv2)
	var c2_top := HBoxContainer.new()
	cv2.add_child(c2_top)
	c2_top.add_child(_lbl("🏠 Phòng Cá Nhân Của Tôi", 16, Color.WHITE))
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c2_top.add_child(spacer2)
	c2_top.add_child(_lbl("Riêng tư • 14x14", 11, Color("#ddd6fe")))
	cv2.add_child(_lbl("Căn phòng 14x14 rộng rãi thuộc sở hữu của riêng bạn. Tự do lát các loại gạch gỗ, đổi màu tường và bài trí tối đa 30 món nội thất theo phong cách riêng.", 12, Color("#cbd5e1"), true))
	var btn_pers := _btn("✨ Vào Phòng Cá Nhân Của Tôi  →", Color("#7c3aed"), Color("#8b5cf6"), 16, Color.TRANSPARENT, 0, 16, 11, 13, Color.WHITE)
	btn_pers.pressed.connect(func():
		var uid := str(GameStore.user.get("uid", "MYROOM"))
		var regex := RegEx.new()
		regex.compile("[^a-zA-Z0-9]")
		var clean_uid := regex.sub(uid, "", true)
		if clean_uid.length() > 8:
			clean_uid = clean_uid.substr(clean_uid.length() - 8)
		clean_uid = clean_uid.to_upper()
		if clean_uid.is_empty():
			clean_uid = "MYROOM"
		GameStore.set_screen("game")
		GameStore.join_room("ROOM_%s" % clean_uid, true)
	)
	cv2.add_child(btn_pers)

	# Custom Room Join Bar
	var join_bar := PanelContainer.new()
	join_bar.add_theme_stylebox_override("panel", _box(Color("#181126", 0.78), 16, Color(1, 1, 1, 0.1), 1, 16, 12))
	main_v.add_child(join_bar)
	var j_row := HBoxContainer.new()
	j_row.add_theme_constant_override("separation", 10)
	join_bar.add_child(j_row)
	var j_lbl := _lbl("#  Tham gia phòng bạn bè theo mã:", 12, Color("#cbd5e1"))
	j_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	j_row.add_child(j_lbl)
	_lobby_custom_room_input = _input_box("Ví dụ: STUDY123...", 24)
	_lobby_custom_room_input.custom_minimum_size = Vector2(210, 0)
	_lobby_custom_room_input.text_submitted.connect(func(txt: String): _join_custom_lobby_room(txt))
	j_row.add_child(_lobby_custom_room_input)
	var j_btn := _btn("Tham gia", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 12, Color(1, 1, 1, 0.2), 1, 16, 8, 12, Color.WHITE)
	j_btn.pressed.connect(func(): _join_custom_lobby_room(_lobby_custom_room_input.text))
	j_row.add_child(j_btn)

	var foot := _lbl("Cozy Focus Room • Phiên bản v%s • Không gian học tập Lo-Fi nhẹ nhàng" % GameStore.app_version, 11, Color("#94a3b8"))
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_v.add_child(foot)


func _join_custom_lobby_room(raw: String) -> void:
	var clean := raw.strip_edges().to_upper().substr(0, 24)
	if clean.is_empty():
		return
	GameStore.set_screen("game")
	GameStore.join_room(clean)


# ===================================================================
# 3. GAME HUD
# ===================================================================

func _build_game_hud() -> void:
	_game_hud = Control.new()
	_game_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_game_hud)

	_build_topbar()
	_build_mini_topbar()
	_build_focus_panel()
	_build_catalog_dock()
	_build_audio_mixer()
	_build_chat_emote_bar()
	_build_zoom_pill()
	_build_hover_hint()


func _build_topbar() -> void:
	var top_center := HBoxContainer.new()
	top_center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_center.offset_top = 12
	top_center.alignment = BoxContainer.ALIGNMENT_CENTER
	top_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(top_center)

	_topbar_panel = PanelContainer.new()
	_topbar_panel.add_theme_stylebox_override("panel", _box(Color("#181026", 0.90), 22, Color("#f9a8d4", 0.3), 1, 14, 6))
	top_center.add_child(_topbar_panel)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	_topbar_panel.add_child(h)

	var lobby_btn := _btn("🏠 Sảnh", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 14, Color.TRANSPARENT, 0, 10, 4, 12, Color("#e2e8f0"))
	lobby_btn.tooltip_text = "Rời phòng về Sảnh Chờ (Lobby)"
	lobby_btn.pressed.connect(func(): GameStore.leave_room_to_lobby())
	h.add_child(lobby_btn)

	# Room status button
	var room_btn := _btn("", Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 10, 4, 12, Color.WHITE)
	room_btn.tooltip_text = "Đổi phòng / Mời bạn bè"
	room_btn.pressed.connect(func(): GameStore.set_show_room_modal(true))
	var rb_h := HBoxContainer.new()
	rb_h.add_theme_constant_override("separation", 6)
	rb_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room_btn.add_child(rb_h)
	_top_status_dot = ColorRect.new()
	_top_status_dot.custom_minimum_size = Vector2(8, 8)
	_top_status_dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_status_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rb_h.add_child(_top_status_dot)
	_top_crown_label = _lbl("👑", 11, Color("#fcd34d"))
	rb_h.add_child(_top_crown_label)
	_top_room_label = _lbl("GENERAL", 12, Color("#fce7f3"))
	rb_h.add_child(_top_room_label)
	_top_conn_label = _lbl("Đang kết nối...", 10, Color("#fcd34d"))
	rb_h.add_child(_top_conn_label)
	_top_count_label = _lbl("👥 1", 11, Color("#cbd5e1"))
	rb_h.add_child(_top_count_label)
	room_btn.custom_minimum_size = Vector2(150, 28)
	h.add_child(room_btn)

	var copy_btn := _btn("📋", Color(1, 1, 1, 0.04), Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 8, 4, 12, Color("#fbcfe8"))
	copy_btn.tooltip_text = "Copy mã phòng để mời bạn"
	copy_btn.pressed.connect(func():
		DisplayServer.clipboard_set(GameStore.room_code)
		GameStore.show_toast("📋 Đã copy mã phòng \"%s\"! Gửi cho bạn bè cùng vào nhé 💕" % GameStore.room_code)
	)
	h.add_child(copy_btn)

	# Atmosphere group
	_top_day_btn = _btn("☀️", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, 12)
	_top_day_btn.tooltip_text = "Ban Ngày"
	_top_day_btn.pressed.connect(func(): GameStore.set_lighting_mode("day"))
	h.add_child(_top_day_btn)

	_top_sunset_btn = _btn("🌅", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, 12)
	_top_sunset_btn.tooltip_text = "Hoàng Hôn Ấm"
	_top_sunset_btn.pressed.connect(func(): GameStore.set_lighting_mode("sunset"))
	h.add_child(_top_sunset_btn)

	_top_night_btn = _btn("🌙", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, 12)
	_top_night_btn.tooltip_text = "Đêm Lo-Fi (Đèn bàn phát sáng)"
	_top_night_btn.pressed.connect(func(): GameStore.set_lighting_mode("night"))
	h.add_child(_top_night_btn)

	_top_rain_btn = _btn("🌧️", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, 12)
	_top_rain_btn.tooltip_text = "Bật/Tắt Mưa rơi"
	_top_rain_btn.pressed.connect(func(): GameStore.toggle_rain())
	h.add_child(_top_rain_btn)

	_top_decor_btn = _btn("🖌️ Decor (B)", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.18), 14, Color.TRANSPARENT, 0, 10, 4, 12, Color("#fce7f3"))
	_top_decor_btn.pressed.connect(func(): GameStore.toggle_build_mode())
	h.add_child(_top_decor_btn)

	_top_focus_btn = _btn("📝 25:00", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 14, Color.TRANSPARENT, 0, 10, 4, 12)
	_top_focus_btn.tooltip_text = "Pomodoro & To-Do List"
	_top_focus_btn.pressed.connect(func(): GameStore.set_show_focus_panel(not GameStore.show_focus_panel))
	h.add_child(_top_focus_btn)

	_top_audio_btn = _btn("🎧", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 14, Color.TRANSPARENT, 0, 8, 4, 12)
	_top_audio_btn.tooltip_text = "Bộ trộn nhạc Lo-Fi & Tiếng Mưa"
	_top_audio_btn.pressed.connect(func(): GameStore.set_show_audio_mixer(not GameStore.show_audio_mixer))
	h.add_child(_top_audio_btn)

	_top_pin_btn = _btn("📌", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 8, 4, 12)
	_top_pin_btn.tooltip_text = "Ghim nổi trên màn hình"
	_top_pin_btn.pressed.connect(func(): GameStore.toggle_always_on_top())
	h.add_child(_top_pin_btn)

	var mini_btn := _btn("🗕", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 8, 4, 12)
	mini_btn.tooltip_text = "Thu gọn chế độ Mini Widget"
	mini_btn.pressed.connect(func(): GameStore.toggle_mini_mode())
	h.add_child(mini_btn)

	_top_full_btn = _btn("⛶", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 8, 4, 12, Color("#fce7f3"))
	_top_full_btn.tooltip_text = "Toàn màn hình / Cửa sổ Retina lớn (F11)"
	_top_full_btn.pressed.connect(func(): GameStore.toggle_fullscreen())
	h.add_child(_top_full_btn)


func _build_mini_topbar() -> void:
	_mini_topbar_panel = PanelContainer.new()
	_mini_topbar_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_mini_topbar_panel.offset_left = 8
	_mini_topbar_panel.offset_right = -8
	_mini_topbar_panel.offset_top = 8
	_mini_topbar_panel.add_theme_stylebox_override("panel", _box(Color("#181026", 0.92), 14, Color("#f9a8d4", 0.3), 1, 12, 6))
	_mini_topbar_panel.visible = false
	_game_hud.add_child(_mini_topbar_panel)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	_mini_topbar_panel.add_child(h)

	_mini_status_dot = ColorRect.new()
	_mini_status_dot.custom_minimum_size = Vector2(8, 8)
	_mini_status_dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(_mini_status_dot)

	_mini_room_label = _lbl("#GENERAL", 12, Color("#fbcfe8"))
	h.add_child(_mini_room_label)

	_mini_timer_label = _lbl("25:00", 12, Color("#fde68a"))
	h.add_child(_mini_timer_label)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(sp)

	var audio_b := _btn("🎧", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 6, 4, 12)
	audio_b.pressed.connect(func(): GameStore.set_show_audio_mixer(not GameStore.show_audio_mixer))
	h.add_child(audio_b)

	_mini_pin_btn = _btn("📌", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 6, 4, 12)
	_mini_pin_btn.pressed.connect(func(): GameStore.toggle_always_on_top())
	h.add_child(_mini_pin_btn)

	var max_b := _btn("⛶", Color("#ec4899", 0.25), Color("#ec4899", 0.4), 8, Color.TRANSPARENT, 0, 8, 4, 12)
	max_b.tooltip_text = "Phóng to lại cửa sổ"
	max_b.pressed.connect(func(): GameStore.toggle_mini_mode())
	h.add_child(max_b)


func _build_focus_panel() -> void:
	_focus_panel = PanelContainer.new()
	_focus_panel.anchor_left = 1.0
	_focus_panel.anchor_right = 1.0
	_focus_panel.anchor_top = 0.0
	_focus_panel.anchor_bottom = 0.0
	_focus_panel.offset_left = -250
	_focus_panel.offset_right = -16
	_focus_panel.offset_top = 64
	_focus_panel.custom_minimum_size = Vector2(234, 0)
	_focus_panel.add_theme_stylebox_override("panel", _box(Color("#181026", 0.88), 22, Color("#f9a8d4", 0.25), 1, 16, 14))
	_game_hud.add_child(_focus_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_focus_panel.add_child(v)

	# Header
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	v.add_child(hdr)
	hdr.add_child(_lbl("🔥 Co-Focus Timer", 14, Color("#fbcfe8")))
	_focus_pomo_count = _lbl("🍅 x0", 10, Color("#fecdd3"))
	hdr.add_child(_focus_pomo_count)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sp)
	var close_b := _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 10, Color.TRANSPARENT, 0, 6, 2, 12, Color("#94a3b8"))
	close_b.pressed.connect(func(): GameStore.set_show_focus_panel(false))
	hdr.add_child(close_b)

	# Mode Switcher
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 4)
	v.add_child(mode_row)
	for m in POMODORO_MODES:
		var mid := str(m["id"])
		var mb := _btn(str(m["label"]), Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.14), 8, Color.TRANSPARENT, 0, 6, 4, 11)
		mb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mb.pressed.connect(func(): GameStore.switch_pomodoro_mode(mid))
		mode_row.add_child(mb)
		_focus_mode_btns[mid] = mb

	# Clock card
	var clock_card := PanelContainer.new()
	clock_card.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0.26), 16, Color(1, 1, 1, 0.1), 1, 12, 12))
	v.add_child(clock_card)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 8)
	clock_card.add_child(cv)

	_focus_time_label = _lbl("25:00", 34, Color.WHITE)
	_focus_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cv.add_child(_focus_time_label)

	_focus_progress = ProgressBar.new()
	_focus_progress.custom_minimum_size = Vector2(0, 6)
	_focus_progress.show_percentage = false
	_focus_progress.add_theme_stylebox_override("background", _box(Color(1, 1, 1, 0.1), 4))
	_focus_progress.add_theme_stylebox_override("fill", _box(Color("#ec4899"), 4))
	cv.add_child(_focus_progress)

	var clk_btns := HBoxContainer.new()
	clk_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	clk_btns.add_theme_constant_override("separation", 8)
	cv.add_child(clk_btns)

	_focus_play_btn = _btn("▶ Bắt đầu", Color("#ec4899"), Color("#f472b6"), 10, Color.TRANSPARENT, 0, 14, 6, 12, Color.WHITE)
	_focus_play_btn.pressed.connect(func():
		if bool(GameStore.pomodoro.get("isRunning", false)):
			GameStore.pause_pomodoro()
		else:
			GameStore.start_pomodoro()
	)
	clk_btns.add_child(_focus_play_btn)

	var rst_btn := _btn("↺", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.15), 10, Color.TRANSPARENT, 0, 10, 6, 13, Color("#e2e8f0"))
	rst_btn.tooltip_text = "Đặt lại đồng hồ"
	rst_btn.pressed.connect(func(): GameStore.reset_pomodoro())
	clk_btns.add_child(rst_btn)

	_focus_sync_btn = _btn("🔗 Đang đồng bộ giờ học cả phòng", Color("#10b981", 0.2), Color("#10b981", 0.3), 12, Color("#34d399", 0.3), 1, 10, 4, 10, Color("#a7f3d0"))
	_focus_sync_btn.pressed.connect(func(): GameStore.toggle_pomodoro_room_sync())
	cv.add_child(_focus_sync_btn)

	# Stand up button
	_focus_stand_btn = _btn("🚶 Đứng dậy (hoặc bấm WASD)", Color("#ec4899", 0.22), Color("#ec4899", 0.35), 10, Color("#f472b6", 0.35), 1, 10, 6, 12, Color("#fce7f3"))
	_focus_stand_btn.pressed.connect(func(): GameStore.stand_up())
	_focus_stand_btn.visible = false
	v.add_child(_focus_stand_btn)

	# Todo section
	var todo_hdr := HBoxContainer.new()
	v.add_child(todo_hdr)
	todo_hdr.add_child(_lbl("📝 Danh Sách Công Việc", 12, Color("#fce7f3")))
	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	todo_hdr.add_child(sp2)
	_todo_count_label = _lbl("0/0 xong", 10, Color("#94a3b8"))
	todo_hdr.add_child(_todo_count_label)

	var add_row := HBoxContainer.new()
	add_row.add_theme_constant_override("separation", 6)
	v.add_child(add_row)
	_todo_input = _input_box("Thêm việc cần focus...", 80)
	_todo_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_todo_input.text_submitted.connect(func(txt: String):
		if not txt.strip_edges().is_empty():
			GameStore.add_todo(txt)
			_todo_input.text = ""
	)
	add_row.add_child(_todo_input)
	var add_b := _btn("+", Color("#ec4899"), Color("#f472b6"), 10, Color.TRANSPARENT, 0, 12, 6, 14)
	add_b.pressed.connect(func():
		if not _todo_input.text.strip_edges().is_empty():
			GameStore.add_todo(_todo_input.text)
			_todo_input.text = ""
	)
	add_row.add_child(add_b)

	var todo_scroll := ScrollContainer.new()
	todo_scroll.custom_minimum_size = Vector2(0, 85)
	v.add_child(todo_scroll)
	_todo_list_vbox = VBoxContainer.new()
	_todo_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_todo_list_vbox.add_theme_constant_override("separation", 6)
	todo_scroll.add_child(_todo_list_vbox)


func _build_catalog_dock() -> void:
	var bottom_center := HBoxContainer.new()
	bottom_center.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_center.offset_bottom = -12
	bottom_center.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_center.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(bottom_center)

	_build_dock = PanelContainer.new()
	_build_dock.custom_minimum_size = Vector2(820, 0)
	_build_dock.add_theme_stylebox_override("panel", _box(Color("#160f24", 0.94), 22, Color("#f9a8d4", 0.35), 1, 12, 10))
	_build_dock.visible = false
	bottom_center.add_child(_build_dock)

	var main_v := VBoxContainer.new()
	main_v.add_theme_constant_override("separation", 10)
	_build_dock.add_child(main_v)

	# Top action row
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 4)
	main_v.add_child(top_row)

	for t in TABS:
		var tid := str(t["id"])
		var tb := _btn(str(t["label"]), Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.14), 10, Color.TRANSPARENT, 0, 8, 6, 11)
		tb.pressed.connect(func(): GameStore.set_build_tab(tid))
		top_row.add_child(tb)
		_build_tab_btns[tid] = tb

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(sp)

	_build_count_label = _lbl("Đồ vật: 0", 11, Color("#e2e8f0"))
	top_row.add_child(_build_count_label)

	_build_moving_box = PanelContainer.new()
	_build_moving_box.add_theme_stylebox_override("panel", _box(Color("#0ea5e9", 0.2), 10, Color("#38bdf8", 0.4), 1, 8, 4))
	_build_moving_box.visible = false
	top_row.add_child(_build_moving_box)
	var mov_h := HBoxContainer.new()
	mov_h.add_theme_constant_override("separation", 6)
	_build_moving_box.add_child(mov_h)
	_build_moving_label = _lbl("Đang di chuyển", 11, Color("#e0f2fe"))
	mov_h.add_child(_build_moving_label)
	var del_b := _btn("🗑️ Xóa", Color("#f43f5e", 0.8), Color("#f43f5e"), 8, Color.TRANSPARENT, 0, 8, 2, 11)
	del_b.pressed.connect(func(): GameStore.remove_item(GameStore.moving_item_uid))
	mov_h.add_child(del_b)
	var cancel_m := _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.15), 8, Color.TRANSPARENT, 0, 6, 2, 11)
	cancel_m.pressed.connect(func(): GameStore.start_moving_item(""))
	mov_h.add_child(cancel_m)

	_build_flip_btn = _btn("🔄 Xoay (R)", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.15), 10, Color.TRANSPARENT, 0, 10, 6, 11)
	_build_flip_btn.pressed.connect(func(): GameStore.toggle_place_flipped())
	top_row.add_child(_build_flip_btn)

	_build_guest_btn = _btn("👥 Khách: Chỉ xem", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.15), 10, Color.TRANSPARENT, 0, 10, 6, 11)
	_build_guest_btn.pressed.connect(func(): GameStore.set_allow_guest_build(not bool(GameStore.layout.get("allowGuestBuild", false))))
	top_row.add_child(_build_guest_btn)

	var done_b := _btn("Xong", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 10, Color.TRANSPARENT, 0, 12, 6, 11, Color("#fbcfe8"))
	done_b.pressed.connect(func(): GameStore.toggle_build_mode(0))
	top_row.add_child(done_b)

	# Floor & Wall tab area
	_build_floor_area = VBoxContainer.new()
	_build_floor_area.add_theme_constant_override("separation", 8)
	main_v.add_child(_build_floor_area)

	var fl_row1 := HBoxContainer.new()
	fl_row1.add_theme_constant_override("separation", 6)
	_build_floor_area.add_child(fl_row1)

	for b in FLOOR_BRUSHES:
		var bid := str(b["id"])
		var btn := _btn("%s\n%s" % [str(b["label"]), str(b["desc"])], Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.1), 12, Color(1, 1, 1, 0.1), 1, 10, 6, 10, Color("#e2e8f0"))
		btn.pressed.connect(func(): GameStore.set_active_floor_brush(bid))
		fl_row1.add_child(btn)
		_build_floor_brush_btns[bid] = btn

	_build_wall_add_btn = _btn("🧱 Dựng Tường\nR xoay Trái/Phải", Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.1), 12, Color(1, 1, 1, 0.1), 1, 10, 6, 10)
	_build_wall_add_btn.pressed.connect(func():
		GameStore.set_active_wall_brush("" if GameStore.active_wall_brush == "add" else "add")
	)
	fl_row1.add_child(_build_wall_add_btn)

	_build_wall_rem_btn = _btn("🚫 Xóa Tường\nGỡ vách tường", Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.1), 12, Color(1, 1, 1, 0.1), 1, 10, 6, 10)
	_build_wall_rem_btn.pressed.connect(func():
		GameStore.set_active_wall_brush("" if GameStore.active_wall_brush == "remove" else "remove")
	)
	fl_row1.add_child(_build_wall_rem_btn)

	var auto_wall_btn := _btn("Auto Bo Tường", Color("#6366f1", 0.2), Color("#6366f1", 0.35), 10, Color("#818cf8", 0.3), 1, 10, 8, 11, Color("#c7d2fe"))
	auto_wall_btn.pressed.connect(func(): GameStore.auto_build_walls())
	fl_row1.add_child(auto_wall_btn)

	var sp_fl := Control.new()
	sp_fl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fl_row1.add_child(sp_fl)

	_build_floor_budget_label = _lbl("", 11, Color("#fde68a"))
	fl_row1.add_child(_build_floor_budget_label)
	_build_wall_budget_label = _lbl("", 11, Color("#ddd6fe"))
	fl_row1.add_child(_build_wall_budget_label)

	var fl_row2 := HBoxContainer.new()
	fl_row2.add_theme_constant_override("separation", 8)
	_build_floor_area.add_child(fl_row2)

	for wt in WALL_THEMES:
		var wid := str(wt["id"])
		var wb := _btn("🎨 " + str(wt["label"]), Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.14), 8, Color.TRANSPARENT, 0, 10, 5, 11)
		wb.pressed.connect(func(): GameStore.set_wall_theme(wid))
		fl_row2.add_child(wb)
		_build_wall_theme_btns[wid] = wb

	var sp_fl2 := Control.new()
	sp_fl2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fl_row2.add_child(sp_fl2)

	var exp_b := _btn("⤢ + Rộng", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 10, Color.TRANSPARENT, 0, 10, 5, 11)
	exp_b.pressed.connect(func(): GameStore.expand_floor_grid())
	fl_row2.add_child(exp_b)

	var shr_b := _btn("⤡ - Gọn", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 10, Color.TRANSPARENT, 0, 10, 5, 11)
	shr_b.pressed.connect(func(): GameStore.shrink_floor_grid())
	fl_row2.add_child(shr_b)

	_build_reset_btn = _btn("↺ Phòng Mẫu", Color("#f43f5e", 0.2), Color("#f43f5e", 0.35), 10, Color("#fb7185", 0.3), 1, 10, 5, 11, Color("#fecdd3"))
	_build_reset_btn.pressed.connect(func(): GameStore.reset_default_room())
	fl_row2.add_child(_build_reset_btn)

	# Furniture catalog scroll
	_build_catalog_scroll = ScrollContainer.new()
	_build_catalog_scroll.custom_minimum_size = Vector2(0, 128)
	_build_catalog_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_v.add_child(_build_catalog_scroll)
	_build_catalog_hbox = HBoxContainer.new()
	_build_catalog_hbox.add_theme_constant_override("separation", 10)
	_build_catalog_scroll.add_child(_build_catalog_hbox)

	main_v.add_child(_lbl("💡 Mẹo: Chọn đồ mục 🎁 Đồ Để Bàn rồi rê lên mặt Bàn/Quầy để đặt lên! Click đồ có sẵn để di chuyển hoặc xóa.", 10, Color("#94a3b8")))


func _build_audio_mixer() -> void:
	_audio_modal = PanelContainer.new()
	_audio_modal.position = Vector2(16, 64)
	_audio_modal.custom_minimum_size = Vector2(300, 0)
	_audio_modal.add_theme_stylebox_override("panel", _box(Color("#181026", 0.94), 22, Color("#f9a8d4", 0.3), 1, 16, 14))
	_audio_modal.visible = false
	_game_hud.add_child(_audio_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_audio_modal.add_child(v)

	var hdr := HBoxContainer.new()
	v.add_child(hdr)
	hdr.add_child(_lbl("🎧 Lo-Fi & Ambient Mixer", 14, Color("#fbcfe8")))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sp)
	_audio_mute_btn = _btn("🔊", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 12, Color.TRANSPARENT, 0, 8, 4, 13)
	_audio_mute_btn.pressed.connect(func(): GameStore.toggle_master_mute())
	hdr.add_child(_audio_mute_btn)
	var close_b := _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 12, Color.TRANSPARENT, 0, 8, 4, 13, Color("#94a3b8"))
	close_b.pressed.connect(func(): GameStore.set_show_audio_mixer(false))
	hdr.add_child(close_b)

	for ch in AUDIO_CHANNELS:
		var cid := str(ch["id"])
		var ch_v := VBoxContainer.new()
		ch_v.add_theme_constant_override("separation", 3)
		v.add_child(ch_v)
		var r := HBoxContainer.new()
		ch_v.add_child(r)
		r.add_child(_lbl(str(ch["label"]), 12, Color("#e2e8f0")))
		var sp2 := Control.new()
		sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(sp2)
		var pct := _lbl("0%", 11, Color("#94a3b8"))
		r.add_child(pct)
		_audio_pct_labels[cid] = pct

		var sl := HSlider.new()
		sl.min_value = 0.0
		sl.max_value = 1.0
		sl.step = 0.02
		sl.focus_mode = Control.FOCUS_NONE
		sl.value_changed.connect(func(val: float): GameStore.set_channel_volume(cid, val))
		ch_v.add_child(sl)
		_audio_sliders[cid] = sl

	v.add_child(_lbl("Trộn tiếng mưa rơi, lửa trại và tiếng phím cơ cùng nhạc Lo-Fi để tạo không gian tập trung ✨", 10, Color("#94a3b8"), true))


func _build_chat_emote_bar() -> void:
	_chat_bar = VBoxContainer.new()
	_chat_bar.anchor_left = 1.0
	_chat_bar.anchor_right = 1.0
	_chat_bar.anchor_top = 1.0
	_chat_bar.anchor_bottom = 1.0
	_chat_bar.offset_left = -320
	_chat_bar.offset_right = -16
	_chat_bar.offset_top = -120
	_chat_bar.offset_bottom = -16
	_chat_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_chat_bar.alignment = BoxContainer.ALIGNMENT_END
	_chat_bar.add_theme_constant_override("separation", 8)
	_chat_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(_chat_bar)

	# Chat Log Popover
	_chat_log_panel = PanelContainer.new()
	_chat_log_panel.custom_minimum_size = Vector2(320, 180)
	_chat_log_panel.add_theme_stylebox_override("panel", _box(Color("#181026", 0.92), 16, Color("#f9a8d4", 0.3), 1, 12, 10))
	_chat_log_panel.visible = false
	_chat_bar.add_child(_chat_log_panel)
	var cl_v := VBoxContainer.new()
	cl_v.add_theme_constant_override("separation", 6)
	_chat_log_panel.add_child(cl_v)
	var cl_hdr := HBoxContainer.new()
	cl_v.add_child(cl_hdr)
	cl_hdr.add_child(_lbl("💬 Nhật Ký Trò Chuyện", 12, Color("#fbcfe8")))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cl_hdr.add_child(sp)
	var cl_close := _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 8, Color.TRANSPARENT, 0, 6, 2, 11, Color("#94a3b8"))
	cl_close.pressed.connect(func():
		_show_chat_log = false
		_chat_log_panel.visible = false
	)
	cl_hdr.add_child(cl_close)
	var cl_scroll := ScrollContainer.new()
	cl_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cl_v.add_child(cl_scroll)
	_chat_log_vbox = VBoxContainer.new()
	_chat_log_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_log_vbox.add_theme_constant_override("separation", 4)
	cl_scroll.add_child(_chat_log_vbox)

	# Row 1: Sit floor + Emotes + Profile
	var row1 := HBoxContainer.new()
	row1.alignment = BoxContainer.ALIGNMENT_END
	row1.add_theme_constant_override("separation", 6)
	_chat_bar.add_child(row1)

	_chat_sit_btn = _btn("🧘 Ngồi bệt (G)", Color("#181026", 0.85), Color(1, 1, 1, 0.15), 16, Color("#f9a8d4", 0.25), 1, 10, 5, 11)
	_chat_sit_btn.pressed.connect(func(): GameStore.sit_on_floor())
	row1.add_child(_chat_sit_btn)

	var emo_panel := PanelContainer.new()
	emo_panel.add_theme_stylebox_override("panel", _box(Color("#181026", 0.85), 16, Color("#f9a8d4", 0.25), 1, 6, 3))
	row1.add_child(emo_panel)
	var emo_h := HBoxContainer.new()
	emo_h.add_theme_constant_override("separation", 2)
	emo_panel.add_child(emo_h)
	for emo in EMOTES:
		var e_str := str(emo)
		var eb := _btn(e_str, Color.TRANSPARENT, Color(1, 1, 1, 0.15), 12, Color.TRANSPARENT, 0, 5, 2, 13)
		eb.pressed.connect(func(): GameStore.send_emote(e_str))
		emo_h.add_child(eb)

	var prof_btn := _btn("", Color("#181026", 0.88), Color(1, 1, 1, 0.15), 16, Color("#f9a8d4", 0.3), 1, 10, 4, 11)
	prof_btn.custom_minimum_size = Vector2(110, 28)
	prof_btn.pressed.connect(func(): GameStore.set_show_profile_modal(true))
	var pb_h := HBoxContainer.new()
	pb_h.add_theme_constant_override("separation", 6)
	pb_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prof_btn.add_child(pb_h)
	_chat_profile_avatar = TextureRect.new()
	_chat_profile_avatar.custom_minimum_size = Vector2(20, 20)
	_chat_profile_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chat_profile_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chat_profile_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pb_h.add_child(_chat_profile_avatar)
	_chat_profile_name = _lbl("Người chơi", 11, Color("#fce7f3"))
	pb_h.add_child(_chat_profile_name)
	pb_h.add_child(_lbl("⚙️", 11, Color("#f9a8d4")))
	row1.add_child(prof_btn)

	# Row 2: Chat Input Pill
	var chat_pill := PanelContainer.new()
	chat_pill.add_theme_stylebox_override("panel", _box(Color("#181026", 0.90), 20, Color("#f9a8d4", 0.3), 1, 10, 5))
	_chat_bar.add_child(chat_pill)
	var ch_h := HBoxContainer.new()
	ch_h.add_theme_constant_override("separation", 6)
	chat_pill.add_child(ch_h)

	var log_b := _btn("💬", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 6, 4, 13)
	log_b.tooltip_text = "Mở lịch sử chat"
	log_b.pressed.connect(func():
		_show_chat_log = not _show_chat_log
		_chat_log_panel.visible = _show_chat_log
	)
	ch_h.add_child(log_b)

	_chat_input = _input_box("Nhắn gì đó cho cả phòng...", 140)
	_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_input.text_submitted.connect(func(txt: String): _submit_chat(txt))
	ch_h.add_child(_chat_input)

	var send_b := _btn("➤", Color("#ec4899"), Color("#f472b6"), 14, Color.TRANSPARENT, 0, 10, 4, 12)
	send_b.pressed.connect(func(): _submit_chat(_chat_input.text))
	ch_h.add_child(send_b)


func _submit_chat(txt: String) -> void:
	if not txt.strip_edges().is_empty():
		GameStore.send_chat(txt)
		_chat_input.text = ""
	_chat_input.release_focus()


func _build_zoom_pill() -> void:
	_zoom_pill = PanelContainer.new()
	_zoom_pill.anchor_left = 0.0
	_zoom_pill.anchor_top = 1.0
	_zoom_pill.anchor_bottom = 1.0
	_zoom_pill.offset_left = 16
	_zoom_pill.offset_top = -50
	_zoom_pill.offset_bottom = -16
	_zoom_pill.add_theme_stylebox_override("panel", _box(Color("#1a1228", 0.85), 18, Color("#f9a8d4", 0.25), 1, 8, 4))
	_game_hud.add_child(_zoom_pill)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 4)
	_zoom_pill.add_child(h)

	var z_out := _btn("−", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 12, Color.TRANSPARENT, 0, 8, 2, 13, Color("#fbcfe8"))
	z_out.pressed.connect(func():
		if room_node != null: room_node.zoom_by(-0.15)
	)
	h.add_child(z_out)

	_zoom_label = _lbl("135%", 11, Color("#fce7f3"))
	_zoom_label.custom_minimum_size = Vector2(44, 0)
	_zoom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_child(_zoom_label)

	var z_in := _btn("+", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 12, Color.TRANSPARENT, 0, 8, 2, 13, Color("#fbcfe8"))
	z_in.pressed.connect(func():
		if room_node != null: room_node.zoom_by(0.15)
	)
	h.add_child(z_in)

	var rst := _btn("🧭", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 12, Color.TRANSPARENT, 0, 8, 2, 13, Color("#fbcfe8"))
	rst.tooltip_text = "Đưa camera về giữa (Chuột phải kéo để di chuyển)"
	rst.pressed.connect(func():
		if room_node != null: room_node.reset_cam()
	)
	h.add_child(rst)


func _build_hover_hint() -> void:
	var wrap := HBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	wrap.offset_top = -110
	wrap.offset_bottom = -80
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(wrap)

	_hover_hint_pill = PanelContainer.new()
	_hover_hint_pill.add_theme_stylebox_override("panel", _box(Color("#181026", 0.90), 16, Color("#f9a8d4", 0.35), 1, 14, 5))
	_hover_hint_pill.visible = false
	_hover_hint_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(_hover_hint_pill)

	_hover_hint_label = _lbl("", 12, Color("#fce7f3"))
	_hover_hint_pill.add_child(_hover_hint_label)


# ===================================================================
# 4. ROOM & PROFILE MODALS
# ===================================================================

func _build_room_modal() -> void:
	_room_modal = Control.new()
	_room_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_room_modal.visible = false
	_root.add_child(_room_modal)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.62)
	_room_modal.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_room_modal.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(440, 0)
	card.add_theme_stylebox_override("panel", _box(Color("#1a1228"), 22, Color("#f9a8d4", 0.35), 1, 20, 18))
	center.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.add_child(v)

	var hdr := HBoxContainer.new()
	v.add_child(hdr)
	hdr.add_child(_lbl("🚪 Phòng Multiplayer Co-Focus", 16, Color.WHITE))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sp)
	var close_b := _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 12, Color.TRANSPARENT, 0, 8, 4, 13, Color("#94a3b8"))
	close_b.pressed.connect(func(): GameStore.set_show_room_modal(false))
	hdr.add_child(close_b)

	var info_box := PanelContainer.new()
	info_box.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.05), 14, Color(1, 1, 1, 0.1), 1, 12, 10))
	v.add_child(info_box)
	var info_h := HBoxContainer.new()
	info_box.add_child(info_h)
	var left_v := VBoxContainer.new()
	left_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_h.add_child(left_v)
	left_v.add_child(_lbl("Phòng hiện tại", 11, Color("#94a3b8")))
	var code_h := HBoxContainer.new()
	code_h.add_theme_constant_override("separation", 8)
	left_v.add_child(code_h)
	_room_modal_code = _lbl("#GENERAL", 18, Color("#f9a8d4"))
	code_h.add_child(_room_modal_code)
	_room_modal_host_badge = _lbl("👑 Chủ phòng", 10, Color("#fde68a"))
	code_h.add_child(_room_modal_host_badge)

	var right_v := VBoxContainer.new()
	info_h.add_child(right_v)
	right_v.add_child(_lbl("Thành viên", 11, Color("#94a3b8")))
	_room_modal_count = _lbl("👥 1 đang online", 13, Color.WHITE)
	right_v.add_child(_room_modal_count)

	_room_modal_guest_check = CheckButton.new()
	_room_modal_guest_check.text = "Cho phép khách cùng sửa nhà"
	_room_modal_guest_check.focus_mode = Control.FOCUS_NONE
	_room_modal_guest_check.toggled.connect(func(pressed: bool): GameStore.set_allow_guest_build(pressed))
	v.add_child(_room_modal_guest_check)

	_room_modal_reset_btn = _btn("↺ Khôi phục bài trí phòng mẫu ban đầu", Color.TRANSPARENT, Color(1, 1, 1, 0.08), 10, Color.TRANSPARENT, 0, 8, 4, 12, Color("#f9a8d4"))
	_room_modal_reset_btn.pressed.connect(func():
		GameStore.reset_default_room()
		GameStore.set_show_room_modal(false)
	)
	v.add_child(_room_modal_reset_btn)

	v.add_child(_lbl("Tạo phòng mới hoặc nhập mã phòng để vào chung:", 12, Color("#cbd5e1")))
	var join_h := HBoxContainer.new()
	join_h.add_theme_constant_override("separation", 8)
	v.add_child(join_h)
	_room_modal_input = _input_box("Ví dụ: GENERAL, STUDY24...", 16)
	_room_modal_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_room_modal_input.text_submitted.connect(func(txt: String):
		if not txt.strip_edges().is_empty():
			GameStore.join_room(txt)
			GameStore.set_show_room_modal(false)
	)
	join_h.add_child(_room_modal_input)
	var go_b := _btn("Vào Phòng", Color("#ec4899"), Color("#f472b6"), 12, Color.TRANSPARENT, 0, 14, 8, 12)
	go_b.pressed.connect(func():
		if not _room_modal_input.text.strip_edges().is_empty():
			GameStore.join_room(_room_modal_input.text)
			GameStore.set_show_room_modal(false)
	)
	join_h.add_child(go_b)

	v.add_child(_lbl("Người đang trong phòng:", 11, Color("#94a3b8")))
	_room_modal_players_flow = HFlowContainer.new()
	_room_modal_players_flow.add_theme_constant_override("h_separation", 6)
	_room_modal_players_flow.add_theme_constant_override("v_separation", 6)
	v.add_child(_room_modal_players_flow)


func _build_profile_modal() -> void:
	_profile_modal = Control.new()
	_profile_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_profile_modal.visible = false
	_root.add_child(_profile_modal)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.72)
	_profile_modal.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_profile_modal.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(730, 0)
	card.add_theme_stylebox_override("panel", _box(Color("#1a1228"), 24, Color("#f9a8d4", 0.35), 1, 20, 18))
	center.add_child(card)

	var main_v := VBoxContainer.new()
	main_v.add_theme_constant_override("separation", 14)
	card.add_child(main_v)

	# Header
	var hdr := HBoxContainer.new()
	main_v.add_child(hdr)
	var hv := VBoxContainer.new()
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(hv)
	_profile_title = _lbl("👗 Tùy Chỉnh Nhân Vật & Trang Phục", 16, Color.WHITE)
	hv.add_child(_profile_title)
	hv.add_child(_lbl("Chọn nhân vật, xem thử các dáng đi bộ / ngồi gõ phím và đặt tên hiển thị", 11, Color("#94a3b8")))
	_profile_close_btn = _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.1), 12, Color.TRANSPARENT, 0, 8, 4, 14, Color("#94a3b8"))
	_profile_close_btn.pressed.connect(func(): GameStore.set_show_profile_modal(false))
	hdr.add_child(_profile_close_btn)

	# Body 2 columns
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 18)
	main_v.add_child(cols)

	# Left column: Preview Stage
	var stage_panel := PanelContainer.new()
	stage_panel.custom_minimum_size = Vector2(280, 0)
	stage_panel.add_theme_stylebox_override("panel", _box(Color("#201536"), 18, Color(1, 1, 1, 0.1), 1, 14, 14))
	cols.add_child(stage_panel)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	stage_panel.add_child(sv)

	var ptabs := HFlowContainer.new()
	ptabs.alignment = FlowContainer.ALIGNMENT_CENTER
	ptabs.add_theme_constant_override("h_separation", 4)
	ptabs.add_theme_constant_override("v_separation", 4)
	sv.add_child(ptabs)
	for pt in PREVIEW_TABS:
		var ptid := str(pt["id"])
		var b := _btn(str(pt["label"]), Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 8, 4, 10)
		b.pressed.connect(func():
			_preview_tab = ptid
			_update_profile_preview()
		)
		ptabs.add_child(b)
		_profile_preview_tab_btns[ptid] = b

	var stage_center := VBoxContainer.new()
	stage_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_center.alignment = BoxContainer.ALIGNMENT_CENTER
	stage_center.add_theme_constant_override("separation", 6)
	sv.add_child(stage_center)

	var nb_center := CenterContainer.new()
	stage_center.add_child(nb_center)
	_profile_preview_badge = PanelContainer.new()
	_profile_preview_badge.add_theme_stylebox_override("panel", _box(Color("#181026", 0.9), 12, Color("#a78bfa"), 1, 10, 3))
	nb_center.add_child(_profile_preview_badge)
	_profile_preview_name = _lbl("Người chơi", 11, Color.WHITE)
	_profile_preview_badge.add_child(_profile_preview_name)

	_profile_preview_tex = TextureRect.new()
	_profile_preview_tex.custom_minimum_size = Vector2(165, 190)
	_profile_preview_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_profile_preview_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_profile_preview_tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	stage_center.add_child(_profile_preview_tex)

	var rot_row := HBoxContainer.new()
	sv.add_child(rot_row)
	_profile_facing_label = _lbl("Góc: Trước Phải (SE)", 11, Color("#cbd5e1"))
	_profile_facing_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rot_row.add_child(_profile_facing_label)
	var rot_b := _btn("🔄 Xoay góc", Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 10, Color.TRANSPARENT, 0, 10, 5, 11)
	rot_b.pressed.connect(func():
		_facing_idx = (_facing_idx + 1) % PREVIEW_FACINGS.size()
		_update_profile_preview()
	)
	rot_row.add_child(rot_b)

	# Right column: Skins + Custom Studio + Form
	var right_v := VBoxContainer.new()
	right_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_v.add_theme_constant_override("separation", 10)
	cols.add_child(right_v)

	right_v.add_child(_lbl("1. Chọn Nhân Vật Isometric (%d nhân vật):" % GameData.CHARACTER_SKINS.size(), 12, Color("#cbd5e1")))

	var skin_scroll := ScrollContainer.new()
	skin_scroll.custom_minimum_size = Vector2(0, 125)
	right_v.add_child(skin_scroll)
	_profile_skin_grid = GridContainer.new()
	_profile_skin_grid.columns = 4
	_profile_skin_grid.add_theme_constant_override("h_separation", 8)
	_profile_skin_grid.add_theme_constant_override("v_separation", 8)
	skin_scroll.add_child(_profile_skin_grid)

	for skin in GameData.CHARACTER_SKINS:
		var sid := str(skin["id"])
		var sb := _btn("", Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 14, Color(1, 1, 1, 0.1), 1, 6, 6, 11)
		sb.custom_minimum_size = Vector2(102, 88)
		sb.pressed.connect(func():
			_draft_outfit = sid
			_refresh_profile_controls()
		)
		var sv_box := VBoxContainer.new()
		sv_box.set_anchors_preset(Control.PRESET_FULL_RECT)
		sv_box.alignment = BoxContainer.ALIGNMENT_CENTER
		sv_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sb.add_child(sv_box)
		var av := TextureRect.new()
		av.custom_minimum_size = Vector2(52, 52)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		av.texture = GameData.get_texture(str(skin["avatar"]))
		av.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sv_box.add_child(av)
		var sn := _lbl(str(skin["name"]), 11, Color.WHITE)
		sn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sv_box.add_child(sn)
		_profile_skin_grid.add_child(sb)
		_profile_skin_btns[sid] = sb

	# Custom Avatar Creator Studio
	_profile_custom_box = PanelContainer.new()
	_profile_custom_box.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.05), 14, Color("#f472b6", 0.3), 1, 10, 10))
	right_v.add_child(_profile_custom_box)
	var cbox_v := VBoxContainer.new()
	cbox_v.add_theme_constant_override("separation", 8)
	_profile_custom_box.add_child(cbox_v)

	var ctab_h := HBoxContainer.new()
	ctab_h.add_theme_constant_override("separation", 4)
	cbox_v.add_child(ctab_h)
	for ct in [
		{"id": "hair", "label": "Tóc"},
		{"id": "face", "label": "Da & Mắt"},
		{"id": "outfit", "label": "Áo & Quần"},
		{"id": "acc", "label": "Phụ kiện"},
	]:
		var ctid := str(ct["id"])
		var cb := _btn(str(ct["label"]), Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.15), 8, Color.TRANSPARENT, 0, 8, 4, 11)
		cb.pressed.connect(func():
			_custom_tab = ctid
			_refresh_profile_controls()
		)
		ctab_h.add_child(cb)
		_profile_custom_tab_btns[ctid] = cb

	var sp_c := Control.new()
	sp_c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctab_h.add_child(sp_c)
	var rand_b := _btn("🔀 Ngẫu nhiên", Color("#8b5cf6", 0.25), Color("#8b5cf6", 0.4), 8, Color("#a78bfa", 0.3), 1, 8, 4, 11, Color("#ede9fe"))
	rand_b.pressed.connect(_randomize_custom_avatar)
	ctab_h.add_child(rand_b)

	_profile_custom_content = VBoxContainer.new()
	_profile_custom_content.add_theme_constant_override("separation", 6)
	cbox_v.add_child(_profile_custom_content)

	# Name & Room inputs
	var form_row := HBoxContainer.new()
	form_row.add_theme_constant_override("separation", 10)
	right_v.add_child(form_row)

	var nv := VBoxContainer.new()
	nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_row.add_child(nv)
	nv.add_child(_lbl("2. Tên hiển thị:", 11, Color("#cbd5e1")))
	_profile_name_input = _input_box("Nhập tên của bạn...", 24)
	_profile_name_input.text_changed.connect(func(txt: String):
		_draft_name = txt
		_update_profile_preview()
	)
	nv.add_child(_profile_name_input)

	var rv := VBoxContainer.new()
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_row.add_child(rv)
	rv.add_child(_lbl("3. Mã phòng muốn vào:", 11, Color("#cbd5e1")))
	_profile_room_input = _input_box("GENERAL", 16)
	rv.add_child(_profile_room_input)

	# Color & Submit row
	var foot_row := HBoxContainer.new()
	foot_row.add_theme_constant_override("separation", 10)
	right_v.add_child(foot_row)

	var col_v := VBoxContainer.new()
	col_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot_row.add_child(col_v)
	col_v.add_child(_lbl("4. Màu viền thẻ tên:", 11, Color("#cbd5e1")))
	var col_h := HBoxContainer.new()
	col_h.add_theme_constant_override("separation", 6)
	col_v.add_child(col_h)
	for c_hex in TINT_COLORS:
		var ch := str(c_hex)
		var cb := _btn("", Color(ch), Color(ch).lightened(0.1), 12, Color.WHITE, 0, 0, 0, 10)
		cb.custom_minimum_size = Vector2(24, 24)
		cb.pressed.connect(func():
			_draft_color = ch
			_refresh_profile_controls()
		)
		col_h.add_child(cb)
		_profile_color_btns[ch] = cb

	_profile_submit_btn = _btn("Lưu Thay Đổi 💕", Color("#ec4899"), Color("#f472b6"), 16, Color.TRANSPARENT, 0, 20, 10, 13)
	_profile_submit_btn.pressed.connect(_save_profile)
	foot_row.add_child(_profile_submit_btn)


func _build_toast_banner() -> void:
	var wrap := HBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_TOP_WIDE)
	wrap.offset_top = 64
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(wrap)

	_toast_pill = PanelContainer.new()
	_toast_pill.add_theme_stylebox_override("panel", _box(Color("#1a1228", 0.95), 18, Color("#f472b6", 0.5), 1, 18, 8))
	_toast_pill.visible = false
	_toast_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(_toast_pill)

	_toast_label = _lbl("", 12, Color.WHITE)
	_toast_pill.add_child(_toast_label)


func _build_embedded_banner() -> void:
	_embedded_banner_btn = _btn(
		"⛶ Mở Cửa Sổ Toàn Màn Hình Retina (F11)",
		Color("#ec4899", 0.92),
		Color("#f472b6"),
		16,
		Color("#fbcfe8", 0.65),
		1,
		14,
		7,
		12,
		Color.WHITE
	)
	_embedded_banner_btn.anchor_left = 0.0
	_embedded_banner_btn.anchor_top = 1.0
	_embedded_banner_btn.anchor_bottom = 1.0
	_embedded_banner_btn.offset_left = 16
	_embedded_banner_btn.offset_bottom = -58
	_embedded_banner_btn.offset_top = -94
	_embedded_banner_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_embedded_banner_btn.tooltip_text = "Thoát chế độ nhúng nhỏ của Godot Editor sang cửa sổ Retina đầy đủ"
	_embedded_banner_btn.pressed.connect(func(): GameStore.toggle_fullscreen())
	_embedded_banner_btn.visible = GameStore.is_embedded_display()
	_root.add_child(_embedded_banner_btn)


func _build_update_banner() -> void:
	_update_banner = PanelContainer.new()
	_update_banner.anchor_left = 1.0
	_update_banner.anchor_right = 1.0
	_update_banner.anchor_top = 1.0
	_update_banner.anchor_bottom = 1.0
	_update_banner.offset_left = -330
	_update_banner.offset_right = -16
	_update_banner.offset_bottom = -130
	_update_banner.offset_top = -280
	_update_banner.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_update_banner.custom_minimum_size = Vector2(314, 0)
	_update_banner.add_theme_stylebox_override(
		"panel",
		_box(Color("#1a1228", 0.96), 18, Color("#f472b6", 0.5), 1, 14, 12)
	)
	_update_banner.visible = false
	_root.add_child(_update_banner)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_update_banner.add_child(v)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	v.add_child(head)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(30, 30)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_theme_stylebox_override("panel", _box(Color("#ec4899"), 10, Color("#a855f7", 0.6), 1, 6, 4))
	head.add_child(badge)
	var badge_lbl := _lbl("✨", 13, Color.WHITE)
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_child(badge_lbl)

	var title_v := VBoxContainer.new()
	title_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_v.add_theme_constant_override("separation", 2)
	head.add_child(title_v)
	_update_title_label = _lbl("Đã có bản cập nhật mới", 13, Color.WHITE)
	title_v.add_child(_update_title_label)
	var sub_lbl := _lbl("Cập nhật nhanh cho Cozy Focus Room", 10, Color("#fbcfe8", 0.85))
	title_v.add_child(sub_lbl)

	_update_close_btn = _btn("✕", Color.TRANSPARENT, Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 6, 3, 12, Color("#cbd5e1"))
	_update_close_btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_update_close_btn.pressed.connect(func(): GameStore.dismiss_update())
	head.add_child(_update_close_btn)

	_update_notes_box = PanelContainer.new()
	_update_notes_box.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.06), 12, Color(1, 1, 1, 0.08), 1, 10, 8))
	_update_notes_box.visible = false
	v.add_child(_update_notes_box)

	var notes_scroll := ScrollContainer.new()
	notes_scroll.custom_minimum_size = Vector2(0, 54)
	_update_notes_box.add_child(notes_scroll)

	_update_notes_label = _lbl("", 11, Color("#e2e8f0"), true)
	_update_notes_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notes_scroll.add_child(_update_notes_label)

	_update_progress_box = VBoxContainer.new()
	_update_progress_box.add_theme_constant_override("separation", 4)
	_update_progress_box.visible = false
	v.add_child(_update_progress_box)

	_update_progress_label = _lbl("Đang tải bản cập nhật... 0%", 11, Color("#fbcfe8"))
	_update_progress_box.add_child(_update_progress_label)

	_update_progress_bar = ProgressBar.new()
	_update_progress_bar.min_value = 0.0
	_update_progress_bar.max_value = 100.0
	_update_progress_bar.value = 0.0
	_update_progress_bar.show_percentage = false
	_update_progress_bar.custom_minimum_size = Vector2(0, 8)
	_update_progress_bar.add_theme_stylebox_override("background", _box(Color(1, 1, 1, 0.12), 4, Color.TRANSPARENT, 0, 0, 0))
	_update_progress_bar.add_theme_stylebox_override("fill", _box(Color("#ec4899"), 4, Color.TRANSPARENT, 0, 0, 0))
	_update_progress_box.add_child(_update_progress_bar)

	_update_error_label = _lbl("", 11, Color("#fda4af"), true)
	_update_error_label.visible = false
	v.add_child(_update_error_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 8)
	v.add_child(btn_row)

	_update_later_btn = _btn("Để sau", Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 12, Color.TRANSPARENT, 0, 12, 6, 11, Color("#e2e8f0"))
	_update_later_btn.pressed.connect(func(): GameStore.dismiss_update())
	btn_row.add_child(_update_later_btn)

	_update_install_btn = _btn("⬇ Cập nhật & Khởi động lại", Color("#ec4899"), Color("#f472b6"), 12, Color("#fbcfe8", 0.4), 1, 12, 6, 11, Color.WHITE)
	_update_install_btn.pressed.connect(func(): GameStore.start_update_download_and_install())
	btn_row.add_child(_update_install_btn)


# ===================================================================
# REFRESH LOGIC
# ===================================================================

func _refresh_all() -> void:
	var scr := GameStore.current_screen
	_login_root.visible = (scr == "login")
	_lobby_root.visible = (scr == "lobby")
	_game_hud.visible = (scr == "game")

	if scr == "login":
		_refresh_login()
	elif scr == "lobby":
		_refresh_lobby()
	elif scr == "game":
		_refresh_game_hud()

	_refresh_room_modal()
	_refresh_profile_modal()
	_refresh_toast(GameStore.toast_message)
	_refresh_update_banner()


func _refresh_update_banner() -> void:
	if _update_banner == null:
		return
	var should_show := GameStore.update_downloading or not GameStore.update_error.is_empty() or (
		GameStore.update_available
		and not GameStore.latest_version.is_empty()
		and GameStore.update_dismissed_version != GameStore.latest_version
	)
	_update_banner.visible = should_show
	if not should_show:
		return

	_update_title_label.text = "Đã có bản cập nhật v%s" % GameStore.latest_version

	var has_notes := not GameStore.update_notes.is_empty()
	_update_notes_box.visible = has_notes
	if has_notes:
		_update_notes_label.text = GameStore.update_notes

	_update_progress_box.visible = GameStore.update_downloading
	if GameStore.update_downloading:
		_update_progress_bar.value = float(GameStore.update_progress_pct)
		_update_progress_label.text = "Đang tải bản cập nhật... %d%%" % GameStore.update_progress_pct

	var has_err := not GameStore.update_error.is_empty()
	_update_error_label.visible = has_err
	if has_err:
		_update_error_label.text = GameStore.update_error

	_update_close_btn.visible = not GameStore.update_downloading
	_update_later_btn.visible = not GameStore.update_downloading
	_update_install_btn.disabled = GameStore.update_downloading
	_update_install_btn.text = "⏳ Đang cài đặt..." if GameStore.update_downloading else "⬇ Cập nhật & Khởi động lại"


func _refresh_login() -> void:
	if not GameStore.auth_error.is_empty():
		_login_error_box.visible = true
		_login_error_label.text = GameStore.auth_error
	else:
		_login_error_box.visible = false

	_login_google_btn.visible = not GameStore.is_waiting_google
	_login_waiting_box.visible = GameStore.is_waiting_google
	_login_guest_btn.visible = not _show_guest_input
	_login_guest_form.visible = _show_guest_input


func _refresh_lobby() -> void:
	var u := GameStore.user
	_lobby_user_name.text = str(u.get("name", "Khách Chill"))
	var is_guest := bool(u.get("isGuest", true))
	_lobby_user_badge.text = "Khách" if is_guest else "🛡️ Google"
	_lobby_user_sub.text = "Đang chơi ở chế độ khách" if is_guest else str(u.get("email", ""))
	var outfit := str(GameStore.local_player.get("outfit", "c1"))
	var av_path := "res://sprites/characters/%s/avatar.png" % ("base" if outfit == "custom" else outfit)
	_lobby_user_avatar.texture = GameData.get_texture(av_path)
	if GameStore.general_players_count >= 0:
		_lobby_general_badge.text = "🟢 %d online" % GameStore.general_players_count
	else:
		_lobby_general_badge.text = "🟢 Trực tuyến"


func _refresh_game_hud() -> void:
	var is_mini := GameStore.mini_mode
	_topbar_panel.visible = not is_mini
	_mini_topbar_panel.visible = is_mini

	var rem := int(GameStore.pomodoro.get("remainingSec", 25 * 60))
	var mins := "%02d" % int(floor(float(rem) / 60.0))
	var secs := "%02d" % (rem % 60)
	var time_str := "%s:%s" % [mins, secs]

	var dot_col := Color("#34d399") if GameStore.connected else Color("#fbbf24")
	_top_status_dot.color = dot_col
	_mini_status_dot.color = dot_col
	_top_crown_label.visible = GameStore.is_host
	_top_room_label.text = GameStore.room_code
	_mini_room_label.text = "#" + GameStore.room_code
	_top_conn_label.visible = not GameStore.connected
	_top_count_label.text = "👥 %d" % GameStore.players.size()
	_mini_timer_label.text = time_str
	_top_focus_btn.text = "📝 " + time_str

	var lmode := str(GameStore.layout.get("lightingMode", "day"))
	_style_btn(_top_day_btn, Color("#fbbf24", 0.25) if lmode == "day" else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, Color("#fde68a") if lmode == "day" else Color("#94a3b8"))
	_style_btn(_top_sunset_btn, Color("#fb923c", 0.25) if lmode == "sunset" else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, Color("#fed7aa") if lmode == "sunset" else Color("#94a3b8"))
	_style_btn(_top_night_btn, Color("#818cf8", 0.3) if lmode == "night" else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, Color("#c7d2fe") if lmode == "night" else Color("#94a3b8"))
	var rain := bool(GameStore.layout.get("rainEnabled", false))
	_style_btn(_top_rain_btn, Color("#38bdf8", 0.25) if rain else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 12, Color.TRANSPARENT, 0, 8, 4, Color("#bae6fd") if rain else Color("#94a3b8"))

	var can_dec := GameStore.can_build()
	_top_decor_btn.text = ("🖌️ " if can_dec else "🔒 ") + "Decor (B)"
	_style_btn(
		_top_decor_btn,
		Color("#ec4899") if GameStore.build_mode else Color(1, 1, 1, 0.1 if can_dec else 0.05),
		Color("#f472b6") if GameStore.build_mode else Color(1, 1, 1, 0.18),
		14, Color.TRANSPARENT, 0, 10, 4,
		Color.WHITE if GameStore.build_mode else (Color("#fce7f3") if can_dec else Color("#94a3b8"))
	)

	_style_btn(_top_focus_btn, Color("#ec4899", 0.25) if GameStore.show_focus_panel else Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 14, Color("#f472b6", 0.4) if GameStore.show_focus_panel else Color.TRANSPARENT, 1 if GameStore.show_focus_panel else 0, 10, 4)
	_style_btn(_top_audio_btn, Color("#ec4899", 0.3) if GameStore.show_audio_mixer else Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 14, Color.TRANSPARENT, 0, 8, 4)
	_style_btn(_top_pin_btn, Color("#fbbf24", 0.25) if GameStore.always_on_top else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 8, 4)
	_style_btn(_top_full_btn, Color("#ec4899", 0.3) if GameStore.is_fullscreen else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 14, Color.TRANSPARENT, 0, 8, 4, Color("#fce7f3"))
	_style_btn(_mini_pin_btn, Color("#ec4899", 0.3) if GameStore.always_on_top else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 6, 4)

	_focus_panel.visible = GameStore.show_focus_panel and not is_mini and not GameStore.build_mode
	_build_dock.visible = GameStore.build_mode
	_audio_modal.visible = GameStore.show_audio_mixer
	_chat_bar.visible = not GameStore.build_mode and not is_mini

	_refresh_pomodoro()
	_refresh_todos()
	_refresh_build_dock()
	_refresh_audio_mixer()
	_refresh_chat_controls()


func _refresh_pomodoro() -> void:
	var rem := int(GameStore.pomodoro.get("remainingSec", 25 * 60))
	var total := maxi(1, int(GameStore.pomodoro.get("totalSec", 25 * 60)))
	var mins := "%02d" % int(floor(float(rem) / 60.0))
	var secs := "%02d" % (rem % 60)
	var time_str := "%s:%s" % [mins, secs]
	_focus_time_label.text = time_str
	_top_focus_btn.text = "📝 " + time_str
	_mini_timer_label.text = time_str
	_focus_pomo_count.text = "🍅 x%d" % GameStore.completed_pomodoros
	_focus_progress.value = clampf(float(total - rem) / float(total) * 100.0, 0.0, 100.0)

	var pmode := str(GameStore.pomodoro.get("mode", "focus"))
	for mid in _focus_mode_btns.keys():
		var b: Button = _focus_mode_btns[mid]
		_style_btn(b, Color("#ec4899") if mid == pmode else Color(1, 1, 1, 0.06), Color("#f472b6") if mid == pmode else Color(1, 1, 1, 0.14), 8, Color.TRANSPARENT, 0, 6, 4)

	var running := bool(GameStore.pomodoro.get("isRunning", false))
	_focus_play_btn.text = "⏸ Tạm dừng" if running else "▶ Bắt đầu"
	_style_btn(_focus_play_btn, Color("#f59e0b") if running else Color("#ec4899"), Color("#fbbf24") if running else Color("#f472b6"), 10, Color.TRANSPARENT, 0, 14, 6, Color("#0f172a") if running else Color.WHITE)

	var synced := bool(GameStore.pomodoro.get("syncedWithRoom", true))
	_focus_sync_btn.text = "🔗 Đang đồng bộ giờ học cả phòng" if synced else "🔗 Chế độ đếm giờ cá nhân"
	_style_btn(_focus_sync_btn, Color("#10b981", 0.2) if synced else Color(1, 1, 1, 0.06), Color("#10b981", 0.3) if synced else Color(1, 1, 1, 0.12), 12, Color("#34d399", 0.3) if synced else Color.TRANSPARENT, 1 if synced else 0, 10, 4, Color("#a7f3d0") if synced else Color("#94a3b8"))

	var seated := not str(GameStore.local_player.get("seatedOnItemUid", "")).is_empty() or str(GameStore.local_player.get("activity", "")) == "sit_floor"
	_focus_stand_btn.visible = seated


func _refresh_todos() -> void:
	for child in _todo_list_vbox.get_children():
		_todo_list_vbox.remove_child(child)
		child.queue_free()

	var done_count := 0
	for t in GameStore.todos:
		if t is Dictionary and bool(t.get("completed", false)):
			done_count += 1
	_todo_count_label.text = "%d/%d xong" % [done_count, GameStore.todos.size()]

	if GameStore.todos.is_empty():
		var empty_lbl := _lbl("Chưa có mục tiêu nào. Thêm 1 việc để ghim lên nhân vật nhé!", 11, Color("#94a3b8"), true)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_todo_list_vbox.add_child(empty_lbl)
		return

	for t_val in GameStore.todos:
		if not (t_val is Dictionary):
			continue
		var todo: Dictionary = t_val
		var tid := str(todo.get("id", ""))
		var is_pinned := (GameStore.pinned_todo_id == tid)
		var is_done := bool(todo.get("completed", false))

		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override(
			"panel",
			_box(
				Color("#ec4899", 0.2) if is_pinned else Color(1, 1, 1, 0.05),
				10,
				Color("#f472b6", 0.5) if is_pinned else Color(1, 1, 1, 0.08),
				1,
				8,
				5
			)
		)
		_todo_list_vbox.add_child(row_panel)

		var rh := HBoxContainer.new()
		rh.add_theme_constant_override("separation", 6)
		row_panel.add_child(rh)

		var chk := _btn("✓" if is_done else "", Color("#10b981") if is_done else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 5, Color("#34d399") if is_done else Color(1, 1, 1, 0.35), 1, 4, 0, 10)
		chk.custom_minimum_size = Vector2(18, 18)
		chk.pressed.connect(func(): GameStore.toggle_todo(tid))
		rh.add_child(chk)

		var txt := _lbl(str(todo.get("text", "")), 11, Color("#94a3b8") if is_done else Color("#f1f5f9"))
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		txt.tooltip_text = str(todo.get("text", ""))
		rh.add_child(txt)

		var pin_b := _btn("📌", Color("#fbbf24", 0.25) if is_pinned else Color.TRANSPARENT, Color(1, 1, 1, 0.12), 6, Color.TRANSPARENT, 0, 4, 2, 10, Color("#fde68a") if is_pinned else Color("#94a3b8"))
		pin_b.pressed.connect(func(): GameStore.pin_todo("" if is_pinned else tid))
		rh.add_child(pin_b)

		var del_b := _btn("🗑️", Color.TRANSPARENT, Color("#f43f5e", 0.2), 6, Color.TRANSPARENT, 0, 4, 2, 10, Color("#94a3b8"))
		del_b.pressed.connect(func(): GameStore.delete_todo(tid))
		rh.add_child(del_b)


func _refresh_build_dock() -> void:
	if not GameStore.build_mode:
		return

	for tid in _build_tab_btns.keys():
		var b: Button = _build_tab_btns[tid]
		var act := (str(tid) == GameStore.build_tab)
		_style_btn(b, Color("#ec4899") if act else Color(1, 1, 1, 0.06), Color("#f472b6") if act else Color(1, 1, 1, 0.14), 10, Color.TRANSPARENT, 0, 10, 6)

	var items: Array = GameStore.layout.get("items", [])
	var max_items := int(GameStore.layout.get("maxItems", 0))
	if max_items > 0:
		_build_count_label.text = "Đồ vật: %d/%d" % [items.size(), max_items]
	else:
		_build_count_label.text = "Đồ vật: %d" % items.size()

	var moving_item: Dictionary = {}
	if not GameStore.moving_item_uid.is_empty():
		for it in items:
			if it is Dictionary and str(it.get("uid", "")) == GameStore.moving_item_uid:
				moving_item = it
				break
	if not moving_item.is_empty():
		var mcat := GameData.get_catalog_item(str(moving_item.get("catalogId", "")))
		_build_moving_label.text = "Đang di chuyển: %s" % str(mcat.get("name", ""))
		_build_moving_box.visible = true
	else:
		_build_moving_box.visible = false

	_style_btn(_build_flip_btn, Color("#fbbf24", 0.25) if GameStore.place_flipped else Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 10, Color("#fcd34d", 0.4) if GameStore.place_flipped else Color.TRANSPARENT, 1 if GameStore.place_flipped else 0, 10, 6, Color("#fde68a") if GameStore.place_flipped else Color("#e2e8f0"))

	_build_guest_btn.visible = GameStore.is_host
	var allow_g := bool(GameStore.layout.get("allowGuestBuild", false))
	_build_guest_btn.text = "👥 Khách: Được sửa" if allow_g else "👥 Khách: Chỉ xem"
	_style_btn(_build_guest_btn, Color("#10b981", 0.25) if allow_g else Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 10, Color("#34d399", 0.4) if allow_g else Color.TRANSPARENT, 1 if allow_g else 0, 10, 6)

	var is_floor := (GameStore.build_tab == "floor")
	_build_floor_area.visible = is_floor
	_build_catalog_scroll.visible = not is_floor

	if is_floor:
		for bid in _build_floor_brush_btns.keys():
			var fb: Button = _build_floor_brush_btns[bid]
			var act := (GameStore.active_floor_brush == str(bid))
			_style_btn(fb, Color("#ec4899", 0.25) if act else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 12, Color("#f472b6") if act else Color(1, 1, 1, 0.1), 1, 10, 6)

		_style_btn(_build_wall_add_btn, Color("#8b5cf6", 0.3) if GameStore.active_wall_brush == "add" else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 12, Color("#a78bfa") if GameStore.active_wall_brush == "add" else Color(1, 1, 1, 0.1), 1, 10, 6)
		_style_btn(_build_wall_rem_btn, Color("#f43f5e", 0.25) if GameStore.active_wall_brush == "remove" else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 12, Color("#fb7185") if GameStore.active_wall_brush == "remove" else Color(1, 1, 1, 0.1), 1, 10, 6)

		var max_floor := int(GameStore.layout.get("maxFloorTiles", 0))
		_build_floor_budget_label.visible = max_floor > 0
		if max_floor > 0:
			_build_floor_budget_label.text = "Sàn: %d/%d" % [GameData.count_floor_tiles(GameStore.layout.get("floorMap", [])), max_floor]

		var max_wall := int(GameStore.layout.get("maxWallTiles", 0))
		_build_wall_budget_label.visible = max_wall > 0
		if max_wall > 0:
			var wcount := (GameStore.layout["walls"] as Array).size() if GameStore.layout.get("walls") is Array else 0
			_build_wall_budget_label.text = "Tường: %d/%d" % [wcount, max_wall]

		var wtheme := str(GameStore.layout.get("wallTheme", "lofi_purple"))
		for wid in _build_wall_theme_btns.keys():
			var wb: Button = _build_wall_theme_btns[wid]
			_style_btn(wb, Color(1, 1, 1, 0.2) if wid == wtheme else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.14), 8, Color.TRANSPARENT, 0, 10, 5)
		_build_reset_btn.visible = GameStore.is_host
	else:
		_rebuild_catalog_cards()


func _rebuild_catalog_cards() -> void:
	for child in _build_catalog_hbox.get_children():
		_build_catalog_hbox.remove_child(child)
		child.queue_free()

	var items: Array = GameStore.layout.get("items", [])
	var max_items := int(GameStore.layout.get("maxItems", 0))

	for cat in GameData.CATALOG_ITEMS:
		if str(cat.get("category", "")) != GameStore.build_tab:
			continue
		var cid := str(cat["id"])
		var is_sel := (GameStore.selected_catalog_id == cid)
		var is_at_limit := (max_items > 0 and items.size() >= max_items and not is_sel)

		var card_btn := _btn(
			"",
			Color("#ec4899", 0.25) if is_sel else Color(1, 1, 1, 0.05),
			Color(1, 1, 1, 0.12),
			14,
			Color("#f472b6") if is_sel else Color(1, 1, 1, 0.1),
			1,
			8,
			8,
			11
		)
		card_btn.custom_minimum_size = Vector2(132, 114)
		card_btn.disabled = is_at_limit
		card_btn.tooltip_text = str(cat.get("description", ""))
		card_btn.pressed.connect(func(): GameStore.select_catalog_item("" if is_sel else cid))
		_build_catalog_hbox.add_child(card_btn)

		var cv := VBoxContainer.new()
		cv.set_anchors_preset(Control.PRESET_FULL_RECT)
		cv.alignment = BoxContainer.ALIGNMENT_CENTER
		cv.add_theme_constant_override("separation", 4)
		cv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_btn.add_child(cv)

		var fp_lbl := _lbl(GameData.format_footprint_label(cat), 9, Color("#e2e8f0"))
		fp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cv.add_child(fp_lbl)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = GameData.get_texture(str(cat["sprite"]))
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_child(icon)

		var nm := _lbl(str(cat["name"]), 11, Color("#f1f5f9"))
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		cv.add_child(nm)

		var badge_txt := "Đặt sàn"
		var badge_col := Color("#cbd5e1")
		if str(cat.get("placement", "")) == "surface":
			badge_txt = "Đặt lên bàn ✨"
			badge_col = Color("#bae6fd")
		elif str(cat.get("placement", "")) == "wall":
			badge_txt = "Treo tường"
			badge_col = Color("#ddd6fe")
		elif (cat.get("seatSlots", []) as Array).size() > 0:
			badge_txt = "Ngồi Focus 🪑"
			badge_col = Color("#a7f3d0")
		elif bool(cat.get("isSurface", false)):
			badge_txt = "Mặt bàn chứa đồ"
			badge_col = Color("#fde68a")
		var blbl := _lbl(badge_txt, 9, badge_col)
		blbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(blbl)


func _refresh_audio_mixer() -> void:
	var muted := bool(GameStore.audio_mixer.get("muted", false))
	_audio_mute_btn.text = "🔇" if muted else "🔊"
	_style_btn(_audio_mute_btn, Color("#f43f5e", 0.25) if muted else Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 12, Color.TRANSPARENT, 0, 8, 4)
	for cid in _audio_sliders.keys():
		var sl: HSlider = _audio_sliders[cid]
		var pct: Label = _audio_pct_labels[cid]
		var val := float(GameStore.audio_mixer.get(cid, 0.0))
		sl.set_value_no_signal(val)
		pct.text = "%d%%" % roundi(val * 100.0)


func _refresh_chat_controls() -> void:
	var is_sitting := str(GameStore.local_player.get("activity", "")) == "sit_floor"
	_chat_sit_btn.text = "🧘 Đứng dậy (G)" if is_sitting else "🧘 Ngồi bệt (G)"
	_style_btn(_chat_sit_btn, Color("#ec4899", 0.3) if is_sitting else Color("#181026", 0.85), Color(1, 1, 1, 0.15), 16, Color("#f472b6") if is_sitting else Color("#f9a8d4", 0.25), 1, 10, 5)
	_chat_profile_name.text = str(GameStore.local_player.get("name", "Người chơi"))
	var outfit := str(GameStore.local_player.get("outfit", "c1"))
	var av_path := "res://sprites/characters/%s/avatar.png" % ("base" if outfit == "custom" else outfit)
	_chat_profile_avatar.texture = GameData.get_texture(av_path)


func _refresh_chat_log() -> void:
	for child in _chat_log_vbox.get_children():
		_chat_log_vbox.remove_child(child)
		child.queue_free()
	if GameStore.chat_messages.is_empty():
		_chat_log_vbox.add_child(_lbl("Gửi tin nhắn để hiện bong bóng chat trên đầu nhân vật ✨", 11, Color("#94a3b8"), true))
		return
	for m in GameStore.chat_messages:
		if m is Dictionary:
			var l := _lbl("%s: %s" % [str(m.get("name", "")), str(m.get("text", ""))], 11, Color("#f1f5f9"), true)
			_chat_log_vbox.add_child(l)


func _refresh_room_modal() -> void:
	var open := GameStore.show_room_modal and GameStore.current_screen != "login"
	_room_modal.visible = open
	if not open:
		_was_room_modal_open = false
		return
	if not _was_room_modal_open:
		_was_room_modal_open = true
		_room_modal_input.text = GameStore.room_code

	_room_modal_code.text = "#" + GameStore.room_code
	_room_modal_host_badge.visible = GameStore.is_host
	_room_modal_count.text = "👥 %d đang online" % GameStore.players.size()
	_room_modal_guest_check.visible = GameStore.is_host
	_room_modal_guest_check.set_pressed_no_signal(bool(GameStore.layout.get("allowGuestBuild", false)))
	_room_modal_reset_btn.visible = GameStore.is_host

	for child in _room_modal_players_flow.get_children():
		_room_modal_players_flow.remove_child(child)
		child.queue_free()

	for p_val in GameStore.players.values():
		if not (p_val is Dictionary):
			continue
		var p: Dictionary = p_val
		var pid := str(p.get("id", ""))
		var pill := PanelContainer.new()
		var bc := Color.from_string(str(p.get("tintColor", "#f472b6")), Color("#f472b6"))
		pill.add_theme_stylebox_override("panel", _box(Color(1, 1, 1, 0.08), 14, bc, 1, 10, 4))
		_room_modal_players_flow.add_child(pill)
		var ph := HBoxContainer.new()
		ph.add_theme_constant_override("separation", 6)
		pill.add_child(ph)
		var label_str := str(p.get("name", "Khách"))
		if pid == GameStore.my_player_id:
			label_str += " (Bạn)"
		ph.add_child(_lbl(label_str, 11, Color.WHITE))
		if GameStore.is_host and pid != GameStore.my_player_id:
			var kick_b := _btn("✕", Color.TRANSPARENT, Color("#ef4444", 0.25), 8, Color.TRANSPARENT, 0, 4, 1, 10, Color("#fca5a5"))
			kick_b.pressed.connect(func(): GameStore.kick_player(pid))
			ph.add_child(kick_b)


func _refresh_profile_modal() -> void:
	var open := GameStore.show_profile_modal and GameStore.current_screen != "login"
	_profile_modal.visible = open
	if not open:
		_was_profile_modal_open = false
		return

	if not _was_profile_modal_open:
		_was_profile_modal_open = true
		_draft_name = str(GameStore.local_player.get("name", "Người chơi"))
		_draft_outfit = str(GameStore.local_player.get("outfit", "c1"))
		var ca: Variant = GameStore.local_player.get("customAvatar", GameData.DEFAULT_CUSTOM_AVATAR)
		_draft_custom_avatar = (ca as Dictionary).duplicate(true) if ca is Dictionary else GameData.DEFAULT_CUSTOM_AVATAR.duplicate(true)
		_draft_color = str(GameStore.local_player.get("tintColor", "#a78bfa"))
		_draft_room = GameStore.room_code
		_profile_name_input.text = _draft_name
		_profile_room_input.text = _draft_room

	_profile_title.text = "👗 Tùy Chỉnh Nhân Vật & Trang Phục" if GameStore.has_customized_character else "✨ Chào Mừng Đến Cozy Focus Room — Tạo Nhân Vật Của Bạn"
	_profile_close_btn.visible = GameStore.has_customized_character
	_profile_submit_btn.text = "Lưu Thay Đổi 💕" if GameStore.has_customized_character else "Vào Phòng Ngay 💕"
	_refresh_profile_controls()


func _refresh_profile_controls() -> void:
	for sid in _profile_skin_btns.keys():
		var b: Button = _profile_skin_btns[sid]
		var act := (str(sid) == _draft_outfit)
		_style_btn(b, Color("#ec4899", 0.25) if act else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 14, Color("#f472b6") if act else Color(1, 1, 1, 0.1), 1, 6, 6)

	_profile_custom_box.visible = (_draft_outfit == "custom")
	if _profile_custom_box.visible:
		for ctid in _profile_custom_tab_btns.keys():
			var cb: Button = _profile_custom_tab_btns[ctid]
			var act := (str(ctid) == _custom_tab)
			_style_btn(cb, Color("#ec4899") if act else Color(1, 1, 1, 0.08), Color(1, 1, 1, 0.16), 8, Color.TRANSPARENT, 0, 8, 4)
		_rebuild_custom_studio_tab()

	for c_hex in _profile_color_btns.keys():
		var col_b: Button = _profile_color_btns[c_hex]
		var act := (str(c_hex) == _draft_color)
		_style_btn(col_b, Color(c_hex), Color(c_hex).lightened(0.1), 12, Color.WHITE, 2 if act else 0, 0, 0)

	_update_profile_preview()


func _rebuild_custom_studio_tab() -> void:
	for child in _profile_custom_content.get_children():
		_profile_custom_content.remove_child(child)
		child.queue_free()

	if _custom_tab == "hair":
		var f1 := HFlowContainer.new()
		f1.add_theme_constant_override("h_separation", 4)
		f1.add_theme_constant_override("v_separation", 4)
		_profile_custom_content.add_child(f1)
		for hs in GameData.HAIR_STYLES:
			var hid := str(hs["id"])
			var act := (str(_draft_custom_avatar.get("hairStyle", "")) == hid)
			var b := _btn(str(hs["label"]), Color("#ec4899", 0.3) if act else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 8, Color("#f472b6") if act else Color(1, 1, 1, 0.1), 1, 8, 4, 11)
			b.pressed.connect(func():
				_draft_custom_avatar["hairStyle"] = hid
				if GameData.is_sprite_hair_style(hid):
					_draft_custom_avatar["hairColor"] = "original"
				elif str(_draft_custom_avatar.get("hairColor", "")) == "original":
					_draft_custom_avatar["hairColor"] = "#272026"
				_refresh_profile_controls()
			)
			f1.add_child(b)

		var f2 := HFlowContainer.new()
		f2.add_theme_constant_override("h_separation", 5)
		f2.add_theme_constant_override("v_separation", 4)
		_profile_custom_content.add_child(f2)
		f2.add_child(_lbl("Màu tóc:", 10, Color("#94a3b8")))
		for col in GameData.HAIR_COLORS:
			var cstr := str(col)
			var act := (str(_draft_custom_avatar.get("hairColor", "")) == cstr)
			if cstr == "original":
				var ob := _btn("Gốc", Color("#ec4899", 0.3) if act else Color(1, 1, 1, 0.1), Color(1, 1, 1, 0.2), 10, Color.WHITE if act else Color(1, 1, 1, 0.15), 1, 8, 2, 10)
				ob.pressed.connect(func():
					_draft_custom_avatar["hairColor"] = "original"
					_refresh_profile_controls()
				)
				f2.add_child(ob)
			else:
				var sb := _btn("", Color(cstr), Color(cstr).lightened(0.1), 10, Color.WHITE, 2 if act else 0, 0, 0, 10)
				sb.custom_minimum_size = Vector2(20, 20)
				sb.pressed.connect(func():
					_draft_custom_avatar["hairColor"] = cstr
					_refresh_profile_controls()
				)
				f2.add_child(sb)

	elif _custom_tab == "face":
		var f1 := HFlowContainer.new()
		f1.add_theme_constant_override("h_separation", 6)
		_profile_custom_content.add_child(f1)
		f1.add_child(_lbl("Màu da:", 10, Color("#94a3b8")))
		for st in GameData.SKIN_TONES:
			var sc := str(st["color"])
			var act := (str(_draft_custom_avatar.get("skinTone", "")) == sc)
			var sb := _btn("", Color(sc), Color(sc).lightened(0.08), 10, Color.WHITE, 2 if act else 0, 0, 0, 10)
			sb.custom_minimum_size = Vector2(20, 20)
			sb.tooltip_text = str(st["label"])
			sb.pressed.connect(func():
				_draft_custom_avatar["skinTone"] = sc
				_refresh_profile_controls()
			)
			f1.add_child(sb)

		var f2 := HFlowContainer.new()
		f2.add_theme_constant_override("h_separation", 4)
		f2.add_theme_constant_override("v_separation", 4)
		_profile_custom_content.add_child(f2)
		for es in GameData.EYE_STYLES:
			var eid := str(es["id"])
			var act := (str(_draft_custom_avatar.get("eyeStyle", "")) == eid)
			var eb := _btn(str(es["label"]), Color("#ec4899", 0.3) if act else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 8, Color("#f472b6") if act else Color(1, 1, 1, 0.1), 1, 8, 4, 11)
			eb.pressed.connect(func():
				_draft_custom_avatar["eyeStyle"] = eid
				_refresh_profile_controls()
			)
			f2.add_child(eb)
		var blush_on := bool(_draft_custom_avatar.get("blush", true))
		var bb := _btn("Má hồng", Color("#f43f5e", 0.3) if blush_on else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 8, Color("#fb7185") if blush_on else Color(1, 1, 1, 0.1), 1, 8, 4, 11)
		bb.pressed.connect(func():
			_draft_custom_avatar["blush"] = not blush_on
			_refresh_profile_controls()
		)
		f2.add_child(bb)

	elif _custom_tab == "outfit":
		var f1 := HFlowContainer.new()
		f1.add_theme_constant_override("h_separation", 4)
		_profile_custom_content.add_child(f1)
		for ts in GameData.TOP_STYLES:
			var tid := str(ts["id"])
			var act := (str(_draft_custom_avatar.get("topStyle", "")) == tid)
			var tb := _btn(str(ts["label"]), Color("#ec4899", 0.3) if act else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 8, Color("#f472b6") if act else Color(1, 1, 1, 0.1), 1, 8, 4, 11)
			tb.pressed.connect(func():
				_draft_custom_avatar["topStyle"] = tid
				_refresh_profile_controls()
			)
			f1.add_child(tb)

		var f2 := HFlowContainer.new()
		f2.add_theme_constant_override("h_separation", 5)
		_profile_custom_content.add_child(f2)
		f2.add_child(_lbl("Áo:", 10, Color("#94a3b8")))
		for col in GameData.CLOTHING_COLORS:
			var cstr := str(col)
			var act := (str(_draft_custom_avatar.get("topColor", "")) == cstr)
			var cb := _btn("", Color(cstr), Color(cstr).lightened(0.1), 9, Color.WHITE, 2 if act else 0, 0, 0, 9)
			cb.custom_minimum_size = Vector2(18, 18)
			cb.pressed.connect(func():
				_draft_custom_avatar["topColor"] = cstr
				_refresh_profile_controls()
			)
			f2.add_child(cb)

		var f3 := HFlowContainer.new()
		f3.add_theme_constant_override("h_separation", 5)
		_profile_custom_content.add_child(f3)
		f3.add_child(_lbl("Quần:", 10, Color("#94a3b8")))
		for col in GameData.CLOTHING_COLORS:
			var cstr := str(col)
			var act := (str(_draft_custom_avatar.get("bottomColor", "")) == cstr)
			var cb := _btn("", Color(cstr), Color(cstr).lightened(0.1), 9, Color.WHITE, 2 if act else 0, 0, 0, 9)
			cb.custom_minimum_size = Vector2(18, 18)
			cb.pressed.connect(func():
				_draft_custom_avatar["bottomColor"] = cstr
				_refresh_profile_controls()
			)
			f3.add_child(cb)

	elif _custom_tab == "acc":
		var f1 := HFlowContainer.new()
		f1.add_theme_constant_override("h_separation", 4)
		f1.add_theme_constant_override("v_separation", 4)
		_profile_custom_content.add_child(f1)
		for ac in GameData.ACCESSORIES:
			var aid := str(ac["id"])
			var act := (str(_draft_custom_avatar.get("accessory", "none")) == aid)
			var ab := _btn(str(ac["label"]), Color("#ec4899", 0.3) if act else Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12), 8, Color("#f472b6") if act else Color(1, 1, 1, 0.1), 1, 8, 4, 11)
			ab.pressed.connect(func():
				_draft_custom_avatar["accessory"] = aid
				_refresh_profile_controls()
			)
			f1.add_child(ab)


func _randomize_custom_avatar() -> void:
	_draft_custom_avatar = {
		"skinTone": GameData.SKIN_TONES[randi() % GameData.SKIN_TONES.size()]["color"],
		"hairStyle": GameData.HAIR_STYLES[randi() % GameData.HAIR_STYLES.size()]["id"],
		"hairColor": GameData.HAIR_COLORS[randi() % GameData.HAIR_COLORS.size()],
		"eyeStyle": GameData.EYE_STYLES[randi() % GameData.EYE_STYLES.size()]["id"],
		"blush": randf() > 0.3,
		"topStyle": GameData.TOP_STYLES[randi() % GameData.TOP_STYLES.size()]["id"],
		"topColor": GameData.CLOTHING_COLORS[randi() % GameData.CLOTHING_COLORS.size()],
		"bottomColor": GameData.CLOTHING_COLORS[randi() % GameData.CLOTHING_COLORS.size()],
		"shoeColor": GameData.CLOTHING_COLORS[randi() % GameData.CLOTHING_COLORS.size()],
		"accessory": GameData.ACCESSORIES[randi() % GameData.ACCESSORIES.size()]["id"],
	}
	_refresh_profile_controls()


func _on_walk_preview_tick() -> void:
	if not GameStore.show_profile_modal or _preview_tab != "walking":
		return
	_walk_frame = (_walk_frame + 1) % 4
	_update_profile_preview()


func _update_profile_preview() -> void:
	if not GameStore.show_profile_modal:
		return

	for ptid in _profile_preview_tab_btns.keys():
		var b: Button = _profile_preview_tab_btns[ptid]
		var act := (str(ptid) == _preview_tab)
		_style_btn(b, Color("#ec4899") if act else Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.12), 8, Color.TRANSPARENT, 0, 8, 4)

	var clean_name := _draft_name.strip_edges()
	_profile_preview_name.text = clean_name if not clean_name.is_empty() else "Người chơi"
	_profile_preview_badge.add_theme_stylebox_override("panel", _box(Color("#181026", 0.9), 12, Color.from_string(_draft_color, Color("#a78bfa")), 1, 10, 3))

	var facing_info: Dictionary = PREVIEW_FACINGS[_facing_idx]
	_profile_facing_label.text = "Góc: " + str(facing_info["label"])

	var act_type := "idle" if _preview_tab == "walking" else _preview_tab
	var resolved := GameData.resolve_iso_character_frame(_draft_outfit, str(facing_info["id"]), act_type, _preview_tab == "walking", _walk_frame)
	var tex: Texture2D = null
	if _draft_outfit == "custom":
		tex = AvatarRenderer.get_custom_avatar_texture(str(resolved["path"]), _draft_custom_avatar)
	else:
		tex = GameData.get_texture(str(resolved["path"]))

	_profile_preview_tex.texture = tex
	_profile_preview_tex.flip_h = bool(resolved["flipX"])


func _save_profile() -> void:
	var clean_name := _profile_name_input.text.strip_edges()
	if clean_name.is_empty():
		clean_name = "Người chơi"
	GameStore.update_local_profile({
		"name": clean_name,
		"outfit": _draft_outfit,
		"customAvatar": _draft_custom_avatar.duplicate(true),
		"tintColor": _draft_color,
	})
	var clean_room := _profile_room_input.text.strip_edges().to_upper().substr(0, 16)
	if not clean_room.is_empty() and clean_room != GameStore.room_code:
		GameStore.join_room(clean_room)
	GameStore.set_show_profile_modal(false)


func _on_zoom_changed(z: float) -> void:
	_zoom_label.text = "%d%%" % roundi(z * 100.0)


func _on_hover_hint_changed(hint: String) -> void:
	_hover_hint_pill.visible = not hint.is_empty() and GameStore.current_screen == "game"
	_hover_hint_label.text = hint


func _refresh_toast(msg: String) -> void:
	_toast_pill.visible = not msg.is_empty()
	_toast_label.text = msg
