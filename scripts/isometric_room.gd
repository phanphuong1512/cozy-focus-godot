extends Node2D

signal zoom_changed(zoom_val: float)
signal hover_hint_changed(hint: String)

const BASE_ZOOM: float = 1.215 # 1.35 * 0.90 (100% zoom = 90% of old 1.35x zoom)
var cam_zoom: float = BASE_ZOOM
var cam_pan: Vector2 = Vector2(-45.0, -25.0)
var _current_loaded_room: String = ""

var _pressed_keys: Dictionary = {}
var _has_walk_target: bool = false
var _walk_target: Vector2 = Vector2.ZERO
var _is_panning: bool = false
var _pan_start: Vector2 = Vector2.ZERO
var _is_pointer_down_left: bool = false
var _has_hover_grid: bool = false
var _hover_grid: Dictionary = {"gx": 0.0, "gy": 0.0, "localX": 0.0, "localY": 0.0}
var _hovered_existing_item_uid: String = ""
var _last_preview_emit_ms: int = 0
var _last_step_sfx_ms: int = 0
var _current_hover_hint: String = ""

var _world_container: Node2D
var _backdrop_layer: _BackdropDrawer
var _hover_cursor: _HoverCursorDrawer
var _sort_layer: Node2D
var _light_layer: Node2D
var _night_tint: ColorRect
var _glow_container: Node2D
var _rain_layer: _RainDrawer
var _avatar_ui_layer: _AvatarUiDrawer

var _rendered_items: Array = [] # [{uid, sprite, item, depth}]
var _local_ghost_sprite: Sprite2D
var _remote_ghost_container: Node2D
var _avatar_visuals: Dictionary = {} # id -> {container, sprite, shadow, focus_ring, gx, gy, walk_phase, depth}
var _rain_drops: Array = []

var _last_layout_sig: String = ""
var _last_build_mode: bool = false

var _ui_font: Font


func _ready() -> void:
	_init_font()
	_build_scene_hierarchy()
	_init_rain_drops()
	GameStore.layout_changed.connect(_on_layout_or_state_changed)
	GameStore.state_changed.connect(_on_layout_or_state_changed)
	GameStore.screen_changed.connect(_on_screen_changed)
	_on_screen_changed(GameStore.current_screen)
	_rebuild_static_and_furniture()


func _init_font() -> void:
	if DisplayServer.get_name() == "headless":
		_ui_font = ThemeDB.fallback_font
		return
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
	_ui_font = sf


func _build_scene_hierarchy() -> void:
	_world_container = Node2D.new()
	_world_container.name = "WorldContainer"
	add_child(_world_container)

	_backdrop_layer = _BackdropDrawer.new()
	_backdrop_layer.name = "BackdropLayer"
	_world_container.add_child(_backdrop_layer)

	_hover_cursor = _HoverCursorDrawer.new()
	_hover_cursor.name = "HoverCursor"
	_backdrop_layer.add_child(_hover_cursor)

	_sort_layer = Node2D.new()
	_sort_layer.name = "SortLayer"
	_world_container.add_child(_sort_layer)

	_local_ghost_sprite = Sprite2D.new()
	_local_ghost_sprite.name = "LocalGhostSprite"
	_local_ghost_sprite.centered = false
	_local_ghost_sprite.modulate.a = 0.72
	_local_ghost_sprite.visible = false
	_local_ghost_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_sort_layer.add_child(_local_ghost_sprite)

	_remote_ghost_container = Node2D.new()
	_remote_ghost_container.name = "RemoteGhostContainer"
	_sort_layer.add_child(_remote_ghost_container)

	_light_layer = Node2D.new()
	_light_layer.name = "LightLayer"
	_world_container.add_child(_light_layer)

	_night_tint = ColorRect.new()
	_night_tint.name = "NightTint"
	_night_tint.position = Vector2(-2400.0, -1600.0)
	_night_tint.size = Vector2(4800.0, 3200.0)
	_night_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_night_tint.visible = false
	_light_layer.add_child(_night_tint)

	_glow_container = Node2D.new()
	_glow_container.name = "GlowContainer"
	_light_layer.add_child(_glow_container)

	_rain_layer = _RainDrawer.new()
	_rain_layer.name = "RainLayer"
	_rain_layer.drops = _rain_drops
	_world_container.add_child(_rain_layer)

	_avatar_ui_layer = _AvatarUiDrawer.new()
	_avatar_ui_layer.name = "AvatarUiLayer"
	_avatar_ui_layer.ui_font = _ui_font
	_world_container.add_child(_avatar_ui_layer)


func _init_rain_drops() -> void:
	_rain_drops.clear()
	for i in range(70):
		_rain_drops.append({
			"x": (randf() - 0.5) * 1800.0,
			"y": (randf() - 0.5) * 1100.0,
			"len": 12.0 + randf() * 14.0,
			"speed": 520.0 + randf() * 240.0,
		})
	if _rain_layer != null:
		_rain_layer.drops = _rain_drops


func _on_screen_changed(screen: String) -> void:
	visible = (screen == "game")
	if visible:
		apply_saved_room_zoom()
	else:
		_pressed_keys.clear()
		_has_walk_target = false
		_is_panning = false
		_is_pointer_down_left = false


func _on_layout_or_state_changed() -> void:
	if visible and _current_loaded_room != GameStore.room_code:
		apply_saved_room_zoom()


func get_zoom_ratio() -> float:
	return cam_zoom / BASE_ZOOM


func zoom_by_ratio(delta_ratio: float) -> void:
	var current_ratio := get_zoom_ratio()
	var new_ratio := clampf(snappedf(current_ratio + delta_ratio, 0.05), 0.50, 2.00)
	apply_zoom_ratio(new_ratio, true)


func zoom_by(delta: float) -> void:
	zoom_by_ratio(delta)


func apply_zoom_ratio(new_ratio: float, save_pref: bool = true) -> void:
	var clamped := clampf(snappedf(new_ratio, 0.01), 0.50, 2.00)
	cam_zoom = BASE_ZOOM * clamped
	_update_camera_transform()
	zoom_changed.emit(clamped)
	if save_pref and not GameStore.room_code.is_empty():
		GameStore.set_room_zoom(GameStore.room_code, clamped)


func apply_saved_room_zoom() -> void:
	if GameStore.room_code.is_empty():
		return
	_current_loaded_room = GameStore.room_code
	var saved_ratio := GameStore.get_room_zoom(_current_loaded_room)
	apply_zoom_ratio(saved_ratio, false)


func reset_cam() -> void:
	cam_pan = Vector2(-45.0, -25.0)
	apply_zoom_ratio(1.0, true)


func _set_hover_hint(hint: String) -> void:
	if _current_hover_hint != hint:
		_current_hover_hint = hint
		hover_hint_changed.emit(hint)


func _update_camera_transform() -> void:
	var vp := get_viewport_rect().size
	_world_container.scale = Vector2(cam_zoom, cam_zoom)
	_world_container.position = Vector2(vp.x * 0.5 + cam_pan.x, vp.y * 0.22 + cam_pan.y)


func _to_world_grid(screen_pos: Vector2) -> Dictionary:
	var local_x := (screen_pos.x - _world_container.position.x) / cam_zoom
	var local_y := (screen_pos.y - _world_container.position.y) / cam_zoom
	var g := GameData.screen_to_grid(local_x, local_y)
	return {
		"canvasX": screen_pos.x,
		"canvasY": screen_pos.y,
		"localX": local_x,
		"localY": local_y,
		"gx": g.x,
		"gy": g.y,
	}


func _is_wall_item_left(gx: float, gy: float, flipped: bool) -> bool:
	var ox := maxi(0, int(floor(gx)))
	var oy := maxi(0, int(floor(gy)))
	if ox == 0 and oy > 0:
		return true
	if oy == 0 and ox > 0:
		return false
	return flipped


func _get_wall_item_cells(cat: Dictionary, gx: float, gy: float, flipped: bool) -> Array:
	var fp: Dictionary = cat.get("footprint", {"w": 1, "h": 1})
	var span := maxi(1, int(fp.get("w", 1)))
	var on_left := _is_wall_item_left(gx, gy, flipped)
	var ox := maxi(0, int(floor(gx)))
	var oy := maxi(0, int(floor(gy)))
	var cells: Array = []
	for i in range(span):
		if on_left:
			cells.append({"gx": ox, "gy": oy + i, "onLeftWall": true})
		else:
			cells.append({"gx": ox + i, "gy": oy, "onLeftWall": false})
	return cells


func _compute_sprite_placement(cat: Dictionary, gx: float, gy: float, flipped: bool, layer: String, elevation_px: float) -> Dictionary:
	if layer == "floor":
		var m := GameData.get_footprint_screen_metrics(cat, gx, gy, flipped)
		return {
			"x": float(m["spriteX"]),
			"y": float(m["spriteY"]) - elevation_px,
			"depth": float(m["depthScore"]),
		}
	if layer == "wall":
		var fp: Dictionary = cat.get("footprint", {"w": 1, "h": 1})
		var span := maxi(1, int(fp.get("w", 1)))
		var on_left := _is_wall_item_left(gx, gy, flipped)
		var ox := maxi(0, int(floor(gx)))
		var oy := maxi(0, int(floor(gy)))
		var anchor_gx := (float(ox) + 0.08) if on_left else (float(ox) + float(span) * 0.5)
		var anchor_gy := (float(oy) + float(span) * 0.5) if on_left else (float(oy) + 0.08)
		var pos := GameData.grid_to_screen(anchor_gx, anchor_gy)
		var wall_elev := elevation_px if elevation_px != 0.0 else float(cat.get("wallElevationPx", 75.0))
		return {
			"x": pos.x,
			"y": pos.y - wall_elev,
			"depth": (anchor_gx + anchor_gy) * 100.0 - 5.0,
		}
	var pos := GameData.grid_to_screen(gx, gy)
	return {
		"x": pos.x,
		"y": pos.y - elevation_px,
		"depth": (gx + gy) * 100.0,
	}


func _is_tile_walkable(gx: float, gy: float) -> bool:
	var floor_map: Array = GameStore.layout.get("floorMap", [])
	var iy := int(floor(gy))
	var ix := int(floor(gx))
	if iy < 0 or iy >= floor_map.size():
		return false
	var row := str(floor_map[iy])
	if ix < 0 or ix >= row.length():
		return false
	return row[ix] != "."


func _find_surface_at_grid(gx: float, gy: float) -> Dictionary:
	var items: Array = GameStore.layout.get("items", [])
	var cell_x := int(floor(gx))
	var cell_y := int(floor(gy))
	var best: Dictionary = {}
	var best_depth := -INF

	for item in items:
		if not (item is Dictionary):
			continue
		var cat := GameData.get_catalog_item(str(item.get("catalogId", "")))
		if cat.is_empty() or not bool(cat.get("isSurface", false)) or str(item.get("layer", "")) != "floor":
			continue
		var occupied := GameData.get_item_occupied_cells(cat, float(item.get("gx", 0.0)), float(item.get("gy", 0.0)), bool(item.get("flipped", false)))
		var matches := false
		for c in occupied:
			if int(c["gx"]) == cell_x and int(c["gy"]) == cell_y:
				matches = true
				break
		if matches:
			var depth := (float(item.get("gx", 0.0)) + float(item.get("gy", 0.0))) * 100.0
			if depth >= best_depth:
				best_depth = depth
				best = item
	return best


func _pick_wall_cell_at_local(local_x: float, local_y: float) -> Dictionary:
	var floor_map: Array = GameStore.layout.get("floorMap", [])
	var h_rows := floor_map.size()
	var w_cols := 0
	for r in floor_map:
		w_cols = maxi(w_cols, str(r).length())
	var row_h := GameData.WALL_HEIGHT / 3.0

	var candidates: Array = []
	if GameStore.layout.has("walls") and GameStore.layout["walls"] is Array:
		for w_key_val in GameStore.layout["walls"]:
			var w_key := str(w_key_val)
			var parts := w_key.split(":")
			if parts.size() < 2:
				continue
			var coords := parts[1].split(",")
			if coords.size() < 2:
				continue
			candidates.append({
				"gx": int(coords[0]),
				"gy": int(coords[1]),
				"isLeft": parts[0] == "L",
			})
	else:
		for gy in range(h_rows):
			candidates.append({"gx": 0, "gy": gy, "isLeft": true})
		for gx in range(w_cols):
			candidates.append({"gx": gx, "gy": 0, "isLeft": false})

	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (int(a["gx"]) + int(a["gy"])) > (int(b["gx"]) + int(b["gy"]))
	)

	for seg in candidates:
		var sx := float(seg["gx"])
		var sy := float(seg["gy"])
		var is_left := bool(seg["isLeft"])
		var p0 := GameData.grid_to_screen(sx, sy)
		var p1 := GameData.grid_to_screen(sx, sy + 1.0) if is_left else GameData.grid_to_screen(sx + 1.0, sy)
		var min_x := minf(p0.x, p1.x)
		var max_x := maxf(p0.x, p1.x)
		if local_x < min_x or local_x > max_x:
			continue
		var span_x := p1.x - p0.x
		var t := (local_x - p0.x) / span_x if span_x != 0.0 else 0.5
		var base_y := p0.y + t * (p1.y - p0.y)
		var height := base_y - local_y
		if height >= 0.0 and height <= GameData.WALL_HEIGHT:
			var row_idx := clampi(int(floor(height / row_h)), 0, 2)
			return {"gx": int(seg["gx"]), "gy": int(seg["gy"]), "isLeft": is_left, "rowIdx": row_idx}
	return {}


func _compute_placement_target(gx: float, gy: float, catalog_id: String, flipped: bool, local_x: float, local_y: float) -> Dictionary:
	var cat := GameData.get_catalog_item(catalog_id)
	if cat.is_empty():
		return {}
	var floor_map: Array = GameStore.layout.get("floorMap", [])
	var h_rows := floor_map.size()
	var w_cols := 0
	for r in floor_map:
		w_cols = maxi(w_cols, str(r).length())

	var placement := str(cat.get("placement", "floor"))
	if placement == "surface":
		var surface := _find_surface_at_grid(gx, gy)
		var snap_gx := roundf(gx * 4.0) / 4.0
		var snap_gy := roundf(gy * 4.0) / 4.0
		if not surface.is_empty():
			var surface_cat := GameData.get_catalog_item(str(surface.get("catalogId", "")))
			return {
				"gx": snap_gx,
				"gy": snap_gy,
				"flipped": flipped,
				"layer": "surface",
				"parentSurfaceUid": str(surface.get("uid", "")),
				"elevationPx": float(surface_cat.get("surfaceHeightPx", 40.0)),
				"valid": true,
				"hint": "✨ Đặt lên mặt %s" % str(surface_cat.get("name", "bàn")),
				"cells": [{"gx": int(floor(snap_gx)), "gy": int(floor(snap_gy)), "valid": true}],
			}
		var cell_x := int(floor(snap_gx))
		var cell_y := int(floor(snap_gy))
		var in_bounds := (
			snap_gx >= 0.3
			and snap_gx <= float(w_cols) - 0.3
			and snap_gy >= 0.3
			and snap_gy <= float(h_rows) - 0.3
			and _is_tile_walkable(float(cell_x), float(cell_y))
		)
		return {
			"gx": snap_gx,
			"gy": snap_gy,
			"flipped": flipped,
			"layer": "floor",
			"parentSurfaceUid": "",
			"elevationPx": 0.0,
			"valid": in_bounds,
			"hint": "Đặt trên sàn (rê lên bàn / quầy để đặt lên mặt bàn)" if in_bounds else "Ngoài phạm vi phòng",
			"cells": [{"gx": cell_x, "gy": cell_y, "valid": in_bounds}],
		}

	if placement == "wall":
		var fp: Dictionary = cat.get("footprint", {"w": 1, "h": 1})
		var span := maxi(1, int(fp.get("w", 1)))
		var row_h := GameData.WALL_HEIGHT / 3.0
		var base_span: Dictionary = cat.get("wallRowSpan", {"start": 1, "end": 1})
		var row_count := maxi(1, int(base_span.get("end", 1)) - int(base_span.get("start", 1)) + 1)

		var hit_wall := _pick_wall_cell_at_local(local_x, local_y)
		if not hit_wall.is_empty():
			var has_custom_walls := GameStore.layout.has("walls") and GameStore.layout["walls"] is Array
			var wall_set: Dictionary = {}
			if has_custom_walls:
				for wk in GameStore.layout["walls"]:
					wall_set[str(wk)] = true

			var attach_left := bool(hit_wall["isLeft"])
			var origin_gx := int(hit_wall["gx"]) if attach_left else clampi(int(hit_wall["gx"]), 0, maxi(0, w_cols - span))
			var origin_gy := clampi(int(hit_wall["gy"]), 0, maxi(0, h_rows - span)) if attach_left else int(hit_wall["gy"])

			var cells: Array = []
			var all_valid := true
			for i in range(span):
				var cx := origin_gx if attach_left else origin_gx + i
				var cy := origin_gy + i if attach_left else origin_gy
				var cell_valid := false
				if has_custom_walls:
					var key := ("L:%d,%d" % [cx, cy]) if attach_left else ("R:%d,%d" % [cx, cy])
					cell_valid = wall_set.has(key)
				else:
					cell_valid = cx >= 0 and cx < w_cols and cy >= 0 and cy < h_rows and _is_tile_walkable(float(cx), float(cy))
				if not cell_valid:
					all_valid = false
				cells.append({"gx": cx, "gy": cy, "valid": cell_valid})

			var start_row := clampi(int(hit_wall["rowIdx"]), 0, maxi(0, 3 - row_count))
			var elev_px := float(start_row) * row_h + (12.0 if str(cat.get("id", "")) == "shower_set" else 6.0)
			return {
				"gx": float(origin_gx),
				"gy": float(origin_gy),
				"flipped": attach_left,
				"layer": "wall",
				"parentSurfaceUid": "",
				"elevationPx": elev_px,
				"valid": all_valid,
				"hint": ("Treo tường tầng %d (%d ô)" % [start_row + 1, span]) if all_valid else "⚠️ Không đủ ô tường liền kề để treo đồ này",
				"cells": cells,
			}

		var ix := clampi(int(floor(gx)), 0, maxi(0, w_cols - 1))
		var iy := clampi(int(floor(gy)), 0, maxi(0, h_rows - 1))
		var attach_left_fb := (iy >= ix) if flipped else (ix <= iy)
		return {
			"gx": float(ix),
			"gy": float(iy),
			"flipped": attach_left_fb,
			"layer": "wall",
			"parentSurfaceUid": "",
			"elevationPx": float(base_span.get("start", 1)) * row_h + 6.0,
			"valid": false,
			"hint": "⚠️ Hãy rê chuột trực tiếp lên ô tường muốn treo đồ",
			"cells": [{"gx": ix, "gy": iy, "valid": false}],
		}

	# Floor placement
	var rel_cells := GameData.get_relative_footprint_cells(cat, flipped)
	var max_dx := 0
	var max_dy := 0
	for c in rel_cells:
		max_dx = maxi(max_dx, int(c["dx"]))
		max_dy = maxi(max_dy, int(c["dy"]))
	var origin_gx := int(floor(gx - float(max_dx) * 0.5))
	var origin_gy := int(floor(gy - float(max_dy) * 0.5))

	var solid_occupied: Dictionary = {}
	for item in GameStore.layout.get("items", []):
		if not (item is Dictionary):
			continue
		if str(item.get("uid", "")) == GameStore.moving_item_uid or str(item.get("layer", "")) != "floor":
			continue
		var other_cat := GameData.get_catalog_item(str(item.get("catalogId", "")))
		if other_cat.is_empty() or bool(other_cat.get("walkable", false)):
			continue
		for c in GameData.get_item_occupied_cells(other_cat, float(item.get("gx", 0.0)), float(item.get("gy", 0.0)), bool(item.get("flipped", false))):
			solid_occupied["%d,%d" % [int(c["gx"]), int(c["gy"])]] = true

	var cells: Array = []
	var all_valid := true
	var is_cat_walkable := bool(cat.get("walkable", false))
	for c in rel_cells:
		var cx := origin_gx + int(c["dx"])
		var cy := origin_gy + int(c["dy"])
		var has_floor := cx >= 0 and cx < w_cols and cy >= 0 and cy < h_rows and _is_tile_walkable(float(cx), float(cy))
		var blocked := (not is_cat_walkable) and solid_occupied.has("%d,%d" % [cx, cy])
		var valid := has_floor and not blocked
		if not valid:
			all_valid = false
		cells.append({"gx": cx, "gy": cy, "valid": valid})

	return {
		"gx": float(origin_gx),
		"gy": float(origin_gy),
		"flipped": flipped,
		"layer": "floor",
		"parentSurfaceUid": "",
		"elevationPx": 0.0,
		"valid": all_valid,
		"hint": ("Click để đặt (%d ô) — [R] xoay hướng" % cells.size()) if all_valid else "⚠️ Có ô bị chồng lên đồ khác hoặc nằm ngoài sàn!",
		"cells": cells,
	}


func _pick_item_at_local(local_x: float, local_y: float) -> Dictionary:
	var sorted := _rendered_items.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["depth"]) > float(b["depth"])
	)
	for meta in sorted:
		var spr: Sprite2D = meta["sprite"]
		if spr == null or spr.texture == null:
			continue
		var sz := spr.texture.get_size()
		var min_x := spr.position.x + spr.offset.x * spr.scale.x
		var max_x := min_x + sz.x * spr.scale.x
		var min_y := spr.position.y + spr.offset.y * spr.scale.y
		var max_y := min_y + sz.y * spr.scale.y
		if local_x >= min_x and local_x <= max_x and local_y >= min_y and local_y <= max_y:
			return meta["item"]
	return {}


func _rebuild_static_and_furniture() -> void:
	var layout := GameStore.layout
	if layout.is_empty():
		return

	# Clean old backdrop children except hover_cursor
	for child in _backdrop_layer.get_children():
		if child != _hover_cursor:
			_backdrop_layer.remove_child(child)
			child.queue_free()

	# Clean old furniture & wall segments from _sort_layer (keep ghosts & avatars)
	for child in _sort_layer.get_children():
		if child == _local_ghost_sprite or child == _remote_ghost_container:
			continue
		if child.has_meta("is_avatar"):
			continue
		_sort_layer.remove_child(child)
		child.queue_free()
	_rendered_items.clear()

	# Clean old glows
	for child in _glow_container.get_children():
		_glow_container.remove_child(child)
		child.queue_free()

	var floor_map: Array = layout.get("floorMap", [])
	var h_rows := floor_map.size()
	var w_cols := 0
	for r in floor_map:
		w_cols = maxi(w_cols, str(r).length())

	var wall_theme := str(layout.get("wallTheme", "lofi_purple"))
	var palette: Dictionary = GameData.WALL_PALETTES.get(wall_theme, GameData.WALL_PALETTES["lofi_purple"])

	_backdrop_layer.floor_map = floor_map
	_backdrop_layer.palette = palette
	_backdrop_layer.has_custom_walls = layout.has("walls") and layout["walls"] is Array
	_backdrop_layer.build_mode = GameStore.build_mode
	_backdrop_layer.grid_w = w_cols
	_backdrop_layer.grid_h = h_rows
	_backdrop_layer.queue_redraw()

	# Custom wall segments inside _sort_layer
	if _backdrop_layer.has_custom_walls:
		for w_key_val in layout["walls"]:
			var w_key := str(w_key_val)
			var parts := w_key.split(":")
			if parts.size() < 2:
				continue
			var coords := parts[1].split(",")
			if coords.size() < 2:
				continue
			var sx := int(coords[0])
			var sy := int(coords[1])
			var is_left := (parts[0] == "L")
			var p0 := GameData.grid_to_screen(float(sx), float(sy))
			var p1 := GameData.grid_to_screen(float(sx), float(sy + 1)) if is_left else GameData.grid_to_screen(float(sx + 1), float(sy))
			var wg := _WallSegmentDrawer.new()
			wg.p0 = p0
			wg.p1 = p1
			wg.is_left = is_left
			wg.palette = palette
			wg.set_meta("depth", (float(sx) + float(sy) + 0.5) * 100.0 - 15.0)
			_sort_layer.add_child(wg)

	# Floor Tile Sprites in _backdrop_layer
	var tiles_container := Node2D.new()
	tiles_container.name = "TilesContainer"
	_backdrop_layer.add_child(tiles_container)
	_backdrop_layer.move_child(_hover_cursor, _backdrop_layer.get_child_count() - 1)

	for gy in range(h_rows):
		var row := str(floor_map[gy])
		for gx in range(w_cols):
			var tile := row[gx] if gx < row.length() else "."
			if tile == ".":
				continue
			var center := GameData.grid_to_screen(float(gx) + 0.5, float(gy) + 0.5)
			var tex_path := (
				"res://sprites/tiles/floor_tiles.png"
				if tile == "B"
				else "res://sprites/tiles/floor_wood_iso.png"
			)
			var spr := Sprite2D.new()
			spr.texture = GameData.get_texture(tex_path)
			spr.centered = true
			spr.position = center
			spr.scale = Vector2(GameData.TILE_W / 250.0, GameData.TILE_H / 125.0)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			if tile == "C":
				spr.modulate = Color("#e9d5ff")
			tiles_container.add_child(spr)

	# Placed Items
	var items: Array = layout.get("items", [])
	for item_val in items:
		if not (item_val is Dictionary):
			continue
		var item: Dictionary = item_val
		if GameStore.build_mode and GameStore.moving_item_uid == str(item.get("uid", "")):
			continue

		var cat := GameData.get_catalog_item(str(item.get("catalogId", "")))
		if cat.is_empty():
			continue

		var alt_sprite := str(cat.get("altSprite", ""))
		var sprite_path := alt_sprite if (bool(item.get("toggled", false)) and not alt_sprite.is_empty()) else str(cat.get("sprite", ""))
		var flipped := bool(item.get("flipped", false))
		var layer := str(item.get("layer", "floor"))
		var elev := float(item.get("elevationPx", 0.0))
		var placement_pos := _compute_sprite_placement(cat, float(item.get("gx", 0.0)), float(item.get("gy", 0.0)), flipped, layer, elev)

		var tex := GameData.get_texture(sprite_path)
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.centered = false
		if tex != null:
			var tsz := tex.get_size()
			spr.offset = Vector2(-tsz.x * 0.5, -tsz.y)
		spr.position = Vector2(float(placement_pos["x"]), float(placement_pos["y"]))
		var sc := float(cat.get("scale", 1.0))
		spr.scale = Vector2(sc, sc)
		spr.flip_h = flipped
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

		var z_base := float(placement_pos["depth"])
		if bool(cat.get("walkable", false)):
			z_base -= 40.0
		elif layer == "surface":
			var parent_uid := str(item.get("parentSurfaceUid", ""))
			var parent_depth := float(placement_pos["depth"])
			for p_val in items:
				if p_val is Dictionary and str(p_val.get("uid", "")) == parent_uid:
					var p_cat := GameData.get_catalog_item(str(p_val.get("catalogId", "")))
					if not p_cat.is_empty():
						var pm := GameData.get_footprint_screen_metrics(p_cat, float(p_val.get("gx", 0.0)), float(p_val.get("gy", 0.0)), bool(p_val.get("flipped", false)))
						parent_depth = float(pm["depthScore"])
					break
			z_base = parent_depth + 35.0 + elev * 0.1

			var shadow := _EllipseDrawer.new()
			shadow.position = Vector2(float(placement_pos["x"]), float(placement_pos["y"]) - 2.0)
			shadow.rx = 22.0
			shadow.ry = 9.0
			shadow.color = Color("#090512", 0.35)
			shadow.set_meta("depth", z_base - 0.5)
			_sort_layer.add_child(shadow)
		elif layer != "wall":
			z_base += 15.0

		spr.set_meta("depth", z_base)
		_sort_layer.add_child(spr)
		_rendered_items.append({
			"uid": str(item.get("uid", "")),
			"sprite": spr,
			"item": item,
			"depth": z_base,
		})

		# Light emitter glow
		if cat.has("lightEmitter") and cat["lightEmitter"] is Dictionary:
			var le: Dictionary = cat["lightEmitter"]
			var cid := str(cat.get("id", ""))
			var is_light_active := bool(item.get("toggled", false)) if (cid == "heat_lamp" or cid == "fridge") else true
			if is_light_active:
				var glow := Sprite2D.new()
				var gtex := GameData.get_glow_texture(int(le.get("color", 0xffffff)))
				glow.texture = gtex
				glow.centered = true
				glow.position = Vector2(float(placement_pos["x"]), float(placement_pos["y"]) + float(le.get("offsetY", -40.0)))
				var radius := float(le.get("radius", 100.0))
				var gsize := radius * 2.0
				if gtex != null:
					var gsz := gtex.get_size()
					glow.scale = Vector2(gsize / gsz.x, gsize / gsz.y)
				glow.modulate.a = float(le.get("intensity", 0.5)) * 0.22
				glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				_glow_container.add_child(glow)


func _compute_layout_signature() -> String:
	var layout := GameStore.layout
	var toggled_parts: PackedStringArray = []
	for item in layout.get("items", []):
		if item is Dictionary:
			toggled_parts.append("%s:%s:%s:%s:%s" % [
				str(item.get("uid", "")),
				str(item.get("gx", 0)),
				str(item.get("gy", 0)),
				str(item.get("flipped", false)),
				str(item.get("toggled", false)),
			])
	return "%s|%s|%s|%s|%d|%s|%s" % [
		str(layout.get("roomCode", "")),
		str(layout.get("wallTheme", "")),
		JSON.stringify(layout.get("floorMap", [])),
		JSON.stringify(layout.get("walls", [])),
		(layout.get("items", []) as Array).size(),
		";".join(toggled_parts),
		GameStore.moving_item_uid,
	]


func _is_text_input_focused() -> bool:
	var f := get_viewport().gui_get_focus_owner()
	return f is LineEdit or f is TextEdit


func _input(event: InputEvent) -> void:
	if GameStore.current_screen != "game":
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed:
			if mb.button_index == MOUSE_BUTTON_LEFT:
				_is_pointer_down_left = false
			_is_panning = false
	elif event is InputEventKey:
		var ke := event as InputEventKey
		if not ke.pressed:
			var key_str := OS.get_keycode_string(ke.keycode).to_lower()
			_pressed_keys.erase(key_str)


func _unhandled_input(event: InputEvent) -> void:
	if GameStore.current_screen != "game":
		return
	if GameStore.show_room_modal or GameStore.show_profile_modal:
		return

	if event is InputEventKey:
		var ke := event as InputEventKey
		if _is_text_input_focused():
			return
		var key_str := OS.get_keycode_string(ke.keycode).to_lower()
		if ke.pressed and not ke.echo:
			_pressed_keys[key_str] = true
			if key_str == "b":
				GameStore.toggle_build_mode()
			elif key_str == "g" and not GameStore.build_mode:
				GameStore.sit_on_floor()
			elif key_str == "r" and GameStore.build_mode:
				GameStore.toggle_place_flipped()
			elif (ke.keycode == KEY_DELETE or ke.keycode == KEY_BACKSPACE) and GameStore.build_mode and not GameStore.moving_item_uid.is_empty():
				GameStore.remove_item(GameStore.moving_item_uid)
			elif ke.keycode == KEY_ESCAPE and GameStore.build_mode:
				if not GameStore.moving_item_uid.is_empty():
					GameStore.start_moving_item("")
				elif not GameStore.selected_catalog_id.is_empty():
					GameStore.select_catalog_item("")
				else:
					GameStore.toggle_build_mode(0)
		elif not ke.pressed:
			_pressed_keys.erase(key_str)

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_by_ratio(0.05)
				return
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_by_ratio(-0.05)
				return

			SoundEngine.unlock_audio()
			var coords := _to_world_grid(mb.position)

			# Middle click, Alt+Left, Space+Left, or Right click -> pan camera
			if (
				mb.button_index == MOUSE_BUTTON_MIDDLE
				or mb.button_index == MOUSE_BUTTON_RIGHT
				or (mb.button_index == MOUSE_BUTTON_LEFT and (mb.alt_pressed or _pressed_keys.has("space")))
			):
				_is_panning = true
				_pan_start = mb.position - cam_pan
				return

			if mb.button_index != MOUSE_BUTTON_LEFT:
				return
			_is_pointer_down_left = true
			_handle_left_click(coords)

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _is_panning:
			cam_pan = mm.position - _pan_start
			return
		var coords := _to_world_grid(mm.position)
		_hover_grid = {
			"gx": float(coords["gx"]),
			"gy": float(coords["gy"]),
			"localX": float(coords["localX"]),
			"localY": float(coords["localY"]),
		}
		_has_hover_grid = true
		_handle_pointer_move(coords)


func _handle_left_click(coords: Dictionary) -> void:
	var gx := float(coords["gx"])
	var gy := float(coords["gy"])
	var local_x := float(coords["localX"])
	var local_y := float(coords["localY"])

	if GameStore.build_mode:
		if not GameStore.active_floor_brush.is_empty():
			GameStore.paint_tile(int(floor(gx)), int(floor(gy)), GameStore.active_floor_brush)
			return

		if not GameStore.active_wall_brush.is_empty():
			var floor_map: Array = GameStore.layout.get("floorMap", [])
			var h_rows := floor_map.size()
			var w_cols := 0
			for r in floor_map:
				w_cols = maxi(w_cols, str(r).length())
			var tx := int(floor(gx))
			var ty := int(floor(gy))
			if tx >= 0 and tx < w_cols and ty >= 0 and ty < h_rows:
				var frac_x := gx - float(tx)
				var frac_y := gy - float(ty)
				var is_left := (frac_y < frac_x) if GameStore.place_flipped else (frac_x <= frac_y)
				var wall_key := "%s:%d,%d" % ["L" if is_left else "R", tx, ty]
				GameStore.toggle_wall_segment(wall_key, GameStore.active_wall_brush)
			return

		var active_cat_id := ""
		if not GameStore.moving_item_uid.is_empty():
			for item in GameStore.layout.get("items", []):
				if item is Dictionary and str(item.get("uid", "")) == GameStore.moving_item_uid:
					active_cat_id = str(item.get("catalogId", ""))
					break
		else:
			active_cat_id = GameStore.selected_catalog_id

		if not active_cat_id.is_empty():
			var target := _compute_placement_target(gx, gy, active_cat_id, GameStore.place_flipped, local_x, local_y)
			if not target.is_empty() and bool(target.get("valid", false)):
				var existing: Dictionary = {}
				if not GameStore.moving_item_uid.is_empty():
					for item in GameStore.layout.get("items", []):
						if item is Dictionary and str(item.get("uid", "")) == GameStore.moving_item_uid:
							existing = item
							break
				var next_uid := str(existing.get("uid", ""))
				if next_uid.is_empty():
					next_uid = "item_%d_%s" % [GameStore.now_ms(), str(randi() % 10000)]
				var next_item := {
					"uid": next_uid,
					"catalogId": active_cat_id,
					"gx": target["gx"],
					"gy": target["gy"],
					"rotation": int(existing.get("rotation", 0)),
					"flipped": bool(target["flipped"]),
					"layer": str(target["layer"]),
					"elevationPx": target["elevationPx"],
					"toggled": bool(existing.get("toggled", false)),
				}
				if not str(target.get("parentSurfaceUid", "")).is_empty():
					next_item["parentSurfaceUid"] = target["parentSurfaceUid"]
				GameStore.place_or_update_item(next_item)
			else:
				GameStore.show_toast("⚠️ Vị trí này chưa đặt được đồ!")
			return

		var hit := _pick_item_at_local(local_x, local_y)
		if not hit.is_empty():
			GameStore.start_moving_item(str(hit.get("uid", "")))
		else:
			_is_panning = true
			_pan_start = Vector2(float(coords["canvasX"]), float(coords["canvasY"])) - cam_pan
		return

	# Normal play mode click
	var hit := _pick_item_at_local(local_x, local_y)
	if not hit.is_empty():
		var cat := GameData.get_catalog_item(str(hit.get("catalogId", "")))
		var seat_slots: Array = cat.get("seatSlots", [])
		if seat_slots.size() > 0:
			var free_slot: Dictionary = seat_slots[0]
			var hit_uid := str(hit.get("uid", ""))
			for slot in seat_slots:
				var taken := false
				for p_val in GameStore.players.values():
					if p_val is Dictionary:
						if str(p_val.get("id", "")) != GameStore.my_player_id and str(p_val.get("seatedOnItemUid", "")) == hit_uid and str(p_val.get("seatSlotId", "")) == str(slot.get("id", "")):
							taken = true
							break
				if not taken:
					free_slot = slot
					break
			var hit_flipped := bool(hit.get("flipped", false))
			var metrics := GameData.get_footprint_screen_metrics(cat, float(hit.get("gx", 0.0)), float(hit.get("gy", 0.0)), hit_flipped)
			var off_gx := float(free_slot.get("offsetGy", 0.0)) if hit_flipped else float(free_slot.get("offsetGx", 0.0))
			var off_gy := float(free_slot.get("offsetGx", 0.0)) if hit_flipped else float(free_slot.get("offsetGy", 0.0))
			var seat_gx := float(metrics["centroidGx"]) + off_gx
			var seat_gy := float(metrics["centroidGy"]) + off_gy
			var seat_facing := str(free_slot.get("facing", "se"))
			if hit_flipped:
				seat_facing = GameData.mirror_facing_direction(seat_facing)
			_has_walk_target = false
			GameStore.seat_at_item(hit_uid, str(free_slot.get("id", "")), seat_gx, seat_gy, str(free_slot.get("activity", "focus_desk")), seat_facing)
			return

		if not str(cat.get("altSprite", "")).is_empty():
			GameStore.toggle_item_interaction(str(hit.get("uid", "")))
			return

	if _is_tile_walkable(gx, gy):
		if not str(GameStore.local_player.get("seatedOnItemUid", "")).is_empty() or str(GameStore.local_player.get("activity", "idle")) == "sit_floor":
			GameStore.stand_up()
		_walk_target = Vector2(gx, gy)
		_has_walk_target = true


func _handle_pointer_move(coords: Dictionary) -> void:
	var gx := float(coords["gx"])
	var gy := float(coords["gy"])
	var local_x := float(coords["localX"])
	var local_y := float(coords["localY"])

	if GameStore.build_mode:
		if _is_pointer_down_left and not GameStore.active_floor_brush.is_empty():
			GameStore.paint_tile(int(floor(gx)), int(floor(gy)), GameStore.active_floor_brush)

		var active_cat_id := ""
		if not GameStore.moving_item_uid.is_empty():
			for item in GameStore.layout.get("items", []):
				if item is Dictionary and str(item.get("uid", "")) == GameStore.moving_item_uid:
					active_cat_id = str(item.get("catalogId", ""))
					break
		else:
			active_cat_id = GameStore.selected_catalog_id

		if not active_cat_id.is_empty():
			_hovered_existing_item_uid = ""
			var target := _compute_placement_target(gx, gy, active_cat_id, GameStore.place_flipped, local_x, local_y)
			_set_hover_hint(str(target.get("hint", "")))
			var now_ticks := Time.get_ticks_msec()
			if not target.is_empty() and now_ticks - _last_preview_emit_ms > 85:
				_last_preview_emit_ms = now_ticks
				GameStore.emit_preview({
					"catalogId": active_cat_id,
					"gx": target["gx"],
					"gy": target["gy"],
					"flipped": target["flipped"],
					"elevationPx": target["elevationPx"],
					"layer": target["layer"],
				})
		else:
			var hit := _pick_item_at_local(local_x, local_y)
			_hovered_existing_item_uid = str(hit.get("uid", "")) if not hit.is_empty() else ""
			if not hit.is_empty():
				var cat := GameData.get_catalog_item(str(hit.get("catalogId", "")))
				_set_hover_hint("🖐️ Bấm để di chuyển / xóa: %s" % str(cat.get("name", "")))
			else:
				if not GameStore.active_floor_brush.is_empty():
					_set_hover_hint("🖌️ Click/Kéo để lát sàn (%s)" % GameStore.active_floor_brush)
				else:
					_set_hover_hint("")
	else:
		_hovered_existing_item_uid = ""
		var hit := _pick_item_at_local(local_x, local_y)
		if not hit.is_empty():
			var cat := GameData.get_catalog_item(str(hit.get("catalogId", "")))
			var seats: Array = cat.get("seatSlots", [])
			if seats.size() > 0:
				_set_hover_hint("🪑 Bấm vào %s để ngồi Focus/Chill" % str(cat.get("name", "")))
			elif not str(cat.get("altSprite", "")).is_empty():
				_set_hover_hint("✨ Bấm để bật/mở %s" % str(cat.get("name", "")))
			else:
				_set_hover_hint("")
		else:
			_set_hover_hint("")


func _process(delta: float) -> void:
	if GameStore.current_screen != "game":
		return
	var dt := minf(delta, 0.05)
	var now_ticks := Time.get_ticks_msec()
	var now_unix_ms := GameStore.now_ms()

	_update_camera_transform()

	var sig := _compute_layout_signature()
	if sig != _last_layout_sig or GameStore.build_mode != _last_build_mode:
		_last_layout_sig = sig
		_last_build_mode = GameStore.build_mode
		_rebuild_static_and_furniture()

	_process_local_movement(dt, now_ticks)
	_update_hover_cursor_and_ghost()
	_update_remote_ghosts()
	_update_avatars(dt, now_ticks, now_unix_ms)
	_sort_layer_children()
	_update_atmosphere_and_rain(dt)


func _process_local_movement(dt: float, now_ticks: int) -> void:
	if _is_text_input_focused() or GameStore.show_room_modal or GameStore.show_profile_modal:
		return

	var dx := 0.0
	var dy := 0.0
	if _pressed_keys.has("w") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dy -= 1.0
	if _pressed_keys.has("s") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dy += 1.0
	if _pressed_keys.has("a") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dx -= 1.0
	if _pressed_keys.has("d") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dx += 1.0

	var is_running := Input.is_key_pressed(KEY_SHIFT)
	var speed := 3.8 if is_running else 2.3
	var cur := GameStore.local_player

	if dx != 0.0 or dy != 0.0:
		_has_walk_target = false
		if not str(cur.get("seatedOnItemUid", "")).is_empty() or str(cur.get("activity", "idle")) == "sit_floor":
			GameStore.stand_up()

		var length := sqrt(dx * dx + dy * dy)
		var ndx := dx / length
		var ndy := dy / length
		var d_gx := ndx * 0.5 + ndy
		var d_gy := ndy - ndx * 0.5
		var g_len := sqrt(d_gx * d_gx + d_gy * d_gy)
		if g_len == 0.0:
			g_len = 1.0

		var cur_gx := float(cur.get("gx", 4.5))
		var cur_gy := float(cur.get("gy", 5.5))
		var next_gx := cur_gx + (d_gx / g_len) * speed * dt
		var next_gy := cur_gy + (d_gy / g_len) * speed * dt

		var facing := "se"
		if ndy < 0.0:
			facing = "nw" if ndx <= 0.0 else "ne"
		else:
			facing = "sw" if ndx < 0.0 else "se"

		var cur_walk := _is_tile_walkable(cur_gx, cur_gy)
		var next_walk := _is_tile_walkable(next_gx, next_gy)
		var can_move := next_walk or not cur_walk

		GameStore.move_local_player({
			"gx": next_gx if can_move else cur_gx,
			"gy": next_gy if can_move else cur_gy,
			"facing": facing,
			"isMoving": true,
			"isRunning": is_running,
		})

		var step_interval := 220 if is_running else 340
		if now_ticks - _last_step_sfx_ms > step_interval:
			_last_step_sfx_ms = now_ticks
			SoundEngine.play_sfx("step")
	elif _has_walk_target:
		var cur_gx := float(cur.get("gx", 4.5))
		var cur_gy := float(cur.get("gy", 5.5))
		var dg_x := _walk_target.x - cur_gx
		var dg_y := _walk_target.y - cur_gy
		var dist := sqrt(dg_x * dg_x + dg_y * dg_y)
		if dist < 0.08:
			_has_walk_target = false
			GameStore.move_local_player({
				"gx": cur_gx,
				"gy": cur_gy,
				"facing": str(cur.get("facing", "se")),
				"isMoving": false,
				"isRunning": false,
			})
		else:
			var step_gx := cur_gx + (dg_x / dist) * speed * dt
			var step_gy := cur_gy + (dg_y / dist) * speed * dt
			var screen_delta := GameData.grid_to_screen(dg_x, dg_y)
			var facing := "se"
			if screen_delta.y < 0.0:
				facing = "nw" if screen_delta.x <= 0.0 else "ne"
			else:
				facing = "sw" if screen_delta.x < 0.0 else "se"

			if _is_tile_walkable(step_gx, step_gy):
				GameStore.move_local_player({
					"gx": step_gx,
					"gy": step_gy,
					"facing": facing,
					"isMoving": true,
					"isRunning": false,
				})
				if now_ticks - _last_step_sfx_ms > 340:
					_last_step_sfx_ms = now_ticks
					SoundEngine.play_sfx("step")
			else:
				_has_walk_target = false
				GameStore.move_local_player({
					"gx": cur_gx,
					"gy": cur_gy,
					"facing": facing,
					"isMoving": false,
					"isRunning": false,
				})
	elif bool(cur.get("isMoving", false)):
		GameStore.move_local_player({
			"gx": float(cur.get("gx", 4.5)),
			"gy": float(cur.get("gy", 5.5)),
			"facing": str(cur.get("facing", "se")),
			"isMoving": false,
			"isRunning": false,
		})


func _update_hover_cursor_and_ghost() -> void:
	var layout := GameStore.layout
	var floor_map: Array = layout.get("floorMap", [])
	var h_rows := floor_map.size()
	var w_cols := 0
	for r in floor_map:
		w_cols = maxi(w_cols, str(r).length())

	_hover_cursor.clear_state()
	_hover_cursor.grid_w = w_cols
	_hover_cursor.grid_h = h_rows
	_hover_cursor.show_brush_wireframe = GameStore.build_mode and (not GameStore.active_floor_brush.is_empty() or not GameStore.active_wall_brush.is_empty())

	if GameStore.build_mode and _has_hover_grid:
		var gx := float(_hover_grid["gx"])
		var gy := float(_hover_grid["gy"])
		var local_x := float(_hover_grid["localX"])
		var local_y := float(_hover_grid["localY"])

		var active_cat_id := ""
		if not GameStore.moving_item_uid.is_empty():
			for item in layout.get("items", []):
				if item is Dictionary and str(item.get("uid", "")) == GameStore.moving_item_uid:
					active_cat_id = str(item.get("catalogId", ""))
					break
		else:
			active_cat_id = GameStore.selected_catalog_id

		if not GameStore.active_floor_brush.is_empty():
			var tx := int(floor(gx))
			var ty := int(floor(gy))
			if tx >= 0 and tx < w_cols and ty >= 0 and ty < h_rows:
				_hover_cursor.floor_brush_cell = Vector2i(tx, ty)
				_hover_cursor.has_floor_brush = true
				_hover_cursor.floor_brush_erase = (GameStore.active_floor_brush == ".")
			_local_ghost_sprite.visible = false
		elif not GameStore.active_wall_brush.is_empty():
			var tx := int(floor(gx))
			var ty := int(floor(gy))
			if tx >= 0 and tx < w_cols and ty >= 0 and ty < h_rows:
				var frac_x := gx - float(tx)
				var frac_y := gy - float(ty)
				var is_left := (frac_y < frac_x) if GameStore.place_flipped else (frac_x <= frac_y)
				_hover_cursor.has_wall_brush = true
				_hover_cursor.wall_brush_cell = Vector2i(tx, ty)
				_hover_cursor.wall_brush_left = is_left
				_hover_cursor.wall_brush_remove = (GameStore.active_wall_brush == "remove")
			_local_ghost_sprite.visible = false
		elif not active_cat_id.is_empty():
			var target := _compute_placement_target(gx, gy, active_cat_id, GameStore.place_flipped, local_x, local_y)
			var cat := GameData.get_catalog_item(active_cat_id)
			if not target.is_empty() and not cat.is_empty():
				var pos := _compute_sprite_placement(cat, float(target["gx"]), float(target["gy"]), bool(target["flipped"]), str(target["layer"]), float(target["elevationPx"]))
				var tex := GameData.get_texture(str(cat.get("sprite", "")))
				_local_ghost_sprite.texture = tex
				if tex != null:
					var tsz := tex.get_size()
					_local_ghost_sprite.offset = Vector2(-tsz.x * 0.5, -tsz.y)
				_local_ghost_sprite.position = Vector2(float(pos["x"]), float(pos["y"]))
				var sc := float(cat.get("scale", 1.0))
				_local_ghost_sprite.scale = Vector2(sc, sc)
				_local_ghost_sprite.flip_h = bool(target["flipped"])
				var tint := Color("#86efac")
				if not bool(target["valid"]):
					tint = Color("#f87171")
				elif str(target["layer"]) == "surface":
					tint = Color("#7dd3fc")
				tint.a = 0.72
				_local_ghost_sprite.modulate = tint
				_local_ghost_sprite.set_meta("depth", float(pos["depth"]) + 80.0)
				_local_ghost_sprite.visible = true

				_hover_cursor.placement_target = target
				_hover_cursor.placement_cat = cat
				_hover_cursor.has_placement_target = true
		else:
			_local_ghost_sprite.visible = false
			if not _hovered_existing_item_uid.is_empty():
				for item in layout.get("items", []):
					if item is Dictionary and str(item.get("uid", "")) == _hovered_existing_item_uid:
						var hcat := GameData.get_catalog_item(str(item.get("catalogId", "")))
						if not hcat.is_empty():
							_hover_cursor.has_hovered_existing = true
							_hover_cursor.hovered_item = item
							_hover_cursor.hovered_cat = hcat
						break
	else:
		_local_ghost_sprite.visible = false

	_hover_cursor.queue_redraw()


func _update_remote_ghosts() -> void:
	for child in _remote_ghost_container.get_children():
		_remote_ghost_container.remove_child(child)
		child.queue_free()

	for preview_val in GameStore.ghost_previews.values():
		if not (preview_val is Dictionary):
			continue
		var preview: Dictionary = preview_val
		if str(preview.get("playerId", "")) == GameStore.my_player_id:
			continue
		var cat := GameData.get_catalog_item(str(preview.get("catalogId", "")))
		if cat.is_empty():
			continue
		var flipped := bool(preview.get("flipped", false))
		var layer := str(preview.get("layer", "floor"))
		var elev := float(preview.get("elevationPx", 0.0))
		var pos := _compute_sprite_placement(cat, float(preview.get("gx", 0.0)), float(preview.get("gy", 0.0)), flipped, layer, elev)
		var gspr := Sprite2D.new()
		var tex := GameData.get_texture(str(cat.get("sprite", "")))
		gspr.texture = tex
		gspr.centered = false
		if tex != null:
			var tsz := tex.get_size()
			gspr.offset = Vector2(-tsz.x * 0.5, -tsz.y)
		gspr.position = Vector2(float(pos["x"]), float(pos["y"]))
		var sc := float(cat.get("scale", 1.0))
		gspr.scale = Vector2(sc, sc)
		gspr.flip_h = flipped
		gspr.modulate = Color("#f472b6", 0.48)
		gspr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_remote_ghost_container.add_child(gspr)
		_remote_ghost_container.set_meta("depth", float(pos["depth"]) + 75.0)


func _update_avatars(dt: float, now_ticks: int, now_unix_ms: int) -> void:
	var all_players := GameStore.players
	for id in _avatar_visuals.keys():
		if not all_players.has(id):
			var v: Dictionary = _avatar_visuals[id]
			var c: Node2D = v["container"]
			if c.get_parent() != null:
				c.get_parent().remove_child(c)
			c.queue_free()
			_avatar_visuals.erase(id)

	var ui_draw_list: Array = []

	for player_val in all_players.values():
		if not (player_val is Dictionary):
			continue
		var player: Dictionary = player_val
		var pid := str(player.get("id", ""))
		if pid.is_empty():
			continue

		if not _avatar_visuals.has(pid):
			var container := Node2D.new()
			container.set_meta("is_avatar", true)

			var shadow := _AvatarShadowDrawer.new()
			var focus_ring := _FocusRingDrawer.new()
			focus_ring.visible = false

			var spr := Sprite2D.new()
			spr.centered = false
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

			container.add_child(shadow)
			container.add_child(focus_ring)
			container.add_child(spr)
			_sort_layer.add_child(container)

			_avatar_visuals[pid] = {
				"container": container,
				"sprite": spr,
				"shadow": shadow,
				"focus_ring": focus_ring,
				"gx": float(player.get("gx", 4.5)),
				"gy": float(player.get("gy", 5.5)),
				"walk_phase": 0.0,
			}

		var vis: Dictionary = _avatar_visuals[pid]
		var lerp_rate := 1.0 if pid == GameStore.my_player_id else minf(1.0, dt * 14.0)
		var target_gx := float(player.get("gx", 4.5))
		var target_gy := float(player.get("gy", 5.5))
		vis["gx"] = float(vis["gx"]) + (target_gx - float(vis["gx"])) * lerp_rate
		vis["gy"] = float(vis["gy"]) + (target_gy - float(vis["gy"])) * lerp_rate

		var screen_pos := GameData.grid_to_screen(float(vis["gx"]), float(vis["gy"]))
		var activity := str(player.get("activity", "idle"))
		var seat_offset_y := 0.0
		if not str(player.get("seatedOnItemUid", "")).is_empty():
			seat_offset_y = -8.0
		elif activity == "sit_floor":
			seat_offset_y = 2.0

		var container: Node2D = vis["container"]
		container.position = Vector2(screen_pos.x, screen_pos.y + seat_offset_y)
		container.set_meta("depth", (float(vis["gx"]) + float(vis["gy"])) * 100.0 + 26.0)

		var is_moving := bool(player.get("isMoving", false))
		var is_running := bool(player.get("isRunning", false))
		if is_moving:
			vis["walk_phase"] = float(vis["walk_phase"]) + dt * (12.0 if is_running else 8.0)
		else:
			vis["walk_phase"] = float(vis["walk_phase"]) + dt * 3.2

		var outfit := str(player.get("outfit", "c1"))
		var facing := str(player.get("facing", "se"))
		var resolved := GameData.resolve_iso_character_frame(
			outfit,
			facing,
			activity,
			is_moving,
			int(floor(float(vis["walk_phase"])))
		)
		var spr: Sprite2D = vis["sprite"]
		var tex: Texture2D = null
		if outfit == "custom":
			var cfg: Dictionary = player.get("customAvatar", GameData.DEFAULT_CUSTOM_AVATAR)
			if not (cfg is Dictionary):
				cfg = GameData.DEFAULT_CUSTOM_AVATAR
			tex = AvatarRenderer.get_custom_avatar_texture(str(resolved["path"]), cfg)
		else:
			tex = GameData.get_texture(str(resolved["path"]))

		spr.texture = tex
		if tex != null:
			var tsz := tex.get_size()
			spr.offset = Vector2(-tsz.x * 0.5, -tsz.y * 0.938)
		spr.flip_h = bool(resolved["flipX"])

		var base_scale := 0.48
		if is_moving:
			var step_bob := 1.0 + absf(sin(float(vis["walk_phase"]) * PI * 0.5)) * 0.025
			spr.scale = Vector2(base_scale, base_scale * step_bob)
		else:
			var breath := (
				1.0 + sin(float(vis["walk_phase"]) * 1.6) * 0.02
				if activity == "focus_desk"
				else 1.0 + sin(float(vis["walk_phase"])) * 0.015
			)
			spr.scale = Vector2(base_scale, base_scale * breath)

		var focus_ring: Node2D = vis["focus_ring"]
		focus_ring.visible = (activity == "focus_desk")
		if focus_ring.visible:
			var pulse := 1.0 + sin(float(now_ticks) / 300.0) * 0.08
			focus_ring.scale = Vector2(pulse, pulse)

		ui_draw_list.append({
			"pos": Vector2(screen_pos.x, screen_pos.y + seat_offset_y - 118.0),
			"player": player,
			"now_ms": now_unix_ms,
		})

	_avatar_ui_layer.items = ui_draw_list
	_avatar_ui_layer.queue_redraw()


func _sort_layer_children() -> void:
	var children := _sort_layer.get_children()
	if children.size() <= 1:
		return
	children.sort_custom(func(a: Node, b: Node) -> bool:
		var da := float(a.get_meta("depth")) if a.has_meta("depth") else 0.0
		var db := float(b.get_meta("depth")) if b.has_meta("depth") else 0.0
		return da < db
	)
	for i in range(children.size()):
		if _sort_layer.get_child(i) != children[i]:
			_sort_layer.move_child(children[i], i)


func _update_atmosphere_and_rain(dt: float) -> void:
	var mode := str(GameStore.layout.get("lightingMode", "day"))
	if mode == "night":
		_night_tint.color = Color("#0b071c", 0.36)
		_night_tint.visible = true
		_glow_container.visible = true
	elif mode == "sunset":
		_night_tint.color = Color("#f59e0b", 0.10)
		_night_tint.visible = true
		_glow_container.visible = true
	else:
		_night_tint.visible = false
		_glow_container.visible = false

	var rain_enabled := bool(GameStore.layout.get("rainEnabled", false))
	_rain_layer.enabled = rain_enabled
	if rain_enabled:
		for drop in _rain_drops:
			var spd := float(drop["speed"])
			drop["x"] = float(drop["x"]) - spd * 0.25 * dt
			drop["y"] = float(drop["y"]) + spd * dt
			if float(drop["y"]) > 650.0 or float(drop["x"]) < -1000.0:
				drop["y"] = -450.0 - randf() * 200.0
				drop["x"] = (randf() - 0.3) * 1800.0
	_rain_layer.queue_redraw()


# ===================================================================
# INTERNAL HELPER DRAWER NODES
# ===================================================================

class _BackdropDrawer extends Node2D:
	var floor_map: Array = []
	var palette: Dictionary = {}
	var has_custom_walls: bool = false
	var build_mode: bool = false
	var grid_w: int = 10
	var grid_h: int = 10

	func _draw() -> void:
		if floor_map.is_empty():
			return

		# Default back walls if layout.walls is absent
		if not has_custom_walls:
			for gy in range(grid_h):
				_draw_tiled_wall_panel(GameData.grid_to_screen(0.0, float(gy)), GameData.grid_to_screen(0.0, float(gy + 1)), true)
			for gx in range(grid_w):
				_draw_tiled_wall_panel(GameData.grid_to_screen(float(gx), 0.0), GameData.grid_to_screen(float(gx + 1), 0.0), false)

		# 3D Diorama Floor Slab + Carpet overlays
		for gy in range(grid_h):
			var row := str(floor_map[gy])
			for gx in range(grid_w):
				var tile := row[gx] if gx < row.length() else "."
				if tile == ".":
					continue
				var c_top := GameData.grid_to_screen(float(gx), float(gy))
				var c_right := GameData.grid_to_screen(float(gx + 1), float(gy))
				var c_bot := GameData.grid_to_screen(float(gx + 1), float(gy + 1))
				var c_left := GameData.grid_to_screen(float(gx), float(gy + 1))

				var has_down_left := false
				if gy + 1 < floor_map.size():
					var nr := str(floor_map[gy + 1])
					has_down_left = gx < nr.length() and nr[gx] != "."
				var has_down_right := (gx + 1 < row.length() and row[gx + 1] != ".")

				if not has_down_left:
					draw_colored_polygon(
						PackedVector2Array([c_left, c_bot, c_bot + Vector2(0, 14), c_left + Vector2(0, 14)]),
						Color("#1a1228")
					)
				if not has_down_right:
					draw_colored_polygon(
						PackedVector2Array([c_bot, c_right, c_right + Vector2(0, 14), c_bot + Vector2(0, 14)]),
						Color("#241938")
					)

				if tile == "C":
					var pts := PackedVector2Array([
						c_top + Vector2(0, 4),
						c_right + Vector2(-6, 0),
						c_bot + Vector2(0, -4),
						c_left + Vector2(6, 0),
					])
					draw_colored_polygon(pts, Color("#f472b6", 0.12))
					draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("#fbcfe8", 0.28), 1.0, true)

		# Build mode grid overlay
		if build_mode:
			var col := Color("#7dd3fc", 0.24)
			for x in range(grid_w + 1):
				draw_line(GameData.grid_to_screen(float(x), 0.0), GameData.grid_to_screen(float(x), float(grid_h)), col, 1.0, true)
			for y in range(grid_h + 1):
				draw_line(GameData.grid_to_screen(0.0, float(y)), GameData.grid_to_screen(float(grid_w), float(y)), col, 1.0, true)

	func _draw_tiled_wall_panel(p0: Vector2, p1: Vector2, is_left: bool) -> void:
		var base_color: Color = palette.get("left" if is_left else "right", Color("#3b2c59"))
		var trim_color: Color = palette.get("trim", Color("#523e7a"))
		var base_board: Color = palette.get("base", Color("#1e1530"))
		var row_h := GameData.WALL_HEIGHT / 3.0
		for r in range(3):
			var y0 := float(r) * row_h
			var y1 := float(r + 1) * row_h
			var pts := PackedVector2Array([
				Vector2(p0.x, p0.y - y0),
				Vector2(p1.x, p1.y - y0),
				Vector2(p1.x, p1.y - y1),
				Vector2(p0.x, p0.y - y1),
			])
			draw_colored_polygon(pts, base_color)
			draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("#090512", 0.24), 1.25, true)
			draw_line(Vector2(p0.x, p0.y - y1 + 1.5), Vector2(p1.x, p1.y - y1 + 1.5), Color(1.0, 1.0, 1.0, 0.08 if is_left else 0.13), 1.0, true)
		draw_line(Vector2(p0.x, p0.y - GameData.WALL_HEIGHT), Vector2(p1.x, p1.y - GameData.WALL_HEIGHT), trim_color, 5.0, true)
		draw_line(Vector2(p0.x, p0.y - 5.0), Vector2(p1.x, p1.y - 5.0), Color(base_board, 0.78), 7.0, true)


class _WallSegmentDrawer extends Node2D:
	var p0: Vector2
	var p1: Vector2
	var is_left: bool = false
	var palette: Dictionary = {}

	func _draw() -> void:
		var base_color: Color = palette.get("left" if is_left else "right", Color("#3b2c59"))
		var trim_color: Color = palette.get("trim", Color("#523e7a"))
		var base_board: Color = palette.get("base", Color("#1e1530"))
		var row_h := GameData.WALL_HEIGHT / 3.0
		for r in range(3):
			var y0 := float(r) * row_h
			var y1 := float(r + 1) * row_h
			var pts := PackedVector2Array([
				Vector2(p0.x, p0.y - y0),
				Vector2(p1.x, p1.y - y0),
				Vector2(p1.x, p1.y - y1),
				Vector2(p0.x, p0.y - y1),
			])
			draw_colored_polygon(pts, base_color)
			draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("#090512", 0.24), 1.25, true)
			draw_line(Vector2(p0.x, p0.y - y1 + 1.5), Vector2(p1.x, p1.y - y1 + 1.5), Color(1.0, 1.0, 1.0, 0.08 if is_left else 0.13), 1.0, true)
		draw_line(Vector2(p0.x, p0.y - GameData.WALL_HEIGHT), Vector2(p1.x, p1.y - GameData.WALL_HEIGHT), trim_color, 5.0, true)
		draw_line(Vector2(p0.x, p0.y - 5.0), Vector2(p1.x, p1.y - 5.0), Color(base_board, 0.78), 7.0, true)


class _HoverCursorDrawer extends Node2D:
	var grid_w: int = 10
	var grid_h: int = 10
	var show_brush_wireframe: bool = false
	var has_floor_brush: bool = false
	var floor_brush_cell: Vector2i = Vector2i.ZERO
	var floor_brush_erase: bool = false
	var has_wall_brush: bool = false
	var wall_brush_cell: Vector2i = Vector2i.ZERO
	var wall_brush_left: bool = false
	var wall_brush_remove: bool = false
	var has_placement_target: bool = false
	var placement_target: Dictionary = {}
	var placement_cat: Dictionary = {}
	var has_hovered_existing: bool = false
	var hovered_item: Dictionary = {}
	var hovered_cat: Dictionary = {}

	func clear_state() -> void:
		has_floor_brush = false
		has_wall_brush = false
		has_placement_target = false
		has_hovered_existing = false

	func _draw() -> void:
		if show_brush_wireframe:
			var wc := Color("#f472b6", 0.16)
			for gy in range(grid_h + 1):
				draw_line(GameData.grid_to_screen(0.0, float(gy)), GameData.grid_to_screen(float(grid_w), float(gy)), wc, 1.0, true)
			for gx in range(grid_w + 1):
				draw_line(GameData.grid_to_screen(float(gx), 0.0), GameData.grid_to_screen(float(gx), float(grid_h)), wc, 1.0, true)

		if has_floor_brush:
			var tx := float(floor_brush_cell.x)
			var ty := float(floor_brush_cell.y)
			var pts := PackedVector2Array([
				GameData.grid_to_screen(tx, ty),
				GameData.grid_to_screen(tx + 1.0, ty),
				GameData.grid_to_screen(tx + 1.0, ty + 1.0),
				GameData.grid_to_screen(tx, ty + 1.0),
			])
			draw_colored_polygon(pts, Color("#fb7185" if floor_brush_erase else "#38bdf8", 0.35))
			draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(1, 1, 1, 0.9), 2.0, true)
		elif has_wall_brush:
			var tx := float(wall_brush_cell.x)
			var ty := float(wall_brush_cell.y)
			var p0 := GameData.grid_to_screen(tx, ty)
			var p1 := GameData.grid_to_screen(tx, ty + 1.0) if wall_brush_left else GameData.grid_to_screen(tx + 1.0, ty)
			var row_h := GameData.WALL_HEIGHT / 3.0
			var fill_c := Color("#fb7185" if wall_brush_remove else "#a78bfa", 0.42)
			for r in range(3):
				var y0 := float(r) * row_h
				var y1 := float(r + 1) * row_h
				var pts := PackedVector2Array([
					Vector2(p0.x, p0.y - y0),
					Vector2(p1.x, p1.y - y0),
					Vector2(p1.x, p1.y - y1),
					Vector2(p0.x, p0.y - y1),
				])
				draw_colored_polygon(pts, fill_c)
				draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(1, 1, 1, 0.85), 1.5, true)
		elif has_placement_target:
			var layer := str(placement_target.get("layer", "floor"))
			var cells: Array = placement_target.get("cells", [])
			if layer == "surface":
				var gx := float(placement_target["gx"])
				var gy := float(placement_target["gy"])
				var e_y := float(placement_target.get("elevationPx", 0.0))
				var r := 0.25
				var pts := PackedVector2Array([
					GameData.grid_to_screen(gx - r, gy - r) - Vector2(0, e_y),
					GameData.grid_to_screen(gx + r, gy - r) - Vector2(0, e_y),
					GameData.grid_to_screen(gx + r, gy + r) - Vector2(0, e_y),
					GameData.grid_to_screen(gx - r, gy + r) - Vector2(0, e_y),
				])
				draw_colored_polygon(pts, Color("#38bdf8", 0.42))
				draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("#e0f2fe"), 2.0, true)
			elif layer == "wall":
				var flipped := bool(placement_target.get("flipped", false))
				var gx := float(placement_target["gx"])
				var gy := float(placement_target["gy"])
				var ox := maxi(0, int(floor(gx)))
				var oy := maxi(0, int(floor(gy)))
				var on_left := true if (ox == 0 and oy > 0) else (false if (oy == 0 and ox > 0) else flipped)
				var row_h := GameData.WALL_HEIGHT / 3.0
				var base_span: Dictionary = placement_cat.get("wallRowSpan", {"start": 1, "end": 1})
				var row_count := maxi(1, int(base_span.get("end", 1)) - int(base_span.get("start", 1)) + 1)
				var start_row := clampi(int(floor(float(placement_target.get("elevationPx", 0.0)) / row_h)), 0, 3 - row_count)
				var end_row := start_row + row_count - 1
				var y0 := float(start_row) * row_h
				var y1 := float(end_row + 1) * row_h
				for c in cells:
					var cgx := float(c["gx"])
					var cgy := float(c["gy"])
					var valid := bool(c["valid"])
					var p0 := GameData.grid_to_screen(cgx, cgy)
					var p1 := GameData.grid_to_screen(cgx, cgy + 1.0) if on_left else GameData.grid_to_screen(cgx + 1.0, cgy)
					var pts := PackedVector2Array([
						Vector2(p0.x, p0.y - y0),
						Vector2(p1.x, p1.y - y0),
						Vector2(p1.x, p1.y - y1),
						Vector2(p0.x, p0.y - y1),
					])
					draw_colored_polygon(pts, Color("#22c55e" if valid else "#ef4444", 0.38 if valid else 0.5))
					draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("#86efac" if valid else "#fca5a5", 0.95), 2.5, true)
			else:
				for c in cells:
					var cgx := float(c["gx"])
					var cgy := float(c["gy"])
					var valid := bool(c["valid"])
					var pts := PackedVector2Array([
						GameData.grid_to_screen(cgx, cgy),
						GameData.grid_to_screen(cgx + 1.0, cgy),
						GameData.grid_to_screen(cgx + 1.0, cgy + 1.0),
						GameData.grid_to_screen(cgx, cgy + 1.0),
					])
					draw_colored_polygon(pts, Color("#22c55e" if valid else "#ef4444", 0.38 if valid else 0.52))
					draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(1, 1, 1, 0.4) if valid else Color("#fca5a5", 0.4), 1.0, true)
				var all_valid := bool(placement_target.get("valid", false))
				var edge_col := Color("#86efac" if all_valid else "#fca5a5", 0.95)
				for edge in GameData.get_footprint_boundary_edges(cells):
					draw_line(
						GameData.grid_to_screen(float(edge["x1"]), float(edge["y1"])),
						GameData.grid_to_screen(float(edge["x2"]), float(edge["y2"])),
						edge_col,
						3.0,
						true
					)
		elif has_hovered_existing:
			var layer := str(hovered_item.get("layer", "floor"))
			var gx := float(hovered_item.get("gx", 0.0))
			var gy := float(hovered_item.get("gy", 0.0))
			var flipped := bool(hovered_item.get("flipped", false))
			if layer == "wall":
				var fp: Dictionary = hovered_cat.get("footprint", {"w": 1, "h": 1})
				var span := maxi(1, int(fp.get("w", 1)))
				var ox := maxi(0, int(floor(gx)))
				var oy := maxi(0, int(floor(gy)))
				var on_left := true if (ox == 0 and oy > 0) else (false if (oy == 0 and ox > 0) else flipped)
				var row_h := GameData.WALL_HEIGHT / 3.0
				var base_span: Dictionary = hovered_cat.get("wallRowSpan", {"start": 1, "end": 1})
				var row_count := maxi(1, int(base_span.get("end", 1)) - int(base_span.get("start", 1)) + 1)
				var elev := float(hovered_item.get("elevationPx", hovered_cat.get("wallElevationPx", 0.0)))
				var start_row := clampi(int(floor(elev / row_h)), 0, 3 - row_count)
				var end_row := start_row + row_count - 1
				var y0 := float(start_row) * row_h
				var y1 := float(end_row + 1) * row_h
				for i in range(span):
					var cgx := float(ox if on_left else ox + i)
					var cgy := float(oy + i if on_left else oy)
					var p0 := GameData.grid_to_screen(cgx, cgy)
					var p1 := GameData.grid_to_screen(cgx, cgy + 1.0) if on_left else GameData.grid_to_screen(cgx + 1.0, cgy)
					var pts := PackedVector2Array([
						Vector2(p0.x, p0.y - y0),
						Vector2(p1.x, p1.y - y0),
						Vector2(p1.x, p1.y - y1),
						Vector2(p0.x, p0.y - y1),
					])
					draw_colored_polygon(pts, Color("#38bdf8", 0.28))
					draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("#7dd3fc", 0.9), 2.5, true)
			elif layer != "surface":
				var cells := GameData.get_item_occupied_cells(hovered_cat, gx, gy, flipped)
				for c in cells:
					var cgx := float(c["gx"])
					var cgy := float(c["gy"])
					var pts := PackedVector2Array([
						GameData.grid_to_screen(cgx, cgy),
						GameData.grid_to_screen(cgx + 1.0, cgy),
						GameData.grid_to_screen(cgx + 1.0, cgy + 1.0),
						GameData.grid_to_screen(cgx, cgy + 1.0),
					])
					draw_colored_polygon(pts, Color("#38bdf8", 0.24))
				for edge in GameData.get_footprint_boundary_edges(cells):
					draw_line(
						GameData.grid_to_screen(float(edge["x1"]), float(edge["y1"])),
						GameData.grid_to_screen(float(edge["x2"]), float(edge["y2"])),
						Color("#7dd3fc", 0.9),
						2.5,
						true
					)


class _EllipseDrawer extends Node2D:
	var rx: float = 20.0
	var ry: float = 8.0
	var color: Color = Color("#090512", 0.35)

	func _draw() -> void:
		var pts := PackedVector2Array()
		for i in range(24):
			var a := float(i) * TAU / 24.0
			pts.append(Vector2(cos(a) * rx, sin(a) * ry))
		draw_colored_polygon(pts, color)


class _AvatarShadowDrawer extends Node2D:
	func _draw() -> void:
		var pts1 := PackedVector2Array()
		var pts2 := PackedVector2Array()
		for i in range(24):
			var a := float(i) * TAU / 24.0
			pts1.append(Vector2(cos(a) * 15.0, 1.0 + sin(a) * 6.5))
			pts2.append(Vector2(cos(a) * 11.0, 1.5 + sin(a) * 4.5))
		draw_colored_polygon(pts1, Color("#090512", 0.35))
		draw_colored_polygon(pts2, Color("#05020a", 0.45))


class _FocusRingDrawer extends Node2D:
	func _draw() -> void:
		var pts := PackedVector2Array()
		for i in range(29):
			var a := float(i % 28) * TAU / 28.0
			pts.append(Vector2(cos(a) * 22.0, 1.0 + sin(a) * 10.0))
		draw_polyline(pts, Color("#f472b6", 0.75), 2.0, true)


class _RainDrawer extends Node2D:
	var enabled: bool = false
	var drops: Array = []

	func _draw() -> void:
		if not enabled:
			return
		var col := Color("#bae6fd", 0.28)
		for drop in drops:
			var x := float(drop["x"])
			var y := float(drop["y"])
			var l := float(drop["len"])
			draw_line(Vector2(x, y), Vector2(x - l * 0.25, y + l), col, 1.2, true)


class _AvatarUiDrawer extends Node2D:
	var ui_font: Font
	var items: Array = []

	func _draw_rounded_rect(rect: Rect2, radius: float, fill_col: Color, border_col: Color = Color.TRANSPARENT, border_w: float = 0.0) -> void:
		var sb := StyleBoxFlat.new()
		sb.bg_color = fill_col
		sb.set_corner_radius_all(int(radius))
		if border_w > 0.0:
			sb.border_color = border_col
			sb.set_border_width_all(int(ceil(border_w)))
		draw_style_box(sb, rect)

	func _draw() -> void:
		if ui_font == null:
			ui_font = ThemeDB.fallback_font
		for entry in items:
			var base: Vector2 = entry["pos"]
			var player: Dictionary = entry["player"]
			var now_ms := int(entry["now_ms"])

			# 1. Nameplate
			var pname := str(player.get("name", "Người chơi"))
			var nsize := ui_font.get_string_size(pname, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
			var badge_w := maxf(64.0, nsize.x + 18.0)
			var border_c := Color.from_string(str(player.get("tintColor", "#f472b6")), Color("#f472b6"))
			_draw_rounded_rect(Rect2(base.x - badge_w * 0.5, base.y - 12.0, badge_w, 22.0), 11.0, Color("#181026", 0.84), border_c, 1.5)
			draw_string(ui_font, Vector2(base.x - nsize.x * 0.5, base.y + 3.5), pname, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

			# 2. Status pill
			var st := str(player.get("statusText", ""))
			if not st.is_empty():
				var st_size := ui_font.get_string_size(st, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
				var st_w := st_size.x + 16.0
				_draw_rounded_rect(Rect2(base.x - st_w * 0.5, base.y - 36.0, st_w, 19.0), 9.0, Color("#1e1530", 0.80))
				draw_string(ui_font, Vector2(base.x - st_size.x * 0.5, base.y - 22.5), st, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#fde68a"))

			# 3. Chat Bubble
			var bubble: Variant = player.get("chatBubble")
			if bubble is Dictionary and int((bubble as Dictionary).get("expiresAt", 0)) > now_ms:
				var text := str((bubble as Dictionary).get("text", ""))
				var para := TextParagraph.new()
				para.width = 175.0
				para.alignment = HORIZONTAL_ALIGNMENT_CENTER
				para.break_flags = TextServer.BREAK_WORD_BOUND | TextServer.BREAK_MANDATORY
				para.add_string(text, ui_font, 12)
				var psize := para.get_size()
				var cw := maxf(52.0, psize.x + 20.0)
				var ch := psize.y + 14.0
				var box_y := base.y - 49.0 - ch + 5.0
				_draw_rounded_rect(Rect2(base.x - cw * 0.5, box_y, cw, ch), 10.0, Color(1, 1, 1, 0.96), Color("#f472b6"), 1.5)
				para.draw(get_canvas_item(), Vector2(base.x - para.width * 0.5, box_y + 7.0), Color("#1e1b2e"))

			# 4. Floating Emote
			var emote: Variant = player.get("emote")
			if emote is Dictionary and int((emote as Dictionary).get("expiresAt", 0)) > now_ms:
				var rem := float(int((emote as Dictionary).get("expiresAt", 0)) - now_ms)
				var float_offset := ((2600.0 - rem) / 2600.0) * 28.0
				var icon := str((emote as Dictionary).get("icon", "❤️"))
				var isize := ui_font.get_string_size(icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
				draw_string(ui_font, Vector2(base.x - isize.x * 0.5, base.y - 48.0 - float_offset), icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
