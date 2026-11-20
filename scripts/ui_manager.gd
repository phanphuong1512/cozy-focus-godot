extends CanvasLayer

# ===================================================================
# COZY LO-FI WARM PIXEL THEME PALETTE
# ===================================================================

const COL_BG_VOID: Color = Color("#1b130f")
const COL_PANEL: Color = Color("#2b1f18", 0.96)
const COL_CARD: Color = Color("#36271f", 0.97)
const COL_WELL: Color = Color("#1e1510", 0.94)
const COL_BORDER_DARK: Color = Color("#140c09")
const COL_BORDER_WOOD: Color = Color("#78553d")
const COL_BORDER_LIGHT: Color = Color("#a87b58")
const COL_AMBER: Color = Color("#d9843b")
const COL_AMBER_HOVER: Color = Color("#e89a50")
const COL_AMBER_GLOW: Color = Color("#f4c274")
const COL_CORAL: Color = Color("#c9624f")
const COL_CORAL_HOVER: Color = Color("#da7562")
const COL_SAGE: Color = Color("#69a86d")
const COL_SAGE_GLOW: Color = Color("#88d88c")
const COL_DANGER: Color = Color("#b84a45")
const COL_DANGER_HOVER: Color = Color("#cc5b55")
const COL_TEXT: Color = Color("#f7ebd9")
const COL_TEXT_SUB: Color = Color("#cfb89e")
const COL_TEXT_MUTED: Color = Color("#967e68")
const COL_TEXT_GOLD: Color = Color("#fde09b")
const COL_DIVIDER: Color = Color("#593e2e")
const COL_BTN_WARM: Color = Color("#3c2b21")
const COL_BTN_WARM_HOV: Color = Color("#4f392c")
const COL_BTN_GHOST_HOV: Color = Color("#f7ebd9", 0.12)

const TABS: Array = [
	{"id": "floor", "label": "Sàn & Tường", "icon": "floor"},
	{"id": "workspace", "label": "Góc Học Tập", "icon": "desk"},
	{"id": "living_room", "label": "Phòng Khách", "icon": "sofa"},
	{"id": "decor", "label": "Đồ Để Bàn", "icon": "lamp"},
	{"id": "kitchen", "label": "Nhà Bếp", "icon": "kitchen"},
	{"id": "bathroom", "label": "Phòng Tắm", "icon": "bath"},
]

const FLOOR_BRUSHES: Array = [
	{"id": "W", "label": "Sàn Gỗ Sồi", "color": "#d97706", "desc": "Ấm áp chuẩn Lo-Fi"},
	{"id": "C", "label": "Thảm Chill", "color": "#d9843b", "desc": "Sàn thảm khu ngồi"},
	{"id": "B", "label": "Gạch Men", "color": "#e5d5c3", "desc": "Khu bếp / tắm"},
	{"id": ".", "label": "Xóa Ô Sàn", "color": "#261b15", "desc": "Tạo góc khuyết"},
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

const REACTION_ITEMS: Array = [
	{"code": "❤️", "icon": "react_heart", "label": "Thả tim"},
	{"code": "✨", "icon": "react_star", "label": "Lấp lánh"},
	{"code": "🔥", "icon": "react_fire", "label": "Tập trung cao"},
	{"code": "☕", "icon": "react_coffee", "label": "Cà phê chill"},
	{"code": "👏", "icon": "react_clap", "label": "Vỗ tay"},
	{"code": "💤", "icon": "react_zzz", "label": "Thư giãn"},
]

const TINT_COLORS: Array = ["#e8a856", "#d9735b", "#7fb37c", "#74a8d9", "#c97b97", "#b59ad9"]

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
	{"id": "bgm", "label": "Nhạc Lo-Fi Chill", "icon": "music", "color": "#f4c274"},
	{"id": "rain", "label": "Tiếng Mưa Rơi", "icon": "rain", "color": "#8ec5e8"},
	{"id": "fire", "label": "Lửa Trại Ấm", "icon": "fire", "color": "#e88856"},
	{"id": "keyboard", "label": "Phím Cơ ASMR", "icon": "keyboard", "color": "#cfb89e"},
	{"id": "wind", "label": "Gió Đêm Dịu", "icon": "wind", "color": "#94cfa0"},
]

var room_node: Node2D = null

var _root: Control
var _ui_theme: Theme
var _mono_font: Font
var _pulse_time: float = 0.0

# Screens
var _login_root: Control
var _login_backdrop: _CozyMenuBackdrop
var _lobby_root: Control
var _lobby_backdrop: _CozyMenuBackdrop
var _game_hud: Control

# Login refs
var _login_error_box: PanelContainer
var _login_error_label: Label
var _login_google_btn: Button
var _login_waiting_box: PanelContainer
var _login_wait_dot: Panel
var _login_guest_btn: Button
var _login_guest_form: VBoxContainer
var _login_guest_input: LineEdit
var _show_guest_input: bool = false

# Lobby refs
var _lobby_user_name: Label
var _lobby_user_badge_panel: PanelContainer
var _lobby_user_badge_icon: TextureRect
var _lobby_user_badge: Label
var _lobby_user_sub: Label
var _lobby_user_avatar: TextureRect
var _lobby_online_dot: Panel
var _lobby_general_badge: Label
var _lobby_custom_room_input: LineEdit

# TopBar refs
var _topbar_panel: PanelContainer
var _mini_topbar_panel: PanelContainer
var _mini_status_dot: Panel
var _mini_room_label: Label
var _mini_timer_label: Label
var _mini_pin_btn: Button
var _top_room_pill: PanelContainer
var _top_status_dot: Panel
var _top_crown_icon: TextureRect
var _top_room_label: Label
var _top_conn_label: Label
var _top_count_label: Label
var _top_copy_btn: Button
var _copy_timer: Timer
var _is_copied_flash: bool = false
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

# ChatBar refs
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
var _room_modal_host_badge: PanelContainer
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
var _draft_color: String = "#e8a856"
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

	_copy_timer = Timer.new()
	_copy_timer.wait_time = 1.8
	_copy_timer.one_shot = true
	_copy_timer.timeout.connect(_on_copy_flash_timeout)
	add_child(_copy_timer)

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


func _process(delta: float) -> void:
	_pulse_time += delta
	var pulse_alpha := 0.78 + 0.22 * sin(_pulse_time * 3.8)

	if _login_root != null and _login_root.visible:
		if _login_backdrop != null:
			_login_backdrop.step(delta)
		if _login_wait_dot != null and _login_waiting_box != null and _login_waiting_box.visible:
			_login_wait_dot.modulate.a = pulse_alpha
	elif _lobby_root != null and _lobby_root.visible:
		if _lobby_backdrop != null:
			_lobby_backdrop.step(delta)
		if _lobby_online_dot != null:
			_lobby_online_dot.modulate.a = pulse_alpha
	elif _game_hud != null and _game_hud.visible:
		if _top_status_dot != null and _top_status_dot.visible:
			_top_status_dot.modulate.a = pulse_alpha
		if _mini_status_dot != null and _mini_status_dot.visible:
			_mini_status_dot.modulate.a = pulse_alpha


func bind_room(room: Node2D) -> void:
	room_node = room
	if room_node != null:
		room_node.zoom_changed.connect(_on_zoom_changed)
		room_node.hover_hint_changed.connect(_on_hover_hint_changed)
		if room_node.has_method("get_zoom_ratio"):
			_on_zoom_changed(room_node.get_zoom_ratio())


# ===================================================================
# THEME & TACTILE PIXEL UI PRIMITIVES
# ===================================================================

func _init_theme() -> void:
	_ui_theme = Theme.new()
	if DisplayServer.get_name() != "headless":
		var sf := SystemFont.new()
		sf.font_names = PackedStringArray([
			"SF Pro Rounded",
			"Nunito",
			"Quicksand",
			"Inter",
			"SF Pro Text",
			"Segoe UI",
			"Arial",
		])
		sf.multichannel_signed_distance_field = false
		sf.generate_mipmaps = true
		sf.oversampling = 2.0
		sf.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
		_ui_theme.default_font = sf

		var mf := SystemFont.new()
		mf.font_names = PackedStringArray([
			"JetBrains Mono",
			"SF Mono",
			"Cascadia Mono",
			"Consolas",
			"Menlo",
			"Monaco",
		])
		mf.generate_mipmaps = true
		mf.oversampling = 2.0
		_mono_font = mf
	else:
		_mono_font = ThemeDB.fallback_font
	_ui_theme.default_font_size = 13

	# HSlider warm pixel styling
	_ui_theme.set_stylebox("slider", "HSlider", _px_box(COL_WELL, 2, Color("#4d3629"), 1, 0, 3))
	_ui_theme.set_stylebox("grabber_area", "HSlider", _px_box(COL_AMBER, 2, Color("#784218"), 1, 0, 3))
	_ui_theme.set_stylebox("grabber_area_highlight", "HSlider", _px_box(COL_AMBER_GLOW, 2, Color("#8a4e1e"), 1, 0, 3))
	_ui_theme.set_icon("grabber", "HSlider", _make_slider_grabber(false))
	_ui_theme.set_icon("grabber_highlight", "HSlider", _make_slider_grabber(true))

	# Slim cozy ScrollBar styling
	var sb_track := _px_box(Color("#18100c", 0.72), 3, Color.TRANSPARENT, 0, 4, 4)
	var sb_grab := _px_box(Color("#78553d", 0.85), 3, Color("#a87b58", 0.65), 1, 4, 4)
	var sb_grab_hov := _px_box(COL_AMBER, 3, COL_AMBER_GLOW, 1, 4, 4)
	for cls in ["VScrollBar", "HScrollBar"]:
		_ui_theme.set_stylebox("scroll", cls, sb_track)
		_ui_theme.set_stylebox("scroll_focus", cls, sb_track)
		_ui_theme.set_stylebox("grabber", cls, sb_grab)
		_ui_theme.set_stylebox("grabber_highlight", cls, sb_grab_hov)
		_ui_theme.set_stylebox("grabber_pressed", cls, sb_grab_hov)

	# CheckButton warm palette
	_ui_theme.set_color("font_color", "CheckButton", COL_TEXT)
	_ui_theme.set_color("font_hover_color", "CheckButton", COL_TEXT)
	_ui_theme.set_color("font_pressed_color", "CheckButton", COL_TEXT_GOLD)
	_ui_theme.set_stylebox("focus", "CheckButton", StyleBoxEmpty.new())

	# Tooltip crisp pixel frame
	_ui_theme.set_stylebox("panel", "TooltipPanel", _px_box(Color("#1f1510", 0.97), 4, COL_BORDER_WOOD, 2, 10, 6, 3, 2))
	_ui_theme.set_color("font_color", "TooltipLabel", COL_TEXT)
	_ui_theme.set_font_size("font_size", "TooltipLabel", 12)


func _make_slider_grabber(highlight: bool) -> ImageTexture:
	var w := 14
	var h := 18
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var outline := COL_BORDER_DARK
	var top_c := COL_TEXT_GOLD if highlight else Color("#e6b685")
	var mid_c := COL_AMBER_GLOW if highlight else Color("#c98b55")
	var bot_c := COL_AMBER if highlight else Color("#8f5d38")
	for y in range(h):
		for x in range(w):
			if (x == 0 or x == w - 1) and (y == 0 or y == h - 1):
				continue
			if x == 0 or x == w - 1 or y == 0 or y == h - 1:
				img.set_pixel(x, y, outline)
			elif y <= 3:
				img.set_pixel(x, y, top_c)
			elif y >= h - 4:
				img.set_pixel(x, y, bot_c)
			else:
				img.set_pixel(x, y, mid_c)
	return ImageTexture.create_from_image(img)


func _px_box(bg: Color, radius: int = 5, border: Color = COL_BORDER_WOOD, bw: int = 2, pad_x: int = 12, pad_y: int = 8, bottom_bw: int = -1, shadow_y: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.corner_detail = 1
	sb.anti_aliasing = false
	var effective_bottom := bw if bottom_bw < 0 else bottom_bw
	if bw > 0 or effective_bottom > 0:
		sb.border_color = border
		sb.border_width_left = bw
		sb.border_width_right = bw
		sb.border_width_top = bw
		sb.border_width_bottom = effective_bottom
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	if shadow_y > 0:
		sb.shadow_size = 1
		sb.shadow_offset = Vector2(0, shadow_y)
		sb.shadow_color = Color("#0c0704", 0.55)
	return sb


func _px_panel(bg: Color = COL_PANEL, border: Color = COL_BORDER_WOOD, pad_x: int = 16, pad_y: int = 14, radius: int = 6) -> StyleBoxFlat:
	return _px_box(bg, radius, border, 2, pad_x, pad_y, 4, 3)


func _px_well(bg: Color = COL_WELL, border: Color = Color("#4d3629"), pad_x: int = 10, pad_y: int = 8, radius: int = 4) -> StyleBoxFlat:
	return _px_box(bg, radius, border, 1, pad_x, pad_y, 2, 0)


func _box(bg: Color, radius: int = 5, border: Color = Color.TRANSPARENT, border_w: int = 0, pad_x: int = 12, pad_y: int = 8) -> StyleBoxFlat:
	return _px_box(bg, radius, border, border_w, pad_x, pad_y, border_w, 0)


func _btn(text: String, bg: Color, hover_bg: Color, radius: int = 5, border: Color = Color.TRANSPARENT, border_w: int = 0, pad_x: int = 12, pad_y: int = 6, font_size: int = 12, font_col: Color = COL_TEXT, icon_tex: Texture2D = null, icon_size: int = 16) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var eff_size := maxi(font_size + 1, 11) if font_size <= 13 else font_size
	b.add_theme_font_size_override("font_size", eff_size)
	if icon_tex != null:
		b.icon = icon_tex
		b.add_theme_constant_override("icon_max_width", icon_size)
		b.add_theme_constant_override("h_separation", 6)
	_style_btn(b, bg, hover_bg, radius, border, border_w, pad_x, pad_y, font_col)
	return b


func _style_btn(b: Button, bg: Color, hover_bg: Color, radius: int = 5, border: Color = Color.TRANSPARENT, border_w: int = 0, pad_x: int = 10, pad_y: int = 6, font_col: Color = COL_TEXT) -> void:
	b.add_theme_color_override("font_color", font_col)
	b.add_theme_color_override("font_hover_color", font_col)
	b.add_theme_color_override("font_pressed_color", font_col)
	b.add_theme_color_override("font_disabled_color", COL_TEXT_MUTED)
	var is_solid := bg.a > 0.08
	var eff_bw := border_w if border_w > 0 else (1 if is_solid else 0)
	var eff_border := border if border.a > 0.01 else (COL_BORDER_WOOD if is_solid else Color.TRANSPARENT)
	var bottom_norm := maxi(eff_bw + 1, 3) if is_solid else eff_bw
	var hov_border := eff_border.lightened(0.22) if is_solid else hover_bg
	var press_bg := hover_bg.darkened(0.12)
	b.add_theme_stylebox_override("normal", _px_box(bg, radius, eff_border, eff_bw, pad_x, pad_y, bottom_norm, 0))
	b.add_theme_stylebox_override("hover", _px_box(hover_bg, radius, hov_border, eff_bw, pad_x, pad_y, bottom_norm, 0))
	# Pressed box trims bottom border and shifts top padding down +2 for tactile keycap depth
	var press_sb := _px_box(press_bg, radius, hov_border, eff_bw, pad_x, pad_y, maxi(1, eff_bw) if is_solid else eff_bw, 0)
	if is_solid:
		press_sb.content_margin_top = pad_y + 2
		press_sb.content_margin_bottom = maxi(1, pad_y - 1)
	b.add_theme_stylebox_override("pressed", press_sb)
	b.add_theme_stylebox_override("disabled", _px_box(bg.darkened(0.35) if is_solid else bg, radius, Color("#3a2a21") if is_solid else Color.TRANSPARENT, eff_bw, pad_x, pad_y, eff_bw, 0))


func _icon_btn(icon_tex: Texture2D, tooltip: String, bg: Color, hover_bg: Color, border: Color = Color.TRANSPARENT, size_px: int = 28, icon_size: int = 16) -> Button:
	var b := Button.new()
	b.text = ""
	b.icon = icon_tex
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = Vector2(size_px, size_px)
	b.tooltip_text = tooltip
	b.add_theme_constant_override("icon_max_width", icon_size)
	var bw := 1 if border.a > 0.01 else 0
	var bbot := 2 if bg.a > 0.08 else 0
	var pad := 2 if size_px <= 22 else 4
	b.add_theme_stylebox_override("normal", _px_box(bg, 4, border, bw, pad, pad, bbot, 0))
	b.add_theme_stylebox_override("hover", _px_box(hover_bg, 4, border.lightened(0.2) if bw > 0 else Color.TRANSPARENT, bw, pad, pad, bbot, 0))
	b.add_theme_stylebox_override("pressed", _px_box(hover_bg.darkened(0.1), 4, border.lightened(0.2) if bw > 0 else Color.TRANSPARENT, bw, pad, pad, bw, 0))
	return b


func _make_divider(vertical: bool = true, length: int = 18) -> ColorRect:
	var d := ColorRect.new()
	d.color = COL_DIVIDER
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if vertical:
		d.custom_minimum_size = Vector2(2, length)
		d.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	else:
		d.custom_minimum_size = Vector2(0, 2)
		d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return d


func _make_status_dot(diameter: int = 9) -> Panel:
	var dot := Panel.new()
	dot.custom_minimum_size = Vector2(diameter, diameter)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_status_dot(dot, COL_SAGE_GLOW)
	return dot


func _set_status_dot(dot: Panel, col: Color) -> void:
	if dot == null:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(999)
	sb.corner_detail = 8
	sb.anti_aliasing = true
	sb.set_border_width_all(1)
	sb.border_color = col.lightened(0.35)
	sb.shadow_size = 4
	sb.shadow_color = Color(col.r, col.g, col.b, 0.55)
	sb.shadow_offset = Vector2.ZERO
	dot.add_theme_stylebox_override("panel", sb)


func _make_icon(tex: Texture2D, sz: int = 16) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = tex
	tr.custom_minimum_size = Vector2(sz, sz)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


func _input_box(placeholder: String, max_len: int = 48) -> LineEdit:
	var le := LineEdit.new()
	le.placeholder_text = placeholder
	le.max_length = max_len
	le.add_theme_font_size_override("font_size", 13)
	le.add_theme_color_override("font_color", COL_TEXT)
	le.add_theme_color_override("font_placeholder_color", COL_TEXT_MUTED)
	le.add_theme_color_override("caret_color", COL_AMBER_GLOW)
	le.add_theme_stylebox_override("normal", _px_box(COL_WELL, 4, Color("#4d3629"), 1, 10, 6, 2, 0))
	le.add_theme_stylebox_override("focus", _px_box(Color("#150e0b", 0.98), 4, COL_AMBER_GLOW, 2, 10, 6, 2, 0))
	return le


func _lbl(text: String, size: int = 12, col: Color = COL_TEXT, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	var eff_size := maxi(size + 1, 11) if size <= 13 else size
	l.add_theme_font_size_override("font_size", eff_size)
	l.add_theme_color_override("font_color", col)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _mono_lbl(text: String, size: int = 12, col: Color = COL_TEXT) -> Label:
	var l := _lbl(text, size, col, false)
	if _mono_font != null:
		l.add_theme_font_override("font", _mono_font)
	return l


func _make_badge_pill(text: String, bg: Color, border: Color, text_col: Color, icon_tex: Texture2D = null) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _px_box(bg, 4, border, 1, 8, 3, 2, 0))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 5)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(h)
	if icon_tex != null:
		h.add_child(_make_icon(icon_tex, 13))
	var lbl := _lbl(text, 10, text_col)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(lbl)
	return p


func _set_player_avatar_texture(tr: TextureRect, outfit: String, custom_cfg: Variant) -> void:
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if outfit == "custom":
		var cfg: Dictionary = custom_cfg if custom_cfg is Dictionary else GameData.DEFAULT_CUSTOM_AVATAR
		tr.texture = AvatarRenderer.get_custom_avatar_texture("res://sprites/characters/base/idle_se.png", cfg)
	else:
		var av_path := "res://sprites/characters/%s/avatar.png" % outfit
		var tex := GameData.get_texture(av_path)
		if tex == null:
			tex = GameData.get_texture("res://sprites/characters/c1/avatar.png")
		tr.texture = tex


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

	_login_backdrop = _CozyMenuBackdrop.new()
	_login_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_login_root.add_child(_login_backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_login_root.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(444, 0)
	card.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 28, 26, 8))
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	# Cozy Logo Medallion
	var logo_center := CenterContainer.new()
	vbox.add_child(logo_center)
	var logo_box := PanelContainer.new()
	logo_box.custom_minimum_size = Vector2(68, 68)
	logo_box.add_theme_stylebox_override("panel", _px_box(COL_CARD, 6, COL_AMBER_GLOW, 2, 10, 10, 4, 2))
	logo_center.add_child(logo_box)
	var logo_tex := TextureRect.new()
	logo_tex.texture = GameData.get_texture("res://sprites/character/prop_bunny_heart.png")
	logo_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo_box.add_child(logo_tex)

	var title := _lbl("Cozy Focus Room", 24, Color("#fff3dc"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := _lbl("Không gian co-focus ấm cúng & bài trí phòng cá nhân", 12, COL_TEXT_SUB)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	# Feature highlights inside inset well
	var feat_box := PanelContainer.new()
	feat_box.add_theme_stylebox_override("panel", _px_well(COL_WELL, Color("#4d3629"), 14, 12, 5))
	vbox.add_child(feat_box)
	var feat_v := VBoxContainer.new()
	feat_v.add_theme_constant_override("separation", 8)
	feat_box.add_child(feat_v)

	var feats := [
		{"icon": "home", "tint": COL_AMBER_GLOW, "colored": false, "text": "Phòng cá nhân riêng biệt, tự do bài trí & lát sàn"},
		{"icon": "react_coffee", "tint": COL_TEXT, "colored": true, "text": "Phòng chung #GENERAL học tập & làm việc cùng nhau"},
		{"icon": "timer", "tint": COL_SAGE_GLOW, "colored": false, "text": "Đồng bộ tiến độ Pomodoro và danh sách công việc"},
	]
	for ft in feats:
		var fr := HBoxContainer.new()
		fr.add_theme_constant_override("separation", 10)
		feat_v.add_child(fr)
		var ftex: Texture2D = PixelIcons.get_colored_icon(str(ft["icon"]), 2) if bool(ft["colored"]) else PixelIcons.get_icon(str(ft["icon"]), ft["tint"], 2)
		fr.add_child(_make_icon(ftex, 16))
		var flbl := _lbl(str(ft["text"]), 12, COL_TEXT, true)
		flbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fr.add_child(flbl)

	# Error banner
	_login_error_box = PanelContainer.new()
	_login_error_box.add_theme_stylebox_override("panel", _px_box(Color("#4f1d1a", 0.92), 4, COL_DANGER_HOVER, 1, 12, 8, 2, 0))
	_login_error_box.visible = false
	vbox.add_child(_login_error_box)
	var err_v := VBoxContainer.new()
	err_v.add_theme_constant_override("separation", 6)
	_login_error_box.add_child(err_v)
	_login_error_label = _lbl("", 12, Color("#ffd4cf"), true)
	_login_error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	err_v.add_child(_login_error_label)
	var err_close := _btn("Đóng", Color("#3b1c19"), Color("#522622"), 4, COL_DANGER, 1, 10, 4, 11, Color("#ffd4cf"), PixelIcons.get_icon("close", Color("#ffd4cf"), 2), 12)
	err_close.pressed.connect(func(): GameStore.clear_auth_error())
	err_v.add_child(err_close)

	# Warm parchment Google sign-in button
	_login_google_btn = _btn(
		"Tiếp tục với Google",
		Color("#fbf2e3"),
		Color("#fffaf0"),
		5,
		Color("#b08962"),
		2,
		16,
		10,
		13,
		Color("#261912"),
		PixelIcons.get_colored_icon("google", 2),
		18
	)
	_login_google_btn.pressed.connect(func(): GameStore.start_google_login())
	vbox.add_child(_login_google_btn)

	# Google waiting box
	_login_waiting_box = PanelContainer.new()
	_login_waiting_box.add_theme_stylebox_override("panel", _px_box(Color("#3b281c", 0.95), 5, COL_AMBER, 2, 14, 12, 3, 0))
	_login_waiting_box.visible = false
	vbox.add_child(_login_waiting_box)
	var wait_v := VBoxContainer.new()
	wait_v.add_theme_constant_override("separation", 8)
	_login_waiting_box.add_child(wait_v)
	var w_hdr := HBoxContainer.new()
	w_hdr.alignment = BoxContainer.ALIGNMENT_CENTER
	w_hdr.add_theme_constant_override("separation", 8)
	wait_v.add_child(w_hdr)
	_login_wait_dot = _make_status_dot(9)
	_set_status_dot(_login_wait_dot, COL_AMBER_GLOW)
	w_hdr.add_child(_login_wait_dot)
	w_hdr.add_child(_lbl("Đang mở trình duyệt xác thực Google...", 12, COL_TEXT_GOLD))
	var w2 := _lbl("Sau khi chọn tài khoản Google trên trình duyệt, ứng dụng sẽ tự động đăng nhập.", 11, COL_TEXT_SUB, true)
	w2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wait_v.add_child(w2)
	var cancel_google := _btn("Hủy", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 12, 5, 11, COL_TEXT, PixelIcons.get_icon("close", COL_TEXT_SUB, 2), 12)
	cancel_google.pressed.connect(func(): GameStore.cancel_google_login())
	wait_v.add_child(cancel_google)

	# Horizontal rule divider
	var div_row := HBoxContainer.new()
	div_row.add_theme_constant_override("separation", 10)
	vbox.add_child(div_row)
	var line_l := _make_divider(false)
	line_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	div_row.add_child(line_l)
	div_row.add_child(_lbl("HOẶC", 10, COL_TEXT_MUTED))
	var line_r := _make_divider(false)
	line_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	div_row.add_child(line_r)

	# Guest button
	_login_guest_btn = _btn(
		"Chơi nhanh làm Khách (Không cần Google)",
		COL_BTN_WARM,
		COL_BTN_WARM_HOV,
		5,
		COL_BORDER_WOOD,
		2,
		16,
		10,
		12,
		COL_TEXT,
		PixelIcons.get_icon("user", COL_TEXT_GOLD, 2),
		16
	)
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

	_login_guest_input = _input_box("Nhập tên hiển thị của bạn...", 20)
	_login_guest_input.text = "Khách Chill"
	_login_guest_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_login_guest_input.text_submitted.connect(func(txt: String): GameStore.login_as_guest(txt))
	_login_guest_form.add_child(_login_guest_input)

	var guest_btns := HBoxContainer.new()
	guest_btns.add_theme_constant_override("separation", 8)
	_login_guest_form.add_child(guest_btns)
	var go_btn := _btn("Vào Sảnh", COL_AMBER, COL_AMBER_HOVER, 5, Color("#784218"), 2, 14, 9, 12, Color("#1f130d"), PixelIcons.get_icon("door", Color("#1f130d"), 2), 16)
	go_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go_btn.pressed.connect(func(): GameStore.login_as_guest(_login_guest_input.text))
	guest_btns.add_child(go_btn)
	var cancel_g := _btn("Hủy", COL_BTN_WARM, COL_BTN_WARM_HOV, 5, COL_BORDER_WOOD, 2, 14, 9, 12, COL_TEXT_SUB)
	cancel_g.pressed.connect(func():
		_show_guest_input = false
		_refresh_login()
	)
	guest_btns.add_child(cancel_g)

	var footer := _lbl("Cozy Focus Room v%s  •  Lo-Fi Pomodoro Desktop Companion" % GameStore.app_version, 10, COL_TEXT_MUTED)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(footer)


# ===================================================================
# 2. LOBBY SCREEN
# ===================================================================

func _build_lobby_screen() -> void:
	_lobby_root = Control.new()
	_lobby_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_lobby_root)

	_lobby_backdrop = _CozyMenuBackdrop.new()
	_lobby_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lobby_root.add_child(_lobby_backdrop)

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
	main_v.custom_minimum_size = Vector2(840, 0)
	main_v.add_theme_constant_override("separation", 18)
	center.add_child(main_v)

	# Header user bar
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 18, 12, 6))
	main_v.add_child(header)

	var h_row := HBoxContainer.new()
	h_row.add_theme_constant_override("separation", 12)
	header.add_child(h_row)

	var av_frame := PanelContainer.new()
	av_frame.add_theme_stylebox_override("panel", _px_box(COL_WELL, 5, COL_AMBER_GLOW, 2, 4, 4, 2, 0))
	h_row.add_child(av_frame)
	_lobby_user_avatar = TextureRect.new()
	_lobby_user_avatar.custom_minimum_size = Vector2(40, 40)
	_lobby_user_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lobby_user_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lobby_user_avatar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lobby_user_avatar.texture = GameData.get_texture("res://sprites/characters/c1/avatar.png")
	av_frame.add_child(_lobby_user_avatar)

	var u_info := VBoxContainer.new()
	u_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	u_info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	u_info.add_theme_constant_override("separation", 3)
	h_row.add_child(u_info)
	var u_top := HBoxContainer.new()
	u_top.add_theme_constant_override("separation", 8)
	u_info.add_child(u_top)
	_lobby_user_name = _lbl("Người chơi", 14, Color("#fff3dc"))
	u_top.add_child(_lobby_user_name)

	_lobby_user_badge_panel = PanelContainer.new()
	_lobby_user_badge_panel.add_theme_stylebox_override("panel", _px_box(COL_WELL, 4, COL_BORDER_WOOD, 1, 7, 2, 1, 0))
	u_top.add_child(_lobby_user_badge_panel)
	var ub_h := HBoxContainer.new()
	ub_h.add_theme_constant_override("separation", 4)
	_lobby_user_badge_panel.add_child(ub_h)
	_lobby_user_badge_icon = _make_icon(PixelIcons.get_icon("user", COL_TEXT_SUB, 2), 12)
	ub_h.add_child(_lobby_user_badge_icon)
	_lobby_user_badge = _lbl("Khách", 10, COL_TEXT_SUB)
	ub_h.add_child(_lobby_user_badge)

	_lobby_user_sub = _lbl("", 11, COL_TEXT_MUTED)
	u_info.add_child(_lobby_user_sub)

	var outfit_btn := _btn("Đổi trang phục", COL_BTN_WARM, COL_BTN_WARM_HOV, 5, COL_BORDER_WOOD, 2, 14, 7, 12, COL_TEXT, PixelIcons.get_icon("palette", COL_AMBER_GLOW, 2), 15)
	outfit_btn.pressed.connect(func(): GameStore.set_show_profile_modal(true))
	h_row.add_child(outfit_btn)

	var logout_btn := _btn("Đăng xuất", Color("#4a201d"), Color("#632925"), 5, COL_DANGER, 2, 14, 7, 12, Color("#ffd4cf"), PixelIcons.get_icon("logout", Color("#ffd4cf"), 2), 15)
	logout_btn.pressed.connect(func(): GameStore.logout())
	h_row.add_child(logout_btn)

	# Title hero section
	var title_v := VBoxContainer.new()
	title_v.add_theme_constant_override("separation", 6)
	main_v.add_child(title_v)
	var tag_center := CenterContainer.new()
	title_v.add_child(tag_center)
	tag_center.add_child(_make_badge_pill(
		"Sảnh Chờ Cozy Focus Room",
		Color("#3b281c", 0.95),
		COL_AMBER,
		COL_TEXT_GOLD,
		PixelIcons.get_icon("sparkle", COL_AMBER_GLOW, 2)
	))
	var h1 := _lbl("Chọn không gian học tập & thư giãn", 24, Color("#fff3dc"))
	h1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_v.add_child(h1)
	var h_sub := _lbl("Tham gia phòng chung cùng mọi người hoặc mở căn phòng ấm cúng của riêng bạn", 13, COL_TEXT_SUB)
	h_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_v.add_child(h_sub)

	# Two main interactive cards
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 18)
	main_v.add_child(cards)

	var on_join_gen := func():
		GameStore.set_screen("game")
		GameStore.join_room("GENERAL")

	var on_join_pers := func():
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

	# Card 1: #GENERAL
	var card_gen := PanelContainer.new()
	card_gen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_gen.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var gen_norm := _px_panel(COL_CARD, COL_BORDER_WOOD, 22, 20, 7)
	var gen_hov := _px_panel(Color("#3f2e24"), COL_AMBER_GLOW, 22, 20, 7)
	card_gen.add_theme_stylebox_override("panel", gen_norm)
	card_gen.mouse_entered.connect(func(): card_gen.add_theme_stylebox_override("panel", gen_hov))
	card_gen.mouse_exited.connect(func(): card_gen.add_theme_stylebox_override("panel", gen_norm))
	card_gen.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			on_join_gen.call()
	)
	cards.add_child(card_gen)

	var cv1 := VBoxContainer.new()
	cv1.add_theme_constant_override("separation", 12)
	cv1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_gen.add_child(cv1)

	var c1_top := HBoxContainer.new()
	c1_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv1.add_child(c1_top)
	var c1_med := PanelContainer.new()
	c1_med.custom_minimum_size = Vector2(44, 44)
	c1_med.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c1_med.add_theme_stylebox_override("panel", _px_box(Color("#4f331d"), 5, COL_AMBER_GLOW, 2, 8, 8, 3, 0))
	c1_med.add_child(_make_icon(PixelIcons.get_icon("users", COL_TEXT_GOLD, 2), 22))
	c1_top.add_child(c1_med)
	var sp_c1 := Control.new()
	sp_c1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_c1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c1_top.add_child(sp_c1)

	var online_pill := PanelContainer.new()
	online_pill.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	online_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_pill.add_theme_stylebox_override("panel", _px_box(Color("#1e3623", 0.92), 4, COL_SAGE, 1, 9, 4, 2, 0))
	c1_top.add_child(online_pill)
	var op_h := HBoxContainer.new()
	op_h.add_theme_constant_override("separation", 6)
	op_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_pill.add_child(op_h)
	_lobby_online_dot = _make_status_dot(8)
	_set_status_dot(_lobby_online_dot, COL_SAGE_GLOW)
	op_h.add_child(_lobby_online_dot)
	_lobby_general_badge = _lbl("Trực tuyến", 11, Color("#b6f2b9"))
	_lobby_general_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	op_h.add_child(_lobby_general_badge)

	var c1_title_row := HBoxContainer.new()
	c1_title_row.add_theme_constant_override("separation", 8)
	c1_title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv1.add_child(c1_title_row)
	c1_title_row.add_child(_lbl("Phòng Chung Lo-Fi", 17, Color("#fff3dc")))
	var gen_tag := PanelContainer.new()
	gen_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gen_tag.add_theme_stylebox_override("panel", _px_box(COL_WELL, 3, COL_AMBER, 1, 7, 2, 1, 0))
	var gen_tag_l := _mono_lbl("#GENERAL", 11, COL_TEXT_GOLD)
	gen_tag.add_child(gen_tag_l)
	c1_title_row.add_child(gen_tag)

	var c1_desc := _lbl("Không gian co-focus công cộng học tập và làm việc cùng mọi người. Hỗ trợ Pomodoro đồng bộ toàn phòng và trò chuyện chill.", 12, COL_TEXT_SUB, true)
	c1_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c1_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv1.add_child(c1_desc)

	var btn_gen := _btn("Vào Phòng Chung #GENERAL", COL_AMBER, COL_AMBER_HOVER, 5, Color("#784218"), 2, 16, 11, 13, Color("#1f130d"), PixelIcons.get_icon("door", Color("#1f130d"), 2), 16)
	btn_gen.pressed.connect(on_join_gen)
	cv1.add_child(btn_gen)

	# Card 2: Personal room
	var card_pers := PanelContainer.new()
	card_pers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_pers.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var pers_norm := _px_panel(COL_CARD, COL_BORDER_WOOD, 22, 20, 7)
	var pers_hov := _px_panel(Color("#3f2e24"), COL_CORAL_HOVER, 22, 20, 7)
	card_pers.add_theme_stylebox_override("panel", pers_norm)
	card_pers.mouse_entered.connect(func(): card_pers.add_theme_stylebox_override("panel", pers_hov))
	card_pers.mouse_exited.connect(func(): card_pers.add_theme_stylebox_override("panel", pers_norm))
	card_pers.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			on_join_pers.call()
	)
	cards.add_child(card_pers)

	var cv2 := VBoxContainer.new()
	cv2.add_theme_constant_override("separation", 12)
	cv2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_pers.add_child(cv2)

	var c2_top := HBoxContainer.new()
	c2_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv2.add_child(c2_top)
	var c2_med := PanelContainer.new()
	c2_med.custom_minimum_size = Vector2(44, 44)
	c2_med.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c2_med.add_theme_stylebox_override("panel", _px_box(Color("#4f2822"), 5, COL_CORAL_HOVER, 2, 8, 8, 3, 0))
	c2_med.add_child(_make_icon(PixelIcons.get_icon("home", Color("#ffd8cf"), 2), 22))
	c2_top.add_child(c2_med)
	var sp_c2 := Control.new()
	sp_c2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_c2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c2_top.add_child(sp_c2)
	var priv_pill := _make_badge_pill("Riêng tư  •  14x14", COL_WELL, COL_CORAL, Color("#ffcfc7"))
	priv_pill.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	c2_top.add_child(priv_pill)

	cv2.add_child(_lbl("Phòng Cá Nhân Của Tôi", 17, Color("#fff3dc")))

	var c2_desc := _lbl("Căn phòng 14x14 rộng rãi thuộc sở hữu của riêng bạn. Tự do lát các loại gạch gỗ, đổi màu tường và bài trí tối đa 30 món nội thất theo phong cách riêng.", 12, COL_TEXT_SUB, true)
	c2_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c2_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv2.add_child(c2_desc)

	var btn_pers := _btn("Vào Phòng Cá Nhân Của Tôi", COL_CORAL, COL_CORAL_HOVER, 5, Color("#732c20"), 2, 16, 11, 13, Color("#fff7ed"), PixelIcons.get_icon("sparkle", Color("#fff7ed"), 2), 16)
	btn_pers.pressed.connect(on_join_pers)
	cv2.add_child(btn_pers)

	# Custom Room Join Bar
	var join_bar := PanelContainer.new()
	join_bar.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 16, 12, 6))
	main_v.add_child(join_bar)
	var j_row := HBoxContainer.new()
	j_row.add_theme_constant_override("separation", 10)
	join_bar.add_child(j_row)
	j_row.add_child(_make_icon(PixelIcons.get_icon("hash", COL_AMBER_GLOW, 2), 16))
	var j_lbl := _lbl("Tham gia phòng bạn bè theo mã:", 12, COL_TEXT_SUB)
	j_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	j_row.add_child(j_lbl)
	_lobby_custom_room_input = _input_box("Ví dụ: STUDY123...", 24)
	_lobby_custom_room_input.custom_minimum_size = Vector2(220, 0)
	if _mono_font != null:
		_lobby_custom_room_input.add_theme_font_override("font", _mono_font)
	_lobby_custom_room_input.text_submitted.connect(func(txt: String): _join_custom_lobby_room(txt))
	j_row.add_child(_lobby_custom_room_input)
	var j_btn := _btn("Tham gia", COL_BTN_WARM, COL_BTN_WARM_HOV, 5, COL_BORDER_LIGHT, 2, 16, 8, 12, COL_TEXT, PixelIcons.get_icon("arrow_right", COL_AMBER_GLOW, 2), 14)
	j_btn.pressed.connect(func(): _join_custom_lobby_room(_lobby_custom_room_input.text))
	j_row.add_child(j_btn)

	var foot := _lbl("Cozy Focus Room  •  Phiên bản v%s  •  Không gian học tập Lo-Fi nhẹ nhàng" % GameStore.app_version, 11, COL_TEXT_MUTED)
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
	_topbar_panel.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 10, 6, 6))
	top_center.add_child(_topbar_panel)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	_topbar_panel.add_child(h)

	# 1. Back to Lobby
	var lobby_btn := _btn("Sảnh", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, Color("#593e2e"), 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("home", COL_AMBER_GLOW, 2), 14)
	lobby_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lobby_btn.tooltip_text = "Rời phòng về Sảnh Chờ (Lobby)"
	lobby_btn.pressed.connect(func(): GameStore.leave_room_to_lobby())
	h.add_child(lobby_btn)

	h.add_child(_make_divider(true, 20))

	# 2. Interactive Room Status Pill (PanelContainer — auto-sizes cleanly to room name + player count)
	_top_room_pill = PanelContainer.new()
	_top_room_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var room_norm := _px_box(COL_WELL, 4, Color("#4d3629"), 1, 10, 5, 2, 0)
	var room_hov := _px_box(Color("#38281f"), 4, COL_BORDER_LIGHT, 1, 10, 5, 2, 0)
	_top_room_pill.add_theme_stylebox_override("panel", room_norm)
	_top_room_pill.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_top_room_pill.tooltip_text = "Đổi phòng / Mời bạn bè"
	_top_room_pill.mouse_entered.connect(func(): _top_room_pill.add_theme_stylebox_override("panel", room_hov))
	_top_room_pill.mouse_exited.connect(func(): _top_room_pill.add_theme_stylebox_override("panel", room_norm))
	_top_room_pill.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			GameStore.set_show_room_modal(true)
	)
	h.add_child(_top_room_pill)

	var rb_h := HBoxContainer.new()
	rb_h.add_theme_constant_override("separation", 7)
	rb_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_room_pill.add_child(rb_h)

	_top_status_dot = _make_status_dot(9)
	rb_h.add_child(_top_status_dot)

	_top_crown_icon = _make_icon(PixelIcons.get_colored_icon("crown", 2), 14)
	rb_h.add_child(_top_crown_icon)

	_top_room_label = _mono_lbl("GENERAL", 12, Color("#fff3dc"))
	_top_room_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rb_h.add_child(_top_room_label)

	_top_conn_label = _lbl("Đang kết nối...", 10, COL_AMBER_GLOW)
	_top_conn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rb_h.add_child(_top_conn_label)

	rb_h.add_child(_make_divider(true, 13))
	rb_h.add_child(_make_icon(PixelIcons.get_icon("users", COL_TEXT_SUB, 2), 14))

	_top_count_label = _mono_lbl("1", 11, COL_TEXT_SUB)
	_top_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rb_h.add_child(_top_count_label)

	_top_copy_btn = _icon_btn(PixelIcons.get_icon("copy", COL_TEXT_SUB, 2), "Copy mã phòng để mời bạn", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 28, 15)
	_top_copy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_copy_btn.pressed.connect(func():
		DisplayServer.clipboard_set(GameStore.room_code)
		GameStore.show_toast("Đã copy mã phòng \"%s\"! Gửi cho bạn bè cùng vào nhé." % GameStore.room_code)
		_is_copied_flash = true
		_refresh_copy_button_icon()
		_copy_timer.start()
	)
	h.add_child(_top_copy_btn)

	h.add_child(_make_divider(true, 20))

	# 3. Atmosphere Segmented Control Well
	var atmo_well := PanelContainer.new()
	atmo_well.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	atmo_well.add_theme_stylebox_override("panel", _px_well(COL_WELL, Color("#4d3629"), 3, 2, 4))
	h.add_child(atmo_well)
	var atmo_h := HBoxContainer.new()
	atmo_h.add_theme_constant_override("separation", 2)
	atmo_well.add_child(atmo_h)

	_top_day_btn = _icon_btn(PixelIcons.get_colored_icon("sun", 2), "Ban Ngày", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	_top_day_btn.pressed.connect(func(): GameStore.set_lighting_mode("day"))
	atmo_h.add_child(_top_day_btn)

	_top_sunset_btn = _icon_btn(PixelIcons.get_icon("sunset", COL_TEXT_SUB, 2), "Hoàng Hôn Ấm", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	_top_sunset_btn.pressed.connect(func(): GameStore.set_lighting_mode("sunset"))
	atmo_h.add_child(_top_sunset_btn)

	_top_night_btn = _icon_btn(PixelIcons.get_icon("moon", COL_TEXT_SUB, 2), "Đêm Lo-Fi (Đèn bàn phát sáng)", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	_top_night_btn.pressed.connect(func(): GameStore.set_lighting_mode("night"))
	atmo_h.add_child(_top_night_btn)

	_top_rain_btn = _icon_btn(PixelIcons.get_icon("rain", COL_TEXT_SUB, 2), "Bật/Tắt Mưa rơi", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	_top_rain_btn.pressed.connect(func(): GameStore.toggle_rain())
	atmo_h.add_child(_top_rain_btn)

	h.add_child(_make_divider(true, 20))

	# 4. Workspace & Productivity Tools
	_top_decor_btn = _btn("Decor (B)", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, Color("#593e2e"), 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("brush", COL_AMBER_GLOW, 2), 14)
	_top_decor_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_decor_btn.pressed.connect(func(): GameStore.toggle_build_mode())
	h.add_child(_top_decor_btn)

	_top_focus_btn = _btn("25:00", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, Color("#593e2e"), 1, 10, 5, 11, COL_TEXT_GOLD, PixelIcons.get_icon("timer", COL_AMBER_GLOW, 2), 14)
	_top_focus_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if _mono_font != null:
		_top_focus_btn.add_theme_font_override("font", _mono_font)
	_top_focus_btn.tooltip_text = "Pomodoro & Danh Sách Công Việc"
	_top_focus_btn.pressed.connect(func(): GameStore.set_show_focus_panel(not GameStore.show_focus_panel))
	h.add_child(_top_focus_btn)

	_top_audio_btn = _icon_btn(PixelIcons.get_icon("headphones", COL_AMBER_GLOW, 2), "Bộ trộn nhạc Lo-Fi & Tiếng Mưa", COL_BTN_WARM, COL_BTN_WARM_HOV, Color("#593e2e"), 28, 16)
	_top_audio_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_audio_btn.pressed.connect(func(): GameStore.set_show_audio_mixer(not GameStore.show_audio_mixer))
	h.add_child(_top_audio_btn)

	h.add_child(_make_divider(true, 20))

	# 5. Window Companion Controls
	_top_pin_btn = _icon_btn(PixelIcons.get_icon("pin_off", COL_TEXT_SUB, 2), "Ghim nổi trên màn hình", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 28, 15)
	_top_pin_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_pin_btn.pressed.connect(func(): GameStore.toggle_always_on_top())
	h.add_child(_top_pin_btn)

	var mini_btn := _icon_btn(PixelIcons.get_icon("minimize", COL_TEXT_SUB, 2), "Thu gọn chế độ Mini Widget", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 28, 15)
	mini_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mini_btn.pressed.connect(func(): GameStore.toggle_mini_mode())
	h.add_child(mini_btn)

	_top_full_btn = _icon_btn(PixelIcons.get_icon("fullscreen", COL_TEXT_SUB, 2), "Toàn màn hình / Cửa sổ Retina lớn (F11)", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 28, 15)
	_top_full_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_full_btn.pressed.connect(func(): GameStore.toggle_fullscreen())
	h.add_child(_top_full_btn)


func _build_mini_topbar() -> void:
	_mini_topbar_panel = PanelContainer.new()
	_mini_topbar_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_mini_topbar_panel.offset_left = 8
	_mini_topbar_panel.offset_right = -8
	_mini_topbar_panel.offset_top = 8
	_mini_topbar_panel.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 12, 6, 5))
	_mini_topbar_panel.visible = false
	_game_hud.add_child(_mini_topbar_panel)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	_mini_topbar_panel.add_child(h)

	_mini_status_dot = _make_status_dot(9)
	h.add_child(_mini_status_dot)

	_mini_room_label = _mono_lbl("#GENERAL", 12, COL_TEXT)
	h.add_child(_mini_room_label)

	var timer_pill := PanelContainer.new()
	timer_pill.add_theme_stylebox_override("panel", _px_box(COL_WELL, 4, Color("#4d3629"), 1, 8, 2, 1, 0))
	h.add_child(timer_pill)
	_mini_timer_label = _mono_lbl("25:00", 12, COL_TEXT_GOLD)
	timer_pill.add_child(_mini_timer_label)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(sp)

	var audio_b := _icon_btn(PixelIcons.get_icon("headphones", COL_AMBER_GLOW, 2), "Âm thanh Lo-Fi", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	audio_b.pressed.connect(func(): GameStore.set_show_audio_mixer(not GameStore.show_audio_mixer))
	h.add_child(audio_b)

	_mini_pin_btn = _icon_btn(PixelIcons.get_icon("pin_off", COL_TEXT_SUB, 2), "Ghim nổi cửa sổ", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	_mini_pin_btn.pressed.connect(func(): GameStore.toggle_always_on_top())
	h.add_child(_mini_pin_btn)

	var max_b := _icon_btn(PixelIcons.get_icon("maximize", COL_TEXT_GOLD, 2), "Phóng to lại cửa sổ", COL_AMBER, COL_AMBER_HOVER, Color("#784218"), 26, 15)
	max_b.pressed.connect(func(): GameStore.toggle_mini_mode())
	h.add_child(max_b)


func _build_focus_panel() -> void:
	_focus_panel = PanelContainer.new()
	_focus_panel.anchor_left = 1.0
	_focus_panel.anchor_right = 1.0
	_focus_panel.anchor_top = 0.0
	_focus_panel.anchor_bottom = 0.0
	_focus_panel.offset_left = -284
	_focus_panel.offset_right = -16
	_focus_panel.offset_top = 66
	_focus_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_focus_panel.custom_minimum_size = Vector2(268, 0)
	_focus_panel.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 14, 12, 6))
	_game_hud.add_child(_focus_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_focus_panel.add_child(v)

	# Header
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 6)
	v.add_child(hdr)
	hdr.add_child(_make_icon(PixelIcons.get_icon("timer", COL_AMBER_GLOW, 2), 16))
	hdr.add_child(_lbl("Co-Focus Timer", 13, Color("#fff3dc")))

	var tomo_pill := PanelContainer.new()
	tomo_pill.add_theme_stylebox_override("panel", _px_box(COL_WELL, 4, Color("#5e3628"), 1, 6, 2, 1, 0))
	hdr.add_child(tomo_pill)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 4)
	tomo_pill.add_child(th)
	th.add_child(_make_icon(PixelIcons.get_colored_icon("tomato", 2), 13))
	_focus_pomo_count = _mono_lbl("x0", 10, COL_TEXT_GOLD)
	th.add_child(_focus_pomo_count)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sp)
	var close_b := _icon_btn(PixelIcons.get_icon("close", COL_TEXT_MUTED, 2), "Ẩn bảng Focus", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 24, 13)
	close_b.pressed.connect(func(): GameStore.set_show_focus_panel(false))
	hdr.add_child(close_b)

	# Mode Switcher inside recessed dark-roast well
	var mode_well := PanelContainer.new()
	mode_well.add_theme_stylebox_override("panel", _px_well(COL_WELL, Color("#4d3629"), 3, 3, 4))
	v.add_child(mode_well)
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 4)
	mode_well.add_child(mode_row)
	for m in POMODORO_MODES:
		var mid := str(m["id"])
		var mb := _btn(str(m["label"]), Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, Color.TRANSPARENT, 0, 6, 4, 11, COL_TEXT_SUB)
		mb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mb.pressed.connect(func(): GameStore.switch_pomodoro_mode(mid))
		mode_row.add_child(mb)
		_focus_mode_btns[mid] = mb

	# Recessed Clock card
	var clock_card := PanelContainer.new()
	clock_card.add_theme_stylebox_override("panel", _px_well(COL_WELL, Color("#593e2e"), 12, 12, 5))
	v.add_child(clock_card)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 8)
	clock_card.add_child(cv)

	_focus_time_label = _mono_lbl("25:00", 36, Color("#fff3dc"))
	_focus_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cv.add_child(_focus_time_label)

	_focus_progress = ProgressBar.new()
	_focus_progress.custom_minimum_size = Vector2(0, 8)
	_focus_progress.show_percentage = false
	_focus_progress.add_theme_stylebox_override("background", _px_box(Color("#120b08"), 2, Color("#4d3629"), 1, 0, 0, 1, 0))
	_focus_progress.add_theme_stylebox_override("fill", _px_box(COL_AMBER_GLOW, 2, COL_AMBER, 1, 0, 0, 1, 0))
	cv.add_child(_focus_progress)

	var clk_btns := HBoxContainer.new()
	clk_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	clk_btns.add_theme_constant_override("separation", 8)
	cv.add_child(clk_btns)

	_focus_play_btn = _btn("Bắt đầu", COL_AMBER, COL_AMBER_HOVER, 4, Color("#784218"), 2, 14, 6, 12, Color("#1f130d"), PixelIcons.get_icon("play", Color("#1f130d"), 2), 14)
	_focus_play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_focus_play_btn.pressed.connect(func():
		if bool(GameStore.pomodoro.get("isRunning", false)):
			GameStore.pause_pomodoro()
		else:
			GameStore.start_pomodoro()
	)
	clk_btns.add_child(_focus_play_btn)

	var rst_btn := _icon_btn(PixelIcons.get_icon("reset", COL_TEXT, 2), "Đặt lại đồng hồ", COL_BTN_WARM, COL_BTN_WARM_HOV, COL_BORDER_WOOD, 30, 15)
	rst_btn.pressed.connect(func(): GameStore.reset_pomodoro())
	clk_btns.add_child(rst_btn)

	_focus_sync_btn = _btn("Đồng bộ giờ học phòng", Color("#213b27"), Color("#2c4f34"), 4, COL_SAGE, 1, 10, 5, 10, Color("#b6f2b9"), PixelIcons.get_icon("link", Color("#b6f2b9"), 2), 13)
	_focus_sync_btn.pressed.connect(func(): GameStore.toggle_pomodoro_room_sync())
	cv.add_child(_focus_sync_btn)

	# Stand up button when seated
	_focus_stand_btn = _btn("Đứng dậy (hoặc bấm WASD)", Color("#4d2c22"), Color("#63392c"), 4, COL_CORAL, 1, 10, 6, 11, Color("#ffd8cf"), PixelIcons.get_icon("stand", Color("#ffd8cf"), 2), 14)
	_focus_stand_btn.pressed.connect(func(): GameStore.stand_up())
	_focus_stand_btn.visible = false
	v.add_child(_focus_stand_btn)

	v.add_child(_make_divider(false))

	# Todo section
	var todo_hdr := HBoxContainer.new()
	todo_hdr.add_theme_constant_override("separation", 6)
	v.add_child(todo_hdr)
	todo_hdr.add_child(_make_icon(PixelIcons.get_icon("checklist", COL_AMBER_GLOW, 2), 14))
	todo_hdr.add_child(_lbl("Danh Sách Công Việc", 12, COL_TEXT))
	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	todo_hdr.add_child(sp2)
	_todo_count_label = _mono_lbl("0/0", 10, COL_TEXT_SUB)
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
	var add_b := _icon_btn(PixelIcons.get_icon("plus", Color("#1f130d"), 2), "Thêm công việc", COL_AMBER, COL_AMBER_HOVER, Color("#784218"), 30, 14)
	add_b.pressed.connect(func():
		if not _todo_input.text.strip_edges().is_empty():
			GameStore.add_todo(_todo_input.text)
			_todo_input.text = ""
	)
	add_row.add_child(add_b)

	var todo_scroll := ScrollContainer.new()
	todo_scroll.custom_minimum_size = Vector2(0, 96)
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
	_build_dock.custom_minimum_size = Vector2(840, 0)
	_build_dock.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 14, 12, 6))
	_build_dock.visible = false
	bottom_center.add_child(_build_dock)

	var main_v := VBoxContainer.new()
	main_v.add_theme_constant_override("separation", 10)
	_build_dock.add_child(main_v)

	# Top action row
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 5)
	main_v.add_child(top_row)

	for t in TABS:
		var tid := str(t["id"])
		var icon_name := str(t["icon"])
		var tb := _btn(str(t["label"]), COL_WELL, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 9, 5, 11, COL_TEXT_SUB, PixelIcons.get_icon(icon_name, COL_AMBER_GLOW, 2), 14)
		tb.pressed.connect(func(): GameStore.set_build_tab(tid))
		top_row.add_child(tb)
		_build_tab_btns[tid] = tb

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(sp)

	var cnt_pill := PanelContainer.new()
	cnt_pill.add_theme_stylebox_override("panel", _px_box(COL_WELL, 4, Color("#4d3629"), 1, 8, 4, 1, 0))
	top_row.add_child(cnt_pill)
	_build_count_label = _mono_lbl("Đồ vật: 0", 11, COL_TEXT_SUB)
	cnt_pill.add_child(_build_count_label)

	_build_moving_box = PanelContainer.new()
	_build_moving_box.add_theme_stylebox_override("panel", _px_box(Color("#1f333d"), 4, Color("#569ec4"), 1, 8, 4, 2, 0))
	_build_moving_box.visible = false
	top_row.add_child(_build_moving_box)
	var mov_h := HBoxContainer.new()
	mov_h.add_theme_constant_override("separation", 6)
	_build_moving_box.add_child(mov_h)
	_build_moving_label = _lbl("Đang di chuyển", 11, Color("#d4eeff"))
	mov_h.add_child(_build_moving_label)
	var del_b := _btn("Xóa", COL_DANGER, COL_DANGER_HOVER, 4, Color("#6b2623"), 1, 8, 2, 11, Color("#fff7ed"), PixelIcons.get_icon("trash", Color("#fff7ed"), 2), 13)
	del_b.pressed.connect(func(): GameStore.remove_item(GameStore.moving_item_uid))
	mov_h.add_child(del_b)
	var cancel_m := _icon_btn(PixelIcons.get_icon("close", Color("#d4eeff"), 2), "Hủy di chuyển", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 22, 12)
	cancel_m.pressed.connect(func(): GameStore.start_moving_item(""))
	mov_h.add_child(cancel_m)

	_build_flip_btn = _btn("Xoay (R)", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("rotate", COL_TEXT_SUB, 2), 14)
	_build_flip_btn.pressed.connect(func(): GameStore.toggle_place_flipped())
	top_row.add_child(_build_flip_btn)

	_build_guest_btn = _btn("Khách: Chỉ xem", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("users", COL_TEXT_SUB, 2), 14)
	_build_guest_btn.pressed.connect(func(): GameStore.set_allow_guest_build(not bool(GameStore.layout.get("allowGuestBuild", false))))
	top_row.add_child(_build_guest_btn)

	var done_b := _btn("Xong", COL_AMBER, COL_AMBER_HOVER, 4, Color("#784218"), 2, 12, 5, 11, Color("#1f130d"), PixelIcons.get_icon("check", Color("#1f130d"), 2), 13)
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
		var sw_tex := _make_swatch_icon(Color(str(b["color"])))
		var btn := _btn("%s\n%s" % [str(b["label"]), str(b["desc"])], COL_WELL, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 10, 6, 10, COL_TEXT, sw_tex, 16)
		btn.pressed.connect(func(): GameStore.set_active_floor_brush(bid))
		fl_row1.add_child(btn)
		_build_floor_brush_btns[bid] = btn

	_build_wall_add_btn = _btn("Dựng Tường\nR xoay Trái/Phải", COL_WELL, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 10, 6, 10, COL_TEXT, PixelIcons.get_icon("wall_add", COL_AMBER_GLOW, 2), 16)
	_build_wall_add_btn.pressed.connect(func():
		GameStore.set_active_wall_brush("" if GameStore.active_wall_brush == "add" else "add")
	)
	fl_row1.add_child(_build_wall_add_btn)

	_build_wall_rem_btn = _btn("Xóa Tường\nGỡ vách tường", COL_WELL, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 10, 6, 10, COL_TEXT, PixelIcons.get_icon("wall_del", Color("#ffa196"), 2), 16)
	_build_wall_rem_btn.pressed.connect(func():
		GameStore.set_active_wall_brush("" if GameStore.active_wall_brush == "remove" else "remove")
	)
	fl_row1.add_child(_build_wall_rem_btn)

	var auto_wall_btn := _btn("Auto Bo Tường", Color("#2c3347"), Color("#39425c"), 4, Color("#6b83b5"), 1, 10, 8, 11, Color("#dce7ff"))
	auto_wall_btn.pressed.connect(func(): GameStore.auto_build_walls())
	fl_row1.add_child(auto_wall_btn)

	var sp_fl := Control.new()
	sp_fl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fl_row1.add_child(sp_fl)

	_build_floor_budget_label = _mono_lbl("", 11, COL_TEXT_GOLD)
	fl_row1.add_child(_build_floor_budget_label)
	_build_wall_budget_label = _mono_lbl("", 11, COL_TEXT_SUB)
	fl_row1.add_child(_build_wall_budget_label)

	var fl_row2 := HBoxContainer.new()
	fl_row2.add_theme_constant_override("separation", 8)
	_build_floor_area.add_child(fl_row2)

	for wt in WALL_THEMES:
		var wid := str(wt["id"])
		var wt_tex := _make_swatch_icon(Color(str(wt["color"])))
		var wb := _btn(str(wt["label"]), COL_WELL, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 10, 5, 11, COL_TEXT, wt_tex, 14)
		wb.pressed.connect(func(): GameStore.set_wall_theme(wid))
		fl_row2.add_child(wb)
		_build_wall_theme_btns[wid] = wb

	var sp_fl2 := Control.new()
	sp_fl2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fl_row2.add_child(sp_fl2)

	var exp_b := _btn("+ Rộng", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("expand", COL_AMBER_GLOW, 2), 14)
	exp_b.pressed.connect(func(): GameStore.expand_floor_grid())
	fl_row2.add_child(exp_b)

	var shr_b := _btn("- Gọn", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("shrink", COL_TEXT_SUB, 2), 14)
	shr_b.pressed.connect(func(): GameStore.shrink_floor_grid())
	fl_row2.add_child(shr_b)

	_build_reset_btn = _btn("Phòng Mẫu", Color("#4a201d"), Color("#632925"), 4, COL_DANGER, 1, 10, 5, 11, Color("#ffd4cf"), PixelIcons.get_icon("reset", Color("#ffd4cf"), 2), 14)
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

	main_v.add_child(_lbl("Mẹo: Chọn đồ mục Đồ Để Bàn rồi rê lên mặt Bàn/Quầy để đặt lên! Click đồ có sẵn để di chuyển hoặc xóa.", 10, COL_TEXT_MUTED))


func _make_swatch_icon(col: Color) -> ImageTexture:
	var s := 2
	var img := Image.create(12 * s, 12 * s, false, Image.FORMAT_RGBA8)
	var light := col.lightened(0.22)
	for y in range(12):
		for x in range(12):
			var c := COL_BORDER_DARK if (x == 0 or x == 11 or y == 0 or y == 11) else (light if y <= 2 else col)
			img.fill_rect(Rect2i(x * s, y * s, s, s), c)
	return ImageTexture.create_from_image(img)


func _build_audio_mixer() -> void:
	_audio_modal = PanelContainer.new()
	_audio_modal.position = Vector2(16, 66)
	_audio_modal.custom_minimum_size = Vector2(308, 0)
	_audio_modal.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 16, 14, 6))
	_audio_modal.visible = false
	_game_hud.add_child(_audio_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_audio_modal.add_child(v)

	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	v.add_child(hdr)
	hdr.add_child(_make_icon(PixelIcons.get_icon("headphones", COL_AMBER_GLOW, 2), 16))
	hdr.add_child(_lbl("Âm Thanh Lo-Fi", 14, Color("#fff3dc")))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sp)
	_audio_mute_btn = _icon_btn(PixelIcons.get_icon("volume_on", COL_TEXT, 2), "Tắt / Mở toàn bộ âm thanh", COL_BTN_WARM, COL_BTN_WARM_HOV, COL_BORDER_WOOD, 28, 15)
	_audio_mute_btn.pressed.connect(func(): GameStore.toggle_master_mute())
	hdr.add_child(_audio_mute_btn)
	var close_b := _icon_btn(PixelIcons.get_icon("close", COL_TEXT_MUTED, 2), "Đóng bộ trộn âm thanh", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 14)
	close_b.pressed.connect(func(): GameStore.set_show_audio_mixer(false))
	hdr.add_child(close_b)

	v.add_child(_make_divider(false))

	for ch in AUDIO_CHANNELS:
		var cid := str(ch["id"])
		var ch_col := Color(str(ch["color"]))
		var ch_v := VBoxContainer.new()
		ch_v.add_theme_constant_override("separation", 4)
		v.add_child(ch_v)
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 8)
		ch_v.add_child(r)
		r.add_child(_make_icon(PixelIcons.get_icon(str(ch["icon"]), ch_col, 2), 16))
		r.add_child(_lbl(str(ch["label"]), 12, COL_TEXT))
		var sp2 := Control.new()
		sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(sp2)
		var pct := _mono_lbl("0%", 11, COL_TEXT_SUB)
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

	v.add_child(_lbl("Trộn tiếng mưa rơi, lửa trại và phím cơ cùng nhạc Lo-Fi để tạo không gian tập trung ấm áp.", 10, COL_TEXT_MUTED, true))


func _build_chat_emote_bar() -> void:
	_chat_bar = VBoxContainer.new()
	_chat_bar.anchor_left = 1.0
	_chat_bar.anchor_right = 1.0
	_chat_bar.anchor_top = 1.0
	_chat_bar.anchor_bottom = 1.0
	_chat_bar.offset_left = -450
	_chat_bar.offset_right = -16
	_chat_bar.offset_top = -120
	_chat_bar.offset_bottom = -16
	_chat_bar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_chat_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_chat_bar.alignment = BoxContainer.ALIGNMENT_END
	_chat_bar.add_theme_constant_override("separation", 8)
	_chat_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(_chat_bar)

	# Chat Log Popover
	_chat_log_panel = PanelContainer.new()
	_chat_log_panel.custom_minimum_size = Vector2(340, 190)
	_chat_log_panel.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 12, 10, 6))
	_chat_log_panel.visible = false
	_chat_bar.add_child(_chat_log_panel)
	var cl_v := VBoxContainer.new()
	cl_v.add_theme_constant_override("separation", 6)
	_chat_log_panel.add_child(cl_v)
	var cl_hdr := HBoxContainer.new()
	cl_hdr.add_theme_constant_override("separation", 6)
	cl_v.add_child(cl_hdr)
	cl_hdr.add_child(_make_icon(PixelIcons.get_icon("chat", COL_AMBER_GLOW, 2), 14))
	cl_hdr.add_child(_lbl("Nhật Ký Trò Chuyện", 12, Color("#fff3dc")))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cl_hdr.add_child(sp)
	var cl_close := _icon_btn(PixelIcons.get_icon("close", COL_TEXT_MUTED, 2), "Đóng nhật ký", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 22, 12)
	cl_close.pressed.connect(func():
		_show_chat_log = false
		_chat_log_panel.visible = false
	)
	cl_hdr.add_child(cl_close)
	cl_v.add_child(_make_divider(false))
	var cl_scroll := ScrollContainer.new()
	cl_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cl_v.add_child(cl_scroll)
	_chat_log_vbox = VBoxContainer.new()
	_chat_log_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_log_vbox.add_theme_constant_override("separation", 5)
	cl_scroll.add_child(_chat_log_vbox)

	# Row 1: Sit floor + Pixel Reactions Strip + Profile Pill (uniform 32px height)
	var row1 := HBoxContainer.new()
	row1.alignment = BoxContainer.ALIGNMENT_END
	row1.add_theme_constant_override("separation", 6)
	_chat_bar.add_child(row1)

	_chat_sit_btn = _btn("Ngồi bệt (G)", COL_PANEL, COL_BTN_WARM_HOV, 5, COL_BORDER_WOOD, 2, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("sit", COL_AMBER_GLOW, 2), 15)
	_chat_sit_btn.custom_minimum_size = Vector2(0, 32)
	_chat_sit_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_chat_sit_btn.tooltip_text = "Ngồi bệt thư giãn ngay tại chỗ (Phím G)"
	_chat_sit_btn.pressed.connect(func(): GameStore.sit_on_floor())
	row1.add_child(_chat_sit_btn)

	# Cozy Pixel-Art Reactions Strip (zero OS emojis)
	var react_panel := PanelContainer.new()
	react_panel.custom_minimum_size = Vector2(0, 32)
	react_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	react_panel.add_theme_stylebox_override("panel", _px_box(COL_PANEL, 5, COL_BORDER_WOOD, 2, 6, 2, 3, 1))
	row1.add_child(react_panel)
	var react_h := HBoxContainer.new()
	react_h.add_theme_constant_override("separation", 2)
	react_panel.add_child(react_h)
	for r_item in REACTION_ITEMS:
		var r_code := str(r_item["code"])
		var r_icon := PixelIcons.get_colored_icon(str(r_item["icon"]), 2)
		var rb := _icon_btn(r_icon, str(r_item["label"]), Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 16)
		rb.pressed.connect(func(): GameStore.send_emote(r_code))
		react_h.add_child(rb)

	# Profile Pill (PanelContainer — auto-sizes cleanly to avatar + player name + pixel gear)
	var prof_pill := PanelContainer.new()
	prof_pill.custom_minimum_size = Vector2(0, 32)
	prof_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var prof_norm_box := _px_box(COL_PANEL, 5, COL_BORDER_WOOD, 2, 10, 4, 3, 1)
	var prof_hov_box := _px_box(COL_BTN_WARM_HOV, 5, COL_AMBER_GLOW, 2, 10, 4, 3, 1)
	prof_pill.add_theme_stylebox_override("panel", prof_norm_box)
	prof_pill.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	prof_pill.tooltip_text = "Đổi nhân vật, tên & màu thẻ tên"
	prof_pill.mouse_entered.connect(func(): prof_pill.add_theme_stylebox_override("panel", prof_hov_box))
	prof_pill.mouse_exited.connect(func(): prof_pill.add_theme_stylebox_override("panel", prof_norm_box))
	prof_pill.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			GameStore.set_show_profile_modal(true)
	)

	var pb_h := HBoxContainer.new()
	pb_h.add_theme_constant_override("separation", 7)
	pb_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prof_pill.add_child(pb_h)

	_chat_profile_avatar = TextureRect.new()
	_chat_profile_avatar.custom_minimum_size = Vector2(22, 22)
	_chat_profile_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chat_profile_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chat_profile_avatar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_chat_profile_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pb_h.add_child(_chat_profile_avatar)

	_chat_profile_name = _lbl("Người chơi", 11, COL_TEXT)
	_chat_profile_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pb_h.add_child(_chat_profile_name)

	pb_h.add_child(_make_icon(PixelIcons.get_icon("gear", COL_AMBER_GLOW, 2), 14))

	row1.add_child(prof_pill)

	# Row 2: Single-Border Integrated Chat Pill (seamless borderless LineEdit inside PanelContainer)
	var chat_pill := PanelContainer.new()
	chat_pill.add_theme_stylebox_override("panel", _px_panel(COL_WELL, COL_BORDER_WOOD, 8, 5, 6))
	_chat_bar.add_child(chat_pill)
	var ch_h := HBoxContainer.new()
	ch_h.add_theme_constant_override("separation", 6)
	chat_pill.add_child(ch_h)

	var log_b := _icon_btn(PixelIcons.get_icon("chat", COL_TEXT_SUB, 2), "Mở lịch sử chat", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 28, 15)
	log_b.pressed.connect(func():
		_show_chat_log = not _show_chat_log
		_chat_log_panel.visible = _show_chat_log
	)
	ch_h.add_child(log_b)

	_chat_input = LineEdit.new()
	_chat_input.placeholder_text = "Nhắn gì đó cho cả phòng..."
	_chat_input.max_length = 140
	_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_input.add_theme_font_size_override("font_size", 12)
	_chat_input.add_theme_color_override("font_color", COL_TEXT)
	_chat_input.add_theme_color_override("font_placeholder_color", COL_TEXT_MUTED)
	_chat_input.add_theme_color_override("caret_color", COL_AMBER_GLOW)
	_chat_input.add_theme_stylebox_override("normal", _px_box(Color.TRANSPARENT, 0, Color.TRANSPARENT, 0, 4, 4, 0, 0))
	_chat_input.add_theme_stylebox_override("focus", _px_box(Color.TRANSPARENT, 0, Color.TRANSPARENT, 0, 4, 4, 0, 0))
	_chat_input.text_submitted.connect(func(txt: String): _submit_chat(txt))
	ch_h.add_child(_chat_input)

	var send_b := _icon_btn(PixelIcons.get_icon("send", Color("#1f130d"), 2), "Gửi tin nhắn", COL_AMBER, COL_AMBER_HOVER, Color("#784218"), 28, 15)
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
	_zoom_pill.offset_top = -52
	_zoom_pill.offset_bottom = -16
	_zoom_pill.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 8, 4, 5))
	_game_hud.add_child(_zoom_pill)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 4)
	_zoom_pill.add_child(h)

	var z_out := _icon_btn(PixelIcons.get_icon("minus", COL_AMBER_GLOW, 2), "Thu nhỏ (-10%)", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 14)
	z_out.pressed.connect(func():
		if room_node != null: room_node.zoom_by_ratio(-0.10)
	)
	h.add_child(z_out)

	_zoom_label = _mono_lbl("100%", 11, COL_TEXT)
	_zoom_label.custom_minimum_size = Vector2(44, 0)
	_zoom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_child(_zoom_label)

	var z_in := _icon_btn(PixelIcons.get_icon("plus", COL_AMBER_GLOW, 2), "Phóng to (+10%)", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 14)
	z_in.pressed.connect(func():
		if room_node != null: room_node.zoom_by_ratio(0.10)
	)
	h.add_child(z_in)

	h.add_child(_make_divider(true, 16))

	var rst := _icon_btn(PixelIcons.get_icon("compass", COL_TEXT_SUB, 2), "Đưa camera về giữa (Chuột phải kéo để di chuyển)", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 15)
	rst.pressed.connect(func():
		if room_node != null: room_node.reset_cam()
	)
	h.add_child(rst)


func _build_hover_hint() -> void:
	var wrap := HBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	wrap.offset_top = -112
	wrap.offset_bottom = -80
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(wrap)

	_hover_hint_pill = PanelContainer.new()
	_hover_hint_pill.add_theme_stylebox_override("panel", _px_box(COL_PANEL, 4, COL_AMBER, 2, 14, 5, 3, 1))
	_hover_hint_pill.visible = false
	_hover_hint_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(_hover_hint_pill)

	_hover_hint_label = _lbl("", 12, COL_TEXT)
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
	overlay.color = Color("#0c0704", 0.68)
	_room_modal.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_room_modal.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(450, 0)
	card.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 22, 18, 7))
	center.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.add_child(v)

	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	v.add_child(hdr)
	hdr.add_child(_make_icon(PixelIcons.get_icon("door", COL_AMBER_GLOW, 2), 18))
	hdr.add_child(_lbl("Phòng Multiplayer Co-Focus", 16, Color("#fff3dc")))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sp)
	var close_b := _icon_btn(PixelIcons.get_icon("close", COL_TEXT_MUTED, 2), "Đóng", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 26, 14)
	close_b.pressed.connect(func(): GameStore.set_show_room_modal(false))
	hdr.add_child(close_b)

	var info_box := PanelContainer.new()
	info_box.add_theme_stylebox_override("panel", _px_well(COL_WELL, Color("#4d3629"), 14, 10, 5))
	v.add_child(info_box)
	var info_h := HBoxContainer.new()
	info_h.add_theme_constant_override("separation", 12)
	info_box.add_child(info_h)
	var left_v := VBoxContainer.new()
	left_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_v.add_theme_constant_override("separation", 3)
	info_h.add_child(left_v)
	left_v.add_child(_lbl("Phòng hiện tại", 11, COL_TEXT_MUTED))
	var code_h := HBoxContainer.new()
	code_h.add_theme_constant_override("separation", 8)
	left_v.add_child(code_h)
	_room_modal_code = _mono_lbl("#GENERAL", 18, COL_AMBER_GLOW)
	code_h.add_child(_room_modal_code)
	_room_modal_host_badge = _make_badge_pill("Chủ phòng", Color("#4a3319"), COL_AMBER_GLOW, COL_TEXT_GOLD, PixelIcons.get_colored_icon("crown", 2))
	code_h.add_child(_room_modal_host_badge)

	var right_v := VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 4)
	info_h.add_child(right_v)
	right_v.add_child(_lbl("Thành viên", 11, COL_TEXT_MUTED))
	var cnt_h := HBoxContainer.new()
	cnt_h.add_theme_constant_override("separation", 5)
	right_v.add_child(cnt_h)
	cnt_h.add_child(_make_icon(PixelIcons.get_icon("users", COL_SAGE_GLOW, 2), 14))
	_room_modal_count = _lbl("1 đang online", 13, COL_TEXT)
	cnt_h.add_child(_room_modal_count)

	_room_modal_guest_check = CheckButton.new()
	_room_modal_guest_check.text = "Cho phép khách cùng sửa nhà"
	_room_modal_guest_check.focus_mode = Control.FOCUS_NONE
	_room_modal_guest_check.toggled.connect(func(pressed: bool): GameStore.set_allow_guest_build(pressed))
	v.add_child(_room_modal_guest_check)

	_room_modal_reset_btn = _btn("Khôi phục bài trí phòng mẫu ban đầu", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 10, 6, 12, COL_TEXT_GOLD, PixelIcons.get_icon("reset", COL_AMBER_GLOW, 2), 14)
	_room_modal_reset_btn.pressed.connect(func():
		GameStore.reset_default_room()
		GameStore.set_show_room_modal(false)
	)
	v.add_child(_room_modal_reset_btn)

	v.add_child(_make_divider(false))
	v.add_child(_lbl("Tạo phòng mới hoặc nhập mã phòng để vào chung:", 12, COL_TEXT_SUB))
	var join_h := HBoxContainer.new()
	join_h.add_theme_constant_override("separation", 8)
	v.add_child(join_h)
	_room_modal_input = _input_box("Ví dụ: GENERAL, STUDY24...", 16)
	_room_modal_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _mono_font != null:
		_room_modal_input.add_theme_font_override("font", _mono_font)
	_room_modal_input.text_submitted.connect(func(txt: String):
		if not txt.strip_edges().is_empty():
			GameStore.join_room(txt)
			GameStore.set_show_room_modal(false)
	)
	join_h.add_child(_room_modal_input)
	var go_b := _btn("Vào Phòng", COL_AMBER, COL_AMBER_HOVER, 4, Color("#784218"), 2, 14, 8, 12, Color("#1f130d"))
	go_b.pressed.connect(func():
		if not _room_modal_input.text.strip_edges().is_empty():
			GameStore.join_room(_room_modal_input.text)
			GameStore.set_show_room_modal(false)
	)
	join_h.add_child(go_b)

	v.add_child(_lbl("Người đang trong phòng:", 11, COL_TEXT_MUTED))
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
	overlay.color = Color("#0c0704", 0.74)
	_profile_modal.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_profile_modal.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(750, 0)
	card.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_BORDER_WOOD, 22, 18, 7))
	center.add_child(card)

	var main_v := VBoxContainer.new()
	main_v.add_theme_constant_override("separation", 14)
	card.add_child(main_v)

	# Header
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 10)
	main_v.add_child(hdr)
	hdr.add_child(_make_icon(PixelIcons.get_icon("palette", COL_AMBER_GLOW, 2), 20))
	var hv := VBoxContainer.new()
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hv.add_theme_constant_override("separation", 2)
	hdr.add_child(hv)
	_profile_title = _lbl("Tùy Chỉnh Nhân Vật & Trang Phục", 16, Color("#fff3dc"))
	hv.add_child(_profile_title)
	hv.add_child(_lbl("Chọn nhân vật, xem thử các dáng đi bộ / ngồi gõ phím và đặt tên hiển thị", 11, COL_TEXT_SUB))
	_profile_close_btn = _icon_btn(PixelIcons.get_icon("close", COL_TEXT_MUTED, 2), "Đóng", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 28, 15)
	_profile_close_btn.pressed.connect(func(): GameStore.set_show_profile_modal(false))
	hdr.add_child(_profile_close_btn)

	# Body 2 columns
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 18)
	main_v.add_child(cols)

	# Left column: Cozy Warm Preview Stage
	var stage_panel := PanelContainer.new()
	stage_panel.custom_minimum_size = Vector2(280, 0)
	stage_panel.add_theme_stylebox_override("panel", _px_well(Color("#231812"), COL_BORDER_WOOD, 14, 14, 6))
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
		var b := _btn(str(pt["label"]), COL_BTN_WARM, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 8, 4, 10, COL_TEXT_SUB)
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
	_profile_preview_badge.add_theme_stylebox_override("panel", _px_box(Color("#1b130f", 0.94), 4, COL_AMBER_GLOW, 2, 10, 3, 2, 0))
	nb_center.add_child(_profile_preview_badge)
	_profile_preview_name = _lbl("Người chơi", 11, COL_TEXT)
	_profile_preview_badge.add_child(_profile_preview_name)

	_profile_preview_tex = TextureRect.new()
	_profile_preview_tex.custom_minimum_size = Vector2(150, 176)
	_profile_preview_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_profile_preview_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_profile_preview_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stage_center.add_child(_profile_preview_tex)

	var rot_row := HBoxContainer.new()
	sv.add_child(rot_row)
	_profile_facing_label = _lbl("Góc: Trước Phải (SE)", 11, COL_TEXT_SUB)
	_profile_facing_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rot_row.add_child(_profile_facing_label)
	var rot_b := _btn("Xoay góc", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 10, 5, 11, COL_TEXT, PixelIcons.get_icon("rotate", COL_AMBER_GLOW, 2), 14)
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

	right_v.add_child(_lbl("1. Chọn Nhân Vật Isometric (%d nhân vật):" % GameData.CHARACTER_SKINS.size(), 12, COL_TEXT_SUB))

	var skin_scroll := ScrollContainer.new()
	skin_scroll.custom_minimum_size = Vector2(0, 122)
	right_v.add_child(skin_scroll)
	_profile_skin_grid = GridContainer.new()
	_profile_skin_grid.columns = 4
	_profile_skin_grid.add_theme_constant_override("h_separation", 8)
	_profile_skin_grid.add_theme_constant_override("v_separation", 8)
	skin_scroll.add_child(_profile_skin_grid)

	for skin in GameData.CHARACTER_SKINS:
		var sid := str(skin["id"])
		var sb := _btn("", COL_WELL, COL_BTN_WARM_HOV, 5, Color("#4d3629"), 1, 6, 6, 11)
		sb.custom_minimum_size = Vector2(102, 86)
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
		av.custom_minimum_size = Vector2(50, 50)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		av.texture = GameData.get_texture(str(skin["avatar"]))
		av.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sv_box.add_child(av)
		var sn := _lbl(str(skin["name"]), 11, COL_TEXT)
		sn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sv_box.add_child(sn)
		_profile_skin_grid.add_child(sb)
		_profile_skin_btns[sid] = sb

	# Custom Avatar Creator Studio
	_profile_custom_box = PanelContainer.new()
	_profile_custom_box.add_theme_stylebox_override("panel", _px_well(COL_WELL, COL_AMBER, 10, 10, 5))
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
		var cb := _btn(str(ct["label"]), COL_BTN_WARM, COL_BTN_WARM_HOV, 4, Color("#4d3629"), 1, 8, 4, 11, COL_TEXT_SUB)
		cb.pressed.connect(func():
			_custom_tab = ctid
			_refresh_profile_controls()
		)
		ctab_h.add_child(cb)
		_profile_custom_tab_btns[ctid] = cb

	var sp_c := Control.new()
	sp_c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctab_h.add_child(sp_c)
	var rand_b := _btn("Ngẫu nhiên", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 8, 4, 11, COL_TEXT_GOLD, PixelIcons.get_icon("shuffle", COL_AMBER_GLOW, 2), 13)
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
	nv.add_theme_constant_override("separation", 4)
	form_row.add_child(nv)
	nv.add_child(_lbl("2. Tên hiển thị:", 11, COL_TEXT_SUB))
	_profile_name_input = _input_box("Nhập tên của bạn...", 24)
	_profile_name_input.text_changed.connect(func(txt: String):
		_draft_name = txt
		_update_profile_preview()
	)
	nv.add_child(_profile_name_input)

	var rv := VBoxContainer.new()
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rv.add_theme_constant_override("separation", 4)
	form_row.add_child(rv)
	rv.add_child(_lbl("3. Mã phòng muốn vào:", 11, COL_TEXT_SUB))
	_profile_room_input = _input_box("GENERAL", 16)
	if _mono_font != null:
		_profile_room_input.add_theme_font_override("font", _mono_font)
	rv.add_child(_profile_room_input)

	# Color & Submit row
	var foot_row := HBoxContainer.new()
	foot_row.add_theme_constant_override("separation", 10)
	right_v.add_child(foot_row)

	var col_v := VBoxContainer.new()
	col_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_v.add_theme_constant_override("separation", 4)
	foot_row.add_child(col_v)
	col_v.add_child(_lbl("4. Màu viền thẻ tên:", 11, COL_TEXT_SUB))
	var col_h := HBoxContainer.new()
	col_h.add_theme_constant_override("separation", 6)
	col_v.add_child(col_h)
	for c_hex in TINT_COLORS:
		var ch := str(c_hex)
		var cb := _btn("", Color(ch), Color(ch).lightened(0.1), 4, Color.WHITE, 1, 0, 0, 10)
		cb.custom_minimum_size = Vector2(24, 24)
		cb.pressed.connect(func():
			_draft_color = ch
			_refresh_profile_controls()
		)
		col_h.add_child(cb)
		_profile_color_btns[ch] = cb

	_profile_submit_btn = _btn("Lưu Thay Đổi", COL_AMBER, COL_AMBER_HOVER, 5, Color("#784218"), 2, 20, 10, 13, Color("#1f130d"), PixelIcons.get_icon("check", Color("#1f130d"), 2), 15)
	_profile_submit_btn.pressed.connect(_save_profile)
	foot_row.add_child(_profile_submit_btn)


func _build_toast_banner() -> void:
	var wrap := HBoxContainer.new()
	wrap.set_anchors_preset(Control.PRESET_TOP_WIDE)
	wrap.offset_top = 66
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(wrap)

	_toast_pill = PanelContainer.new()
	_toast_pill.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_AMBER_GLOW, 16, 8, 5))
	_toast_pill.visible = false
	_toast_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(_toast_pill)

	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 8)
	th.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_pill.add_child(th)
	th.add_child(_make_icon(PixelIcons.get_icon("sparkle", COL_AMBER_GLOW, 2), 14))
	_toast_label = _lbl("", 12, COL_TEXT)
	_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	th.add_child(_toast_label)


func _build_embedded_banner() -> void:
	_embedded_banner_btn = _btn(
		"Mở Cửa Sổ Toàn Màn Hình Retina (F11)",
		COL_AMBER,
		COL_AMBER_HOVER,
		5,
		Color("#784218"),
		2,
		14,
		7,
		12,
		Color("#1f130d"),
		PixelIcons.get_icon("fullscreen", Color("#1f130d"), 2),
		14
	)
	_embedded_banner_btn.anchor_left = 0.0
	_embedded_banner_btn.anchor_top = 1.0
	_embedded_banner_btn.anchor_bottom = 1.0
	_embedded_banner_btn.offset_left = 16
	_embedded_banner_btn.offset_bottom = -60
	_embedded_banner_btn.offset_top = -96
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
	_update_banner.offset_left = -336
	_update_banner.offset_right = -16
	_update_banner.offset_bottom = -132
	_update_banner.offset_top = -286
	_update_banner.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_update_banner.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_update_banner.custom_minimum_size = Vector2(320, 0)
	_update_banner.add_theme_stylebox_override("panel", _px_panel(COL_PANEL, COL_AMBER_GLOW, 16, 14, 6))
	_update_banner.visible = false
	_root.add_child(_update_banner)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_update_banner.add_child(v)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	v.add_child(head)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(32, 32)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_theme_stylebox_override("panel", _px_box(COL_AMBER, 4, Color("#784218"), 2, 6, 6, 2, 0))
	head.add_child(badge)
	badge.add_child(_make_icon(PixelIcons.get_icon("sparkle", Color("#1f130d"), 2), 16))

	var title_v := VBoxContainer.new()
	title_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_v.add_theme_constant_override("separation", 2)
	head.add_child(title_v)
	_update_title_label = _lbl("Đã có bản cập nhật mới", 13, Color("#fff3dc"))
	title_v.add_child(_update_title_label)
	title_v.add_child(_lbl("Cập nhật nhanh cho Cozy Focus Room", 10, COL_TEXT_SUB))

	_update_close_btn = _icon_btn(PixelIcons.get_icon("close", COL_TEXT_MUTED, 2), "Bỏ qua bản này", Color.TRANSPARENT, COL_BTN_GHOST_HOV, Color.TRANSPARENT, 24, 13)
	_update_close_btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_update_close_btn.pressed.connect(func(): GameStore.dismiss_update())
	head.add_child(_update_close_btn)

	_update_notes_box = PanelContainer.new()
	_update_notes_box.add_theme_stylebox_override("panel", _px_well(COL_WELL, Color("#4d3629"), 10, 8, 4))
	_update_notes_box.visible = false
	v.add_child(_update_notes_box)

	var notes_scroll := ScrollContainer.new()
	notes_scroll.custom_minimum_size = Vector2(0, 54)
	_update_notes_box.add_child(notes_scroll)

	_update_notes_label = _lbl("", 11, COL_TEXT, true)
	_update_notes_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notes_scroll.add_child(_update_notes_label)

	_update_progress_box = VBoxContainer.new()
	_update_progress_box.add_theme_constant_override("separation", 4)
	_update_progress_box.visible = false
	v.add_child(_update_progress_box)

	_update_progress_label = _lbl("Đang tải bản cập nhật... 0%", 11, COL_TEXT_GOLD)
	_update_progress_box.add_child(_update_progress_label)

	_update_progress_bar = ProgressBar.new()
	_update_progress_bar.min_value = 0.0
	_update_progress_bar.max_value = 100.0
	_update_progress_bar.value = 0.0
	_update_progress_bar.show_percentage = false
	_update_progress_bar.custom_minimum_size = Vector2(0, 8)
	_update_progress_bar.add_theme_stylebox_override("background", _px_box(COL_WELL, 2, Color("#4d3629"), 1, 0, 0, 1, 0))
	_update_progress_bar.add_theme_stylebox_override("fill", _px_box(COL_AMBER_GLOW, 2, COL_AMBER, 1, 0, 0, 1, 0))
	_update_progress_box.add_child(_update_progress_bar)

	_update_error_label = _lbl("", 11, Color("#ffb6ad"), true)
	_update_error_label.visible = false
	v.add_child(_update_error_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 8)
	v.add_child(btn_row)

	_update_later_btn = _btn("Để sau", COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_BORDER_WOOD, 1, 12, 6, 11, COL_TEXT_SUB)
	_update_later_btn.pressed.connect(func(): GameStore.dismiss_update())
	btn_row.add_child(_update_later_btn)

	_update_install_btn = _btn("Cập nhật & Khởi động lại", COL_AMBER, COL_AMBER_HOVER, 4, Color("#784218"), 2, 12, 6, 11, Color("#1f130d"), PixelIcons.get_icon("download", Color("#1f130d"), 2), 14)
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
	_update_install_btn.text = "Đang cài đặt..." if GameStore.update_downloading else "Cập nhật & Khởi động lại"


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
	_lobby_user_badge.text = "Khách" if is_guest else "Google"
	_lobby_user_badge.add_theme_color_override("font_color", COL_TEXT_SUB if is_guest else COL_TEXT_GOLD)
	_lobby_user_badge_icon.texture = PixelIcons.get_icon("user" if is_guest else "shield", COL_TEXT_SUB if is_guest else COL_SAGE_GLOW, 2)
	_lobby_user_badge_panel.add_theme_stylebox_override(
		"panel",
		_px_box(COL_WELL if is_guest else Color("#1e3623"), 4, COL_BORDER_WOOD if is_guest else COL_SAGE, 1, 7, 2, 1, 0)
	)
	_lobby_user_sub.text = "Đang chơi ở chế độ khách" if is_guest else str(u.get("email", ""))

	var outfit := str(GameStore.local_player.get("outfit", "c1"))
	_set_player_avatar_texture(_lobby_user_avatar, outfit, GameStore.local_player.get("customAvatar"))

	if GameStore.general_players_count >= 0:
		_lobby_general_badge.text = "%d online" % GameStore.general_players_count
	else:
		_lobby_general_badge.text = "Trực tuyến"


func _on_copy_flash_timeout() -> void:
	_is_copied_flash = false
	_refresh_copy_button_icon()


func _refresh_copy_button_icon() -> void:
	if _top_copy_btn == null:
		return
	if _is_copied_flash:
		_top_copy_btn.icon = PixelIcons.get_icon("check", COL_SAGE_GLOW, 2)
	else:
		_top_copy_btn.icon = PixelIcons.get_icon("copy", COL_TEXT_SUB, 2)


func _refresh_game_hud() -> void:
	var is_mini := GameStore.mini_mode
	_topbar_panel.visible = not is_mini
	_mini_topbar_panel.visible = is_mini

	var rem := int(GameStore.pomodoro.get("remainingSec", 25 * 60))
	var mins := "%02d" % int(floor(float(rem) / 60.0))
	var secs := "%02d" % (rem % 60)
	var time_str := "%s:%s" % [mins, secs]

	var dot_col := COL_SAGE_GLOW if GameStore.connected else COL_AMBER_GLOW
	_set_status_dot(_top_status_dot, dot_col)
	_set_status_dot(_mini_status_dot, dot_col)
	_top_crown_icon.visible = GameStore.is_host
	_top_room_label.text = GameStore.room_code
	_mini_room_label.text = "#" + GameStore.room_code
	_top_conn_label.visible = not GameStore.connected
	_top_count_label.text = "%d" % GameStore.players.size()
	_mini_timer_label.text = time_str
	_top_focus_btn.text = time_str

	var lmode := str(GameStore.layout.get("lightingMode", "day"))
	_style_btn(_top_day_btn, Color("#594122") if lmode == "day" else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, COL_AMBER_GLOW if lmode == "day" else Color.TRANSPARENT, 1 if lmode == "day" else 0, 4, 4)
	_top_day_btn.icon = PixelIcons.get_colored_icon("sun", 2)

	_style_btn(_top_sunset_btn, Color("#5e3621") if lmode == "sunset" else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, COL_CORAL if lmode == "sunset" else Color.TRANSPARENT, 1 if lmode == "sunset" else 0, 4, 4)
	_top_sunset_btn.icon = PixelIcons.get_icon("sunset", Color("#f4a460") if lmode == "sunset" else COL_TEXT_MUTED, 2)

	_style_btn(_top_night_btn, Color("#2f3552") if lmode == "night" else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, Color("#8aa4d6") if lmode == "night" else Color.TRANSPARENT, 1 if lmode == "night" else 0, 4, 4)
	_top_night_btn.icon = PixelIcons.get_icon("moon", Color("#dbe6ff") if lmode == "night" else COL_TEXT_MUTED, 2)

	var rain := bool(GameStore.layout.get("rainEnabled", false))
	_style_btn(_top_rain_btn, Color("#243f52") if rain else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, Color("#6fb6db") if rain else Color.TRANSPARENT, 1 if rain else 0, 4, 4)
	_top_rain_btn.icon = PixelIcons.get_icon("rain", Color("#bce6ff") if rain else COL_TEXT_MUTED, 2)

	var can_dec := GameStore.can_build()
	_top_decor_btn.text = "Decor (B)"
	_top_decor_btn.icon = PixelIcons.get_icon(
		"brush" if can_dec else "lock",
		Color("#1f130d") if GameStore.build_mode else (COL_AMBER_GLOW if can_dec else COL_TEXT_MUTED),
		2
	)
	_style_btn(
		_top_decor_btn,
		COL_AMBER if GameStore.build_mode else (COL_BTN_WARM if can_dec else COL_WELL),
		COL_AMBER_HOVER if GameStore.build_mode else COL_BTN_WARM_HOV,
		4,
		Color("#784218") if GameStore.build_mode else (Color("#593e2e") if can_dec else Color("#3a2a21")),
		1,
		10,
		5,
		Color("#1f130d") if GameStore.build_mode else (COL_TEXT if can_dec else COL_TEXT_MUTED)
	)

	_style_btn(
		_top_focus_btn,
		Color("#4f331d") if GameStore.show_focus_panel else COL_BTN_WARM,
		COL_BTN_WARM_HOV,
		4,
		COL_AMBER_GLOW if GameStore.show_focus_panel else Color("#593e2e"),
		1,
		10,
		5,
		COL_TEXT_GOLD if GameStore.show_focus_panel else COL_TEXT_SUB
	)
	_style_btn(
		_top_audio_btn,
		Color("#4f331d") if GameStore.show_audio_mixer else COL_BTN_WARM,
		COL_BTN_WARM_HOV,
		4,
		COL_AMBER_GLOW if GameStore.show_audio_mixer else Color("#593e2e"),
		1,
		4,
		4
	)

	_style_btn(_top_pin_btn, Color("#594122") if GameStore.always_on_top else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, COL_AMBER_GLOW if GameStore.always_on_top else Color.TRANSPARENT, 1 if GameStore.always_on_top else 0, 4, 4)
	_top_pin_btn.icon = PixelIcons.get_icon("pin" if GameStore.always_on_top else "pin_off", COL_TEXT_GOLD if GameStore.always_on_top else COL_TEXT_SUB, 2)

	_style_btn(_top_full_btn, Color("#4f331d") if GameStore.is_fullscreen else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, COL_AMBER_GLOW if GameStore.is_fullscreen else Color.TRANSPARENT, 1 if GameStore.is_fullscreen else 0, 4, 4)
	_top_full_btn.icon = PixelIcons.get_icon("fullscreen", COL_TEXT_GOLD if GameStore.is_fullscreen else COL_TEXT_SUB, 2)

	_style_btn(_mini_pin_btn, Color("#594122") if GameStore.always_on_top else Color.TRANSPARENT, COL_BTN_GHOST_HOV, 4, COL_AMBER_GLOW if GameStore.always_on_top else Color.TRANSPARENT, 1 if GameStore.always_on_top else 0, 4, 4)
	_mini_pin_btn.icon = PixelIcons.get_icon("pin" if GameStore.always_on_top else "pin_off", COL_TEXT_GOLD if GameStore.always_on_top else COL_TEXT_SUB, 2)

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
	_top_focus_btn.text = time_str
	_mini_timer_label.text = time_str
	_focus_pomo_count.text = "x%d" % GameStore.completed_pomodoros
	_focus_progress.value = clampf(float(total - rem) / float(total) * 100.0, 0.0, 100.0)

	var pmode := str(GameStore.pomodoro.get("mode", "focus"))
	for mid in _focus_mode_btns.keys():
		var b: Button = _focus_mode_btns[mid]
		var act := (str(mid) == pmode)
		_style_btn(
			b,
			COL_AMBER if act else Color.TRANSPARENT,
			COL_AMBER_HOVER if act else COL_BTN_GHOST_HOV,
			4,
			Color("#784218") if act else Color.TRANSPARENT,
			1 if act else 0,
			6,
			4,
			Color("#1f130d") if act else COL_TEXT_SUB
		)

	var running := bool(GameStore.pomodoro.get("isRunning", false))
	_focus_play_btn.text = "Tạm dừng" if running else "Bắt đầu"
	_focus_play_btn.icon = PixelIcons.get_icon("pause" if running else "play", Color("#1f130d"), 2)
	_style_btn(
		_focus_play_btn,
		COL_AMBER_GLOW if running else COL_AMBER,
		Color("#ffe29e") if running else COL_AMBER_HOVER,
		4,
		Color("#784218"),
		2,
		14,
		6,
		Color("#1f130d")
	)

	var synced := bool(GameStore.pomodoro.get("syncedWithRoom", true))
	_focus_sync_btn.text = "Đang đồng bộ giờ học phòng" if synced else "Chế độ đếm giờ cá nhân"
	_focus_sync_btn.icon = PixelIcons.get_icon("link", Color("#b6f2b9") if synced else COL_TEXT_MUTED, 2)
	_style_btn(
		_focus_sync_btn,
		Color("#213b27") if synced else COL_WELL,
		Color("#2c4f34") if synced else COL_BTN_WARM_HOV,
		4,
		COL_SAGE if synced else Color("#4d3629"),
		1,
		10,
		5,
		Color("#b6f2b9") if synced else COL_TEXT_MUTED
	)

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
	_todo_count_label.text = "%d/%d" % [done_count, GameStore.todos.size()]

	if GameStore.todos.is_empty():
		var empty_lbl := _lbl("Chưa có mục tiêu nào. Thêm 1 việc để ghim lên nhân vật nhé!", 11, COL_TEXT_MUTED, true)
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
			_px_box(
				Color("#422c1d", 0.92) if is_pinned else COL_WELL,
				4,
				COL_AMBER_GLOW if is_pinned else Color("#4d3629"),
				1,
				8,
				5,
				2,
				0
			)
		)
		_todo_list_vbox.add_child(row_panel)

		var rh := HBoxContainer.new()
		rh.add_theme_constant_override("separation", 6)
		row_panel.add_child(rh)

		var chk := _icon_btn(
			PixelIcons.get_icon("check", Color("#162918"), 2) if is_done else null,
			"Đánh dấu hoàn thành",
			COL_SAGE if is_done else Color("#18100c"),
			COL_SAGE_GLOW if is_done else COL_BTN_WARM_HOV,
			COL_SAGE_GLOW if is_done else COL_BORDER_WOOD,
			20,
			12
		)
		chk.pressed.connect(func(): GameStore.toggle_todo(tid))
		rh.add_child(chk)

		var txt := _lbl(str(todo.get("text", "")), 11, COL_TEXT_MUTED if is_done else COL_TEXT)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		txt.tooltip_text = str(todo.get("text", ""))
		rh.add_child(txt)

		var pin_b := _icon_btn(
			PixelIcons.get_icon("pin", COL_TEXT_GOLD if is_pinned else COL_TEXT_MUTED, 2),
			"Ghim lên nhân vật",
			Color("#594122") if is_pinned else Color.TRANSPARENT,
			COL_BTN_GHOST_HOV,
			COL_AMBER_GLOW if is_pinned else Color.TRANSPARENT,
			22,
			13
		)
		pin_b.pressed.connect(func(): GameStore.pin_todo("" if is_pinned else tid))
		rh.add_child(pin_b)

		var del_b := _icon_btn(
			PixelIcons.get_icon("trash", Color("#ffb6ad"), 2),
			"Xóa công việc",
			Color.TRANSPARENT,
			Color("#632925"),
			Color.TRANSPARENT,
			22,
			13
		)
		del_b.pressed.connect(func(): GameStore.delete_todo(tid))
		rh.add_child(del_b)


func _refresh_build_dock() -> void:
	if not GameStore.build_mode:
		return

	for tid in _build_tab_btns.keys():
		var b: Button = _build_tab_btns[tid]
		var act := (str(tid) == GameStore.build_tab)
		_style_btn(
			b,
			COL_AMBER if act else COL_WELL,
			COL_AMBER_HOVER if act else COL_BTN_WARM_HOV,
			4,
			Color("#784218") if act else Color("#4d3629"),
			1,
			9,
			5,
			Color("#1f130d") if act else COL_TEXT_SUB
		)
		for t in TABS:
			if str(t["id"]) == str(tid):
				b.icon = PixelIcons.get_icon(str(t["icon"]), Color("#1f130d") if act else COL_AMBER_GLOW, 2)
				break

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

	_style_btn(
		_build_flip_btn,
		Color("#594122") if GameStore.place_flipped else COL_BTN_WARM,
		COL_BTN_WARM_HOV,
		4,
		COL_AMBER_GLOW if GameStore.place_flipped else COL_BORDER_WOOD,
		1,
		10,
		5,
		COL_TEXT_GOLD if GameStore.place_flipped else COL_TEXT
	)

	_build_guest_btn.visible = GameStore.is_host
	var allow_g := bool(GameStore.layout.get("allowGuestBuild", false))
	_build_guest_btn.text = "Khách: Được sửa" if allow_g else "Khách: Chỉ xem"
	_build_guest_btn.icon = PixelIcons.get_icon("users", Color("#b6f2b9") if allow_g else COL_TEXT_SUB, 2)
	_style_btn(
		_build_guest_btn,
		Color("#213b27") if allow_g else COL_BTN_WARM,
		Color("#2c4f34") if allow_g else COL_BTN_WARM_HOV,
		4,
		COL_SAGE if allow_g else COL_BORDER_WOOD,
		1,
		10,
		5,
		Color("#b6f2b9") if allow_g else COL_TEXT
	)

	var is_floor := (GameStore.build_tab == "floor")
	_build_floor_area.visible = is_floor
	_build_catalog_scroll.visible = not is_floor

	if is_floor:
		for bid in _build_floor_brush_btns.keys():
			var fb: Button = _build_floor_brush_btns[bid]
			var act := (GameStore.active_floor_brush == str(bid))
			_style_btn(fb, Color("#4f331d") if act else COL_WELL, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 2 if act else 1, 10, 6, COL_TEXT_GOLD if act else COL_TEXT)

		_style_btn(_build_wall_add_btn, Color("#4f331d") if GameStore.active_wall_brush == "add" else COL_WELL, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if GameStore.active_wall_brush == "add" else Color("#4d3629"), 2 if GameStore.active_wall_brush == "add" else 1, 10, 6)
		_style_btn(_build_wall_rem_btn, Color("#4f1d1a") if GameStore.active_wall_brush == "remove" else COL_WELL, COL_BTN_WARM_HOV, 4, COL_DANGER_HOVER if GameStore.active_wall_brush == "remove" else Color("#4d3629"), 2 if GameStore.active_wall_brush == "remove" else 1, 10, 6)

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
			var act := (str(wid) == wtheme)
			_style_btn(wb, Color("#4f331d") if act else COL_WELL, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 1, 10, 5, COL_TEXT_GOLD if act else COL_TEXT)
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
			Color("#4f331d") if is_sel else COL_WELL,
			COL_BTN_WARM_HOV,
			5,
			COL_AMBER_GLOW if is_sel else Color("#4d3629"),
			2 if is_sel else 1,
			8,
			8,
			11
		)
		card_btn.custom_minimum_size = Vector2(134, 114)
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

		var fp_lbl := _mono_lbl(GameData.format_footprint_label(cat), 9, COL_TEXT_MUTED)
		fp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cv.add_child(fp_lbl)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = GameData.get_texture(str(cat["sprite"]))
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_child(icon)

		var nm := _lbl(str(cat["name"]), 11, COL_TEXT)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		cv.add_child(nm)

		var badge_txt := "Đặt sàn"
		var badge_col := COL_TEXT_SUB
		if str(cat.get("placement", "")) == "surface":
			badge_txt = "Đặt lên bàn"
			badge_col = Color("#9fd4f5")
		elif str(cat.get("placement", "")) == "wall":
			badge_txt = "Treo tường"
			badge_col = Color("#d8c2ff")
		elif (cat.get("seatSlots", []) as Array).size() > 0:
			badge_txt = "Ngồi Focus"
			badge_col = Color("#b6f2b9")
		elif bool(cat.get("isSurface", false)):
			badge_txt = "Mặt bàn"
			badge_col = COL_TEXT_GOLD
		var blbl := _lbl(badge_txt, 9, badge_col)
		blbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(blbl)


func _refresh_audio_mixer() -> void:
	var muted := bool(GameStore.audio_mixer.get("muted", false))
	_audio_mute_btn.icon = PixelIcons.get_icon("volume_off" if muted else "volume_on", Color("#ffb6ad") if muted else COL_TEXT, 2)
	_style_btn(_audio_mute_btn, Color("#4a201d") if muted else COL_BTN_WARM, Color("#632925") if muted else COL_BTN_WARM_HOV, 4, COL_DANGER if muted else COL_BORDER_WOOD, 1, 4, 4)
	for cid in _audio_sliders.keys():
		var sl: HSlider = _audio_sliders[cid]
		var pct: Label = _audio_pct_labels[cid]
		var val := float(GameStore.audio_mixer.get(cid, 0.0))
		sl.set_value_no_signal(val)
		pct.text = "%d%%" % roundi(val * 100.0)


func _refresh_chat_controls() -> void:
	var is_sitting := str(GameStore.local_player.get("activity", "")) == "sit_floor"
	_chat_sit_btn.text = "Đứng dậy (G)" if is_sitting else "Ngồi bệt (G)"
	_chat_sit_btn.icon = PixelIcons.get_icon("stand" if is_sitting else "sit", Color("#1f130d") if is_sitting else COL_AMBER_GLOW, 2)
	_style_btn(
		_chat_sit_btn,
		COL_AMBER if is_sitting else COL_PANEL,
		COL_AMBER_HOVER if is_sitting else COL_BTN_WARM_HOV,
		5,
		Color("#784218") if is_sitting else COL_BORDER_WOOD,
		2,
		10,
		5,
		Color("#1f130d") if is_sitting else COL_TEXT
	)
	_chat_profile_name.text = str(GameStore.local_player.get("name", "Người chơi"))
	var outfit := str(GameStore.local_player.get("outfit", "c1"))
	_set_player_avatar_texture(_chat_profile_avatar, outfit, GameStore.local_player.get("customAvatar"))


func _refresh_chat_log() -> void:
	for child in _chat_log_vbox.get_children():
		_chat_log_vbox.remove_child(child)
		child.queue_free()
	if GameStore.chat_messages.is_empty():
		_chat_log_vbox.add_child(_lbl("Gửi tin nhắn để hiện bong bóng chat trên đầu nhân vật!", 11, COL_TEXT_MUTED, true))
		return
	for m in GameStore.chat_messages:
		if m is Dictionary:
			var rtb := RichTextLabel.new()
			rtb.fit_content = true
			rtb.scroll_active = false
			rtb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			rtb.add_theme_font_size_override("normal_font_size", 11)
			var sender_col := Color.from_string(str(m.get("tintColor", "#e8a856")), COL_AMBER_GLOW)
			rtb.push_color(sender_col)
			rtb.add_text("%s: " % str(m.get("name", "")))
			rtb.pop()
			rtb.push_color(COL_TEXT)
			rtb.add_text(str(m.get("text", "")))
			rtb.pop()
			_chat_log_vbox.add_child(rtb)


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
	_room_modal_count.text = "%d đang online" % GameStore.players.size()
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
		var bc := Color.from_string(str(p.get("tintColor", "#e8a856")), COL_AMBER_GLOW)
		pill.add_theme_stylebox_override("panel", _px_box(COL_WELL, 4, bc, 1, 10, 4, 2, 0))
		_room_modal_players_flow.add_child(pill)
		var ph := HBoxContainer.new()
		ph.add_theme_constant_override("separation", 6)
		pill.add_child(ph)
		var label_str := str(p.get("name", "Khách"))
		if pid == GameStore.my_player_id:
			label_str += " (Bạn)"
		ph.add_child(_lbl(label_str, 11, COL_TEXT))
		if GameStore.is_host and pid != GameStore.my_player_id:
			var kick_b := _icon_btn(PixelIcons.get_icon("close", Color("#ffb6ad"), 2), "Mời ra khỏi phòng", Color.TRANSPARENT, Color("#632925"), Color.TRANSPARENT, 20, 11)
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
		_draft_color = str(GameStore.local_player.get("tintColor", "#e8a856"))
		_draft_room = GameStore.room_code
		_profile_name_input.text = _draft_name
		_profile_room_input.text = _draft_room

	_profile_title.text = "Tùy Chỉnh Nhân Vật & Trang Phục" if GameStore.has_customized_character else "Chào Mừng Đến Cozy Focus Room — Tạo Nhân Vật"
	_profile_close_btn.visible = GameStore.has_customized_character
	_profile_submit_btn.text = "Lưu Thay Đổi" if GameStore.has_customized_character else "Vào Phòng Ngay"
	_refresh_profile_controls()


func _refresh_profile_controls() -> void:
	for sid in _profile_skin_btns.keys():
		var b: Button = _profile_skin_btns[sid]
		var act := (str(sid) == _draft_outfit)
		_style_btn(b, Color("#4f331d") if act else COL_WELL, COL_BTN_WARM_HOV, 5, COL_AMBER_GLOW if act else Color("#4d3629"), 2 if act else 1, 6, 6)

	_profile_custom_box.visible = (_draft_outfit == "custom")
	if _profile_custom_box.visible:
		for ctid in _profile_custom_tab_btns.keys():
			var cb: Button = _profile_custom_tab_btns[ctid]
			var act := (str(ctid) == _custom_tab)
			_style_btn(cb, COL_AMBER if act else COL_BTN_WARM, COL_AMBER_HOVER if act else COL_BTN_WARM_HOV, 4, Color("#784218") if act else Color("#4d3629"), 1, 8, 4, Color("#1f130d") if act else COL_TEXT_SUB)
		_rebuild_custom_studio_tab()

	for c_hex in _profile_color_btns.keys():
		var col_b: Button = _profile_color_btns[c_hex]
		var act := (str(c_hex) == _draft_color)
		_style_btn(col_b, Color(c_hex), Color(c_hex).lightened(0.1), 4, Color("#fff3dc") if act else COL_BORDER_DARK, 2 if act else 1, 0, 0)

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
			var b := _btn(str(hs["label"]), Color("#4f331d") if act else COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 1, 8, 4, 11, COL_TEXT_GOLD if act else COL_TEXT)
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
		f2.add_child(_lbl("Màu tóc:", 10, COL_TEXT_MUTED))
		for col in GameData.HAIR_COLORS:
			var cstr := str(col)
			var act := (str(_draft_custom_avatar.get("hairColor", "")) == cstr)
			if cstr == "original":
				var ob := _btn("Gốc", Color("#4f331d") if act else COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 1, 8, 2, 10, COL_TEXT_GOLD if act else COL_TEXT)
				ob.pressed.connect(func():
					_draft_custom_avatar["hairColor"] = "original"
					_refresh_profile_controls()
				)
				f2.add_child(ob)
			else:
				var sb := _btn("", Color(cstr), Color(cstr).lightened(0.1), 4, Color("#fff3dc") if act else COL_BORDER_DARK, 2 if act else 1, 0, 0, 10)
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
		f1.add_child(_lbl("Màu da:", 10, COL_TEXT_MUTED))
		for st in GameData.SKIN_TONES:
			var sc := str(st["color"])
			var act := (str(_draft_custom_avatar.get("skinTone", "")) == sc)
			var sb := _btn("", Color(sc), Color(sc).lightened(0.08), 4, Color("#fff3dc") if act else COL_BORDER_DARK, 2 if act else 1, 0, 0, 10)
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
			var eb := _btn(str(es["label"]), Color("#4f331d") if act else COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 1, 8, 4, 11, COL_TEXT_GOLD if act else COL_TEXT)
			eb.pressed.connect(func():
				_draft_custom_avatar["eyeStyle"] = eid
				_refresh_profile_controls()
			)
			f2.add_child(eb)
		var blush_on := bool(_draft_custom_avatar.get("blush", true))
		var bb := _btn("Má hồng", Color("#5c2a24") if blush_on else COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_CORAL_HOVER if blush_on else Color("#4d3629"), 1, 8, 4, 11, Color("#ffd8cf") if blush_on else COL_TEXT)
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
			var tb := _btn(str(ts["label"]), Color("#4f331d") if act else COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 1, 8, 4, 11, COL_TEXT_GOLD if act else COL_TEXT)
			tb.pressed.connect(func():
				_draft_custom_avatar["topStyle"] = tid
				_refresh_profile_controls()
			)
			f1.add_child(tb)

		var f2 := HFlowContainer.new()
		f2.add_theme_constant_override("h_separation", 5)
		_profile_custom_content.add_child(f2)
		f2.add_child(_lbl("Áo:", 10, COL_TEXT_MUTED))
		for col in GameData.CLOTHING_COLORS:
			var cstr := str(col)
			var act := (str(_draft_custom_avatar.get("topColor", "")) == cstr)
			var cb := _btn("", Color(cstr), Color(cstr).lightened(0.1), 4, Color("#fff3dc") if act else COL_BORDER_DARK, 2 if act else 1, 0, 0, 9)
			cb.custom_minimum_size = Vector2(18, 18)
			cb.pressed.connect(func():
				_draft_custom_avatar["topColor"] = cstr
				_refresh_profile_controls()
			)
			f2.add_child(cb)

		var f3 := HFlowContainer.new()
		f3.add_theme_constant_override("h_separation", 5)
		_profile_custom_content.add_child(f3)
		f3.add_child(_lbl("Quần:", 10, COL_TEXT_MUTED))
		for col in GameData.CLOTHING_COLORS:
			var cstr := str(col)
			var act := (str(_draft_custom_avatar.get("bottomColor", "")) == cstr)
			var cb := _btn("", Color(cstr), Color(cstr).lightened(0.1), 4, Color("#fff3dc") if act else COL_BORDER_DARK, 2 if act else 1, 0, 0, 9)
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
			var ab := _btn(str(ac["label"]), Color("#4f331d") if act else COL_BTN_WARM, COL_BTN_WARM_HOV, 4, COL_AMBER_GLOW if act else Color("#4d3629"), 1, 8, 4, 11, COL_TEXT_GOLD if act else COL_TEXT)
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
		_style_btn(b, COL_AMBER if act else COL_BTN_WARM, COL_AMBER_HOVER if act else COL_BTN_WARM_HOV, 4, Color("#784218") if act else Color("#4d3629"), 1, 8, 4, Color("#1f130d") if act else COL_TEXT_SUB)

	var clean_name := _draft_name.strip_edges()
	_profile_preview_name.text = clean_name if not clean_name.is_empty() else "Người chơi"
	_profile_preview_badge.add_theme_stylebox_override("panel", _px_box(Color("#1b130f", 0.94), 4, Color.from_string(_draft_color, COL_AMBER_GLOW), 2, 10, 3, 2, 0))

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


# ===================================================================
# COZY LO-FI PIXEL MENU BACKDROP (Login & Lobby)
# ===================================================================

class _CozyMenuBackdrop extends Control:
	var _motes: Array = []
	var _time: float = 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in range(28):
			_motes.append({
				"rx": fmod(float(i * 37 + 13), 100.0) / 100.0,
				"ry": fmod(float(i * 53 + 7), 100.0) / 100.0,
				"sz": 2.0 if (i % 3 != 0) else 4.0,
				"speed": 0.008 + float(i % 5) * 0.003,
				"phase": float(i) * 0.7,
				"bright": (i % 4 == 0),
			})

	func step(dt: float) -> void:
		_time += dt
		for m in _motes:
			m["ry"] = fmod(float(m["ry"]) - float(m["speed"]) * dt + 1.0, 1.0)
		queue_redraw()

	func _draw() -> void:
		var sz := size
		if sz.x <= 0.0 or sz.y <= 0.0:
			return
		# Deep warm espresso base
		draw_rect(Rect2(Vector2.ZERO, sz), Color("#1a120e"))

		# Subtle cozy pixel grid / wallpaper diamonds (spaced 24px)
		var pat_col := Color("#231813")
		var step_px := 24
		var cols := int(ceil(sz.x / float(step_px)))
		var rows := int(ceil(sz.y / float(step_px)))
		for gy in range(rows):
			var py := float(gy * step_px)
			for gx in range(cols):
				var px := float(gx * step_px) + (12.0 if gy % 2 == 1 else 0.0)
				draw_rect(Rect2(px, py, 2.0, 2.0), pat_col)

		# Soft warm desk-lamp ambient window glows
		draw_circle(Vector2(sz.x * 0.14, sz.y * 0.18), 220.0, Color("#d9843b", 0.055))
		draw_circle(Vector2(sz.x * 0.14, sz.y * 0.18), 115.0, Color("#f4c274", 0.04))
		draw_circle(Vector2(sz.x * 0.86, sz.y * 0.82), 240.0, Color("#c9624f", 0.05))
		draw_circle(Vector2(sz.x * 0.86, sz.y * 0.82), 120.0, Color("#d9843b", 0.035))

		# Drifting warm amber pixel dust motes / fireflies
		for m in _motes:
			var mx := float(m["rx"]) * sz.x + sin(_time * 1.1 + float(m["phase"])) * 10.0
			var my := float(m["ry"]) * sz.y
			var msz := float(m["sz"])
			var alpha := 0.22 + 0.28 * (0.5 + 0.5 * sin(_time * 2.1 + float(m["phase"])))
			var col := Color("#fde09b", alpha) if bool(m["bright"]) else Color("#d9843b", alpha * 0.85)
			draw_rect(Rect2(floor(mx), floor(my), msz, msz), col)
