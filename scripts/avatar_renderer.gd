extends Node

const AVATAR_W: int = 180
const AVATAR_H: int = 240
const OUTLINE_COLOR: Color = Color("#2b1810")

var _tex_cache: Dictionary = {}


func _hex_to_rgb255(hex_str: String) -> Vector3i:
	var c := Color.from_string(hex_str, Color("#f3d2b3"))
	return Vector3i(roundi(c.r * 255.0), roundi(c.g * 255.0), roundi(c.b * 255.0))


func _shade_color(hex_str: String, factor: float) -> Color:
	var rgb := _hex_to_rgb255(hex_str)
	var r := clampf(roundf(float(rgb.x) * factor) / 255.0, 0.0, 1.0)
	var g := clampf(roundf(float(rgb.y) * factor) / 255.0, 0.0, 1.0)
	var b := clampf(roundf(float(rgb.z) * factor) / 255.0, 0.0, 1.0)
	return Color(r, g, b, 1.0)


func _draw_px(img: Image, gx: float, gy: float, gw: float, gh: float, col: Color) -> void:
	var x0 := roundi(gx * 3.0)
	var y0 := roundi(gy * 3.0)
	var w := roundi(gw * 3.0)
	var h := roundi(gh * 3.0)
	if w <= 0 or h <= 0:
		return

	var x_start := maxi(0, x0)
	var y_start := maxi(0, y0)
	var x_end := mini(AVATAR_W, x0 + w)
	var y_end := mini(AVATAR_H, y0 + h)
	if x_start >= x_end or y_start >= y_end:
		return

	if col.a >= 0.999:
		img.fill_rect(Rect2i(x_start, y_start, x_end - x_start, y_end - y_start), col)
	else:
		for py in range(y_start, y_end):
			for px_x in range(x_start, x_end):
				var dst := img.get_pixel(px_x, py)
				var out_a := col.a + dst.a * (1.0 - col.a)
				if out_a <= 0.0001:
					continue
				var out_r := (col.r * col.a + dst.r * dst.a * (1.0 - col.a)) / out_a
				var out_g := (col.g * col.a + dst.g * dst.a * (1.0 - col.a)) / out_a
				var out_b := (col.b * col.a + dst.b * dst.a * (1.0 - col.a)) / out_a
				img.set_pixel(px_x, py, Color(out_r, out_g, out_b, out_a))


func parse_frame_context(frame_path: String) -> Dictionary:
	var is_back := frame_path.contains("_nw")
	var is_sitting := frame_path.contains("sit_")
	var walk_frame := -1
	var regex := RegEx.new()
	regex.compile("walk_(?:se|nw)_(\\d)")
	var m := regex.search(frame_path)
	if m != null:
		walk_frame = int(m.get_string(1))
	return {
		"isBack": is_back,
		"isSitting": is_sitting,
		"walkFrame": walk_frame,
	}


func get_custom_avatar_texture(frame_path: String, config: Dictionary) -> Texture2D:
	var cfg := GameData.DEFAULT_CUSTOM_AVATAR.duplicate()
	for k in config.keys():
		cfg[k] = config[k]

	var cache_key := "%s|%s" % [frame_path, JSON.stringify(cfg)]
	if _tex_cache.has(cache_key):
		return _tex_cache[cache_key]

	var base_img := GameData.get_image(frame_path)
	if base_img == null or base_img.is_empty():
		return GameData.get_texture(frame_path)

	var frame_ctx := parse_frame_context(frame_path)
	var hair_style := str(cfg.get("hairStyle", "girl_long"))
	var hair_path := GameData.get_hair_sprite_path(hair_style, bool(frame_ctx["isBack"]))
	var hair_img: Image = GameData.get_image(hair_path) if not hair_path.is_empty() else null

	var rendered_img := render_custom_avatar_to_image(base_img, cfg, frame_ctx, hair_img)
	rendered_img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(rendered_img)

	if _tex_cache.size() > 350:
		_tex_cache.clear()
	_tex_cache[cache_key] = tex
	return tex


func render_custom_avatar_to_image(
	base_img: Image,
	config: Dictionary,
	frame_ctx: Dictionary,
	hair_img: Image = null
) -> Image:
	var img := Image.create(AVATAR_W, AVATAR_H, false, Image.FORMAT_RGBA8)
	var src_w := mini(AVATAR_W, base_img.get_width())
	var src_h := mini(AVATAR_H, base_img.get_height())
	img.blit_rect(base_img, Rect2i(0, 0, src_w, src_h), Vector2i.ZERO)

	var default_skin := "#f3d2b3"
	var ref_skin := _hex_to_rgb255(default_skin)
	var sr := float(ref_skin.x)
	var sg := float(ref_skin.y)
	var sb := float(ref_skin.z)

	var skin_hex := str(config.get("skinTone", default_skin))
	var skin_rgb := _hex_to_rgb255(skin_hex)
	var top_hex := str(config.get("topColor", "#a78bfa"))
	var top_rgb := _hex_to_rgb255(top_hex)
	var bot_rgb := _hex_to_rgb255(str(config.get("bottomColor", "#334155")))
	var shoe_rgb := _hex_to_rgb255(str(config.get("shoeColor", "#f8fafc")))

	var is_sitting := bool(frame_ctx.get("isSitting", false))
	var is_back := bool(frame_ctx.get("isBack", false))
	var torso_end := 156 if is_sitting else 162
	var leg_end := 196 if is_sitting else 214
	var recolor_skin := skin_hex.to_lower() != default_skin
	var top_style := str(config.get("topStyle", "hoodie"))

	for py in range(AVATAR_H):
		for px_x in range(AVATAR_W):
			var c := img.get_pixel(px_x, py)
			var a8 := roundi(c.a * 255.0)
			if a8 < 20:
				continue
			var r8 := roundi(c.r * 255.0)
			var g8 := roundi(c.g * 255.0)
			var b8 := roundi(c.b * 255.0)
			if r8 < 85 and g8 < 68 and b8 < 64:
				continue

			var has_target := false
			var target := Vector3i.ZERO
			if py <= 108:
				if recolor_skin:
					target = skin_rgb
					has_target = true
			elif py <= torso_end:
				var is_hand := py >= 150 and (px_x < 65 or px_x > 120)
				var is_tshirt_arm := top_style == "tshirt" and py >= 132 and (px_x < 66 or px_x > 119)
				if is_hand or is_tshirt_arm:
					if recolor_skin:
						target = skin_rgb
						has_target = true
				else:
					target = top_rgb
					has_target = true
			elif py <= leg_end:
				var is_hand := py <= 180 and (px_x < 65 or px_x > 119)
				if is_hand:
					if recolor_skin:
						target = skin_rgb
						has_target = true
				elif top_style == "dress" and py <= 185:
					target = top_rgb
					has_target = true
				else:
					target = bot_rgb
					has_target = true
			else:
				target = shoe_rgb
				has_target = true

			if has_target:
				var nr := clampf(roundf((float(r8) / sr) * float(target.x)) / 255.0, 0.0, 1.0)
				var ng := clampf(roundf((float(g8) / sg) * float(target.y)) / 255.0, 0.0, 1.0)
				var nb := clampf(roundf((float(b8) / sb) * float(target.z)) / 255.0, 0.0, 1.0)
				img.set_pixel(px_x, py, Color(nr, ng, nb, c.a))

	# Head & body anchor offsets (in 3px grid units: 60x80 grid!)
	var hx := 29.5 if is_sitting else 31.0
	var hy := 21.0
	var bx := 29.5 if is_sitting else 31.0
	var by := 38.0

	var top_dark := _shade_color(top_hex, 0.72)
	var top_light := _shade_color(top_hex, 1.15)
	var hair_color_cfg := str(config.get("hairColor", "original"))
	var hair_hex := "#5c3a21" if hair_color_cfg == "original" else hair_color_cfg
	var hair_col := Color.from_string(hair_hex, Color("#5c3a21"))
	var hair_dark := _shade_color(hair_hex, 0.7)
	var hair_light := _shade_color(hair_hex, 1.2)

	# 2. Subtle clothing surface details
	if not is_back:
		if top_style == "hoodie":
			_draw_px(img, bx - 2.0, by + 2.0, 1.0, 4.0, Color("#f8fafc"))
			_draw_px(img, bx + 2.0, by + 2.0, 1.0, 4.0, Color("#f8fafc"))
			_draw_px(img, bx - 4.0, by + 9.0, 8.0, 3.0, top_dark)
		elif top_style == "cardigan":
			_draw_px(img, bx - 1.0, by + 1.0, 3.0, 12.0, Color("#f8fafc"))
			_draw_px(img, bx, by + 3.0, 1.0, 1.0, OUTLINE_COLOR)
			_draw_px(img, bx, by + 7.0, 1.0, 1.0, OUTLINE_COLOR)
			_draw_px(img, bx, by + 11.0, 1.0, 1.0, OUTLINE_COLOR)
		elif top_style == "sweater":
			_draw_px(img, bx - 4.0, by + 1.0, 8.0, 2.0, top_light)
			_draw_px(img, bx - 5.0, by + 12.0, 10.0, 2.0, top_light)

	# 4. Face (Eyes & Blush)
	if not is_back:
		var ey := hy + 1.0
		var ex_l := hx - 2.0
		var ex_r := hx + 5.0

		if bool(config.get("blush", true)):
			_draw_px(img, ex_l - 2.0, ey + 3.0, 2.0, 1.0, Color("#fb7185"))
			_draw_px(img, ex_r + 1.0, ey + 3.0, 2.0, 1.0, Color("#fb7185"))

		var eye_style := str(config.get("eyeStyle", "cute"))
		if eye_style == "cute":
			_draw_px(img, ex_l, ey, 2.0, 3.0, Color("#1e1b4b"))
			_draw_px(img, ex_l, ey, 1.0, 1.0, Color.WHITE)
			_draw_px(img, ex_r, ey, 2.0, 3.0, Color("#1e1b4b"))
			_draw_px(img, ex_r, ey, 1.0, 1.0, Color.WHITE)
		elif eye_style == "happy":
			_draw_px(img, ex_l, ey + 1.0, 2.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_l - 1.0, ey + 2.0, 1.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_r, ey + 1.0, 2.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_r + 2.0, ey + 2.0, 1.0, 1.0, Color("#1e1b4b"))
		elif eye_style == "cool":
			_draw_px(img, ex_l - 1.0, ey, 3.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_l, ey + 1.0, 2.0, 2.0, Color("#1e1b4b"))
			_draw_px(img, ex_r, ey, 3.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_r, ey + 1.0, 2.0, 2.0, Color("#1e1b4b"))
		elif eye_style == "sleepy":
			_draw_px(img, ex_l, ey + 1.0, 3.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_l + 1.0, ey + 2.0, 1.0, 1.0, Color("#312e81"))
			_draw_px(img, ex_r, ey + 1.0, 3.0, 1.0, Color("#1e1b4b"))
			_draw_px(img, ex_r + 1.0, ey + 2.0, 1.0, 1.0, Color("#312e81"))
		elif eye_style == "wink":
			_draw_px(img, ex_l, ey, 2.0, 3.0, Color("#1e1b4b"))
			_draw_px(img, ex_l, ey, 1.0, 1.0, Color.WHITE)
			_draw_px(img, ex_r, ey + 1.0, 3.0, 1.0, Color("#1e1b4b"))

	# 5. Hair Layer
	var hair_style := str(config.get("hairStyle", "girl_long"))
	if hair_img != null and not hair_img.is_empty():
		var dx := -4 if is_sitting else 0
		var work_hair := Image.create(AVATAR_W, AVATAR_H, false, Image.FORMAT_RGBA8)
		var hw := mini(AVATAR_W, hair_img.get_width())
		var hh := mini(AVATAR_H, hair_img.get_height())
		work_hair.blit_rect(hair_img, Rect2i(0, 0, hw, hh), Vector2i.ZERO)

		if hair_color_cfg != "original":
			var tr := _hex_to_rgb255(hair_hex)
			for hy_px in range(AVATAR_H):
				for hx_px in range(AVATAR_W):
					var hc := work_hair.get_pixel(hx_px, hy_px)
					if roundi(hc.a * 255.0) < 20:
						continue
					var hr8 := roundi(hc.r * 255.0)
					var hg8 := roundi(hc.g * 255.0)
					var hb8 := roundi(hc.b * 255.0)
					if hr8 < 32 and hg8 < 32 and hb8 < 32:
						continue
					var lum := (0.299 * float(hr8) + 0.587 * float(hg8) + 0.114 * float(hb8)) / 140.0
					var factor := clampf(lum, 0.35, 1.45)
					var nr := clampf(roundf(float(tr.x) * factor) / 255.0, 0.0, 1.0)
					var ng := clampf(roundf(float(tr.y) * factor) / 255.0, 0.0, 1.0)
					var nb := clampf(roundf(float(tr.z) * factor) / 255.0, 0.0, 1.0)
					work_hair.set_pixel(hx_px, hy_px, Color(nr, ng, nb, hc.a))

		if dx < 0:
			var shift := -dx
			img.blend_rect(work_hair, Rect2i(shift, 0, AVATAR_W - shift, AVATAR_H), Vector2i.ZERO)
		else:
			img.blend_rect(work_hair, Rect2i(0, 0, AVATAR_W - dx, AVATAR_H), Vector2i(dx, 0))
	elif hair_style != "none":
		if is_back:
			_draw_px(img, hx - 12.0, hy - 14.0, 24.0, 18.0, OUTLINE_COLOR)
			_draw_px(img, hx - 11.0, hy - 13.0, 22.0, 16.0, hair_col)
			_draw_px(img, hx - 9.0, hy - 11.0, 18.0, 3.0, hair_light)
			_draw_px(img, hx - 11.0, hy, 22.0, 4.0, hair_dark)
		else:
			_draw_px(img, hx - 12.0, hy - 15.0, 24.0, 10.0, OUTLINE_COLOR)
			_draw_px(img, hx - 11.0, hy - 14.0, 22.0, 8.0, hair_col)
			_draw_px(img, hx - 7.0, hy - 12.0, 14.0, 2.0, hair_light)
			_draw_px(img, hx - 12.0, hy - 7.0, 5.0, 11.0, OUTLINE_COLOR)
			_draw_px(img, hx - 11.0, hy - 7.0, 3.0, 10.0, hair_col)
			_draw_px(img, hx - 8.0, hy - 6.0, 18.0, 4.0, OUTLINE_COLOR)
			_draw_px(img, hx - 7.0, hy - 6.0, 16.0, 3.0, hair_col)

		if hair_style == "spiky":
			_draw_px(img, hx - 10.0, hy - 18.0, 4.0, 4.0, hair_col)
			_draw_px(img, hx - 2.0, hy - 19.0, 5.0, 5.0, hair_col)
			_draw_px(img, hx + 6.0, hy - 17.0, 4.0, 4.0, hair_col)
		elif hair_style == "bob":
			_draw_px(img, hx - 13.0, hy - 2.0, 5.0, 14.0, OUTLINE_COLOR)
			_draw_px(img, hx - 12.0, hy - 2.0, 3.0, 13.0, hair_col)
			if is_back:
				_draw_px(img, hx - 11.0, hy + 2.0, 22.0, 8.0, hair_col)
		elif hair_style == "long":
			_draw_px(img, hx - 13.0, hy - 2.0, 5.0, 22.0, OUTLINE_COLOR)
			_draw_px(img, hx - 12.0, hy - 2.0, 3.0, 20.0, hair_col)
			if is_back:
				_draw_px(img, hx - 11.0, hy + 2.0, 22.0, 18.0, OUTLINE_COLOR)
				_draw_px(img, hx - 10.0, hy + 2.0, 20.0, 17.0, hair_col)
		elif hair_style == "ponytail":
			_draw_px(img, hx - 15.0, hy - 10.0, 5.0, 14.0, OUTLINE_COLOR)
			_draw_px(img, hx - 14.0, hy - 9.0, 3.0, 12.0, hair_col)
			_draw_px(img, hx - 13.0, hy - 10.0, 2.0, 2.0, Color("#f472b6"))
		elif hair_style == "bun":
			_draw_px(img, hx - 5.0, hy - 20.0, 10.0, 6.0, OUTLINE_COLOR)
			_draw_px(img, hx - 4.0, hy - 19.0, 8.0, 4.0, hair_col)
			_draw_px(img, hx - 2.0, hy - 18.0, 4.0, 1.0, hair_light)

	# 6. Accessories
	var acc := str(config.get("accessory", "none"))
	if acc == "headphones":
		_draw_px(img, hx - 11.0, hy - 16.0, 22.0, 3.0, OUTLINE_COLOR)
		_draw_px(img, hx - 10.0, hy - 15.0, 20.0, 2.0, Color("#38bdf8"))
		_draw_px(img, hx - 14.0, hy - 4.0, 5.0, 8.0, OUTLINE_COLOR)
		_draw_px(img, hx - 13.0, hy - 3.0, 3.0, 6.0, Color("#38bdf8"))
		if not is_back:
			_draw_px(img, hx + 11.0, hy - 4.0, 3.0, 7.0, OUTLINE_COLOR)
			_draw_px(img, hx + 11.0, hy - 3.0, 2.0, 5.0, Color("#0284c7"))
	elif acc == "cat_ears":
		_draw_px(img, hx - 10.0, hy - 20.0, 5.0, 6.0, OUTLINE_COLOR)
		_draw_px(img, hx - 9.0, hy - 19.0, 3.0, 4.0, Color("#f472b6"))
		_draw_px(img, hx + 5.0, hy - 20.0, 5.0, 6.0, OUTLINE_COLOR)
		_draw_px(img, hx + 6.0, hy - 19.0, 3.0, 4.0, Color("#f472b6"))
	elif acc == "cap":
		_draw_px(img, hx - 12.0, hy - 16.0, 24.0, 8.0, OUTLINE_COLOR)
		_draw_px(img, hx - 11.0, hy - 15.0, 22.0, 6.0, Color("#fb7185"))
		if not is_back:
			_draw_px(img, hx - 2.0, hy - 10.0, 17.0, 3.0, OUTLINE_COLOR)
			_draw_px(img, hx - 1.0, hy - 9.0, 15.0, 2.0, Color("#e11d48"))
	elif acc == "beanie":
		_draw_px(img, hx - 12.0, hy - 17.0, 24.0, 9.0, OUTLINE_COLOR)
		_draw_px(img, hx - 11.0, hy - 16.0, 22.0, 7.0, Color("#fbbf24"))
		_draw_px(img, hx - 12.0, hy - 11.0, 24.0, 3.0, Color("#d97706"))
		_draw_px(img, hx - 3.0, hy - 20.0, 6.0, 4.0, OUTLINE_COLOR)
		_draw_px(img, hx - 2.0, hy - 19.0, 4.0, 2.0, Color("#fef3c7"))
	elif acc == "glasses" and not is_back:
		var ey := hy + 1.0
		_draw_px(img, hx - 4.0, ey - 1.0, 5.0, 4.0, OUTLINE_COLOR)
		_draw_px(img, hx - 3.0, ey, 3.0, 2.0, Color(186.0 / 255.0, 230.0 / 255.0, 253.0 / 255.0, 0.45))
		_draw_px(img, hx + 1.0, ey, 3.0, 1.0, OUTLINE_COLOR)
		_draw_px(img, hx + 4.0, ey - 1.0, 5.0, 4.0, OUTLINE_COLOR)
		_draw_px(img, hx + 5.0, ey, 3.0, 2.0, Color(186.0 / 255.0, 230.0 / 255.0, 253.0 / 255.0, 0.45))
	elif acc == "bow":
		_draw_px(img, hx - 12.0, hy - 14.0, 7.0, 5.0, OUTLINE_COLOR)
		_draw_px(img, hx - 11.0, hy - 13.0, 5.0, 3.0, Color("#f472b6"))

	return img
