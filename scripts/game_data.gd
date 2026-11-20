extends Node

const TILE_W: float = 120.0
const TILE_H: float = 60.0
const WALL_HEIGHT: float = 195.0

const SERVER_URL: String = "https://cozy-focus-server-production.up.railway.app"
const GOOGLE_CLIENT_ID: String = "743759840913-cr689blpjcct1t6cb6e6cibjusdgavc7.apps.googleusercontent.com"

const WALL_PALETTES: Dictionary = {
	"lofi_purple": {
		"left": Color("#3b2c59"),
		"right": Color("#2e2147"),
		"trim": Color("#523e7a"),
		"base": Color("#1e1530"),
	},
	"cream": {
		"left": Color("#d6c7b2"),
		"right": Color("#c2b19a"),
		"trim": Color("#efe5d6"),
		"base": Color("#8f7e6a"),
	},
	"sage": {
		"left": Color("#6b8c7c"),
		"right": Color("#567365"),
		"trim": Color("#8fb0a0"),
		"base": Color("#3a4f45"),
	},
	"brick": {
		"left": Color("#8f4f49"),
		"right": Color("#733c37"),
		"trim": Color("#b36c64"),
		"base": Color("#4a2522"),
	},
}

const DEFAULT_CUSTOM_AVATAR: Dictionary = {
	"skinTone": "#f3d2b3",
	"hairStyle": "girl_long",
	"hairColor": "original",
	"eyeStyle": "cute",
	"blush": true,
	"topStyle": "hoodie",
	"topColor": "#a78bfa",
	"bottomColor": "#334155",
	"shoeColor": "#f8fafc",
	"accessory": "none",
}

const SKIN_TONES: Array = [
	{"label": "Sáng hồng", "color": "#fbe0cc"},
	{"label": "Tự nhiên", "color": "#f3d2b3"},
	{"label": "Ấm áp", "color": "#e5b88b"},
	{"label": "Mật ong", "color": "#c98e5b"},
	{"label": "Nâu ấm", "color": "#9c643c"},
	{"label": "Pastel", "color": "#e2d4f0"},
]

const SPRITE_HAIR_STYLES: Array = [
	"girl_long",
	"girl_ponytail",
	"girl_bob",
]

const HAIR_STYLES: Array = [
	{"id": "girl_long", "label": "Nữ tóc dài"},
	{"id": "girl_ponytail", "label": "Nữ buộc cao"},
	{"id": "girl_bob", "label": "Nữ tóc ngắn"},
	{"id": "short", "label": "Tóc ngắn"},
	{"id": "bob", "label": "Tóc bob"},
	{"id": "ponytail", "label": "Đuôi ngựa"},
	{"id": "spiky", "label": "Tóc dựng"},
	{"id": "bun", "label": "Búi củ tỏi"},
	{"id": "long", "label": "Tóc dài"},
	{"id": "none", "label": "Tối giản"},
]

const HAIR_COLORS: Array = [
	"original",
	"#272026",
	"#5c3a21",
	"#c48a47",
	"#f472b6",
	"#a78bfa",
	"#38bdf8",
	"#34d399",
	"#e2e8f0",
	"#be123c",
]

const EYE_STYLES: Array = [
	{"id": "cute", "label": "Tròn cute"},
	{"id": "happy", "label": "Mắt cười"},
	{"id": "cool", "label": "Ngầu"},
	{"id": "sleepy", "label": "Buồn ngủ"},
	{"id": "wink", "label": "Nháy mắt"},
]

const TOP_STYLES: Array = [
	{"id": "hoodie", "label": "Hoodie"},
	{"id": "tshirt", "label": "Áo phông"},
	{"id": "sweater", "label": "Áo len"},
	{"id": "cardigan", "label": "Cardigan"},
	{"id": "dress", "label": "Váy liền"},
]

const CLOTHING_COLORS: Array = [
	"#f472b6",
	"#a78bfa",
	"#38bdf8",
	"#34d399",
	"#fbbf24",
	"#fb7185",
	"#334155",
	"#1e293b",
	"#f8fafc",
	"#7c2d12",
]

const ACCESSORIES: Array = [
	{"id": "none", "label": "Không"},
	{"id": "headphones", "label": "Tai nghe"},
	{"id": "cat_ears", "label": "Tai mèo"},
	{"id": "cap", "label": "Mũ lưỡi trai"},
	{"id": "beanie", "label": "Mũ len"},
	{"id": "glasses", "label": "Kính cận"},
	{"id": "bow", "label": "Nơ xinh"},
]

const ISO_CHARACTER_IDS: Array = [
	"custom", "c1", "c2", "c3", "c4", "c5", "c6",
	"c7", "c8", "c9", "c10", "c11", "c12",
]

const CHARACTER_SKINS: Array = [
	{
		"id": "custom",
		"name": "Tự Tạo Avatar",
		"subtitle": "Tùy biến tóc, mắt, áo & phụ kiện",
		"avatar": "res://sprites/characters/base/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c7",
		"name": "Kaito",
		"subtitle": "Tóc tím • Hoodie xanh rêu",
		"avatar": "res://sprites/characters/c7/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c8",
		"name": "Bách",
		"subtitle": "Tóc xoăn • Cardigan vàng",
		"avatar": "res://sprites/characters/c8/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c9",
		"name": "Sora",
		"subtitle": "Tóc bạch kim • Áo Varsity",
		"avatar": "res://sprites/characters/c9/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c10",
		"name": "Na",
		"subtitle": "Tóc đuôi ngựa • Áo hồng phấn",
		"avatar": "res://sprites/characters/c10/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c11",
		"name": "Hân",
		"subtitle": "Kính tròn • Ghi-lê nâu",
		"avatar": "res://sprites/characters/c11/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c12",
		"name": "An",
		"subtitle": "Tóc tết • Khoác bò xanh",
		"avatar": "res://sprites/characters/c12/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c1",
		"name": "Minh",
		"subtitle": "Tóc đen • Áo len kem",
		"avatar": "res://sprites/characters/c1/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c2",
		"name": "Khoa",
		"subtitle": "Tóc nâu rẽ ngôi • Điềm đạm",
		"avatar": "res://sprites/characters/c2/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c3",
		"name": "Leo",
		"subtitle": "Tóc vàng • Kính tròn",
		"avatar": "res://sprites/characters/c3/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c4",
		"name": "Linh",
		"subtitle": "Tóc đen dài • Dịu dàng",
		"avatar": "res://sprites/characters/c4/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c5",
		"name": "Vy",
		"subtitle": "Tóc bob nâu • Ấm áp",
		"avatar": "res://sprites/characters/c5/avatar.png",
		"isModularIso": true,
	},
	{
		"id": "c6",
		"name": "Miu",
		"subtitle": "Tóc búi • Kính tròn",
		"avatar": "res://sprites/characters/c6/avatar.png",
		"isModularIso": true,
	},
]

const CATALOG_ITEMS: Array = [
	# ===================================================================
	# 1. PHÒNG KHÁCH & CẤU TRÚC (LIVING ROOM & ENTRYWAY)
	# ===================================================================
	{
		"id": "main_door_b",
		"name": "Cửa Chính (Quay Trái)",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/interior/main_door_b_closed.png",
		"altSprite": "res://sprites/interior/main_door_b_open_wide.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 1.35,
		"description": "Cửa chính căn hộ thông minh (Bấm để mở/đóng cửa).",
	},
	{
		"id": "main_door_t",
		"name": "Cửa Chính (Quay Phải)",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/interior/main_door_t_closed.png",
		"altSprite": "res://sprites/interior/main_door_t_open_wide.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 1.35,
		"description": "Cửa chính hướng đối diện (Bấm để mở/đóng cửa).",
	},
	{
		"id": "sofa_iso",
		"name": "Sofa Nỉ Góc Nghiêng",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/sofa_iso.png",
		"footprint": {"w": 2, "h": 1},
		"footprintCells": [
			{"dx": 0, "dy": 0},
			{"dx": 1, "dy": 0},
		],
		"scale": 0.76,
		"seatSlots": [
			{"id": "sofa_1", "offsetGx": -0.42, "offsetGy": 0.14, "activity": "chill_sofa", "label": "Ngồi Chill (Trái)", "facing": "sw"},
			{"id": "sofa_2", "offsetGx": 0.42, "offsetGy": 0.14, "activity": "chill_sofa", "label": "Ngồi Chill (Phải)", "facing": "sw"},
		],
		"description": "Ghế sofa 2 người ngồi chill cùng nhau.",
	},
	{
		"id": "sofa_straight",
		"name": "Sofa Băng Ngang",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/sofa_straight.png",
		"footprint": {"w": 2, "h": 1},
		"scale": 0.68,
		"seatSlots": [
			{"id": "sofa_s1", "offsetGx": -0.4, "offsetGy": 0.1, "activity": "chill_sofa", "label": "Ngồi Sofa (Trái)", "facing": "se"},
			{"id": "sofa_s2", "offsetGx": 0.4, "offsetGy": 0.1, "activity": "chill_sofa", "label": "Ngồi Sofa (Phải)", "facing": "se"},
		],
		"description": "Ghế sofa ngang êm ái cho góc phòng khách.",
	},
	{
		"id": "table_glass_round_1",
		"name": "Bàn Trà Kính Tròn",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/table_glass_round_1.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.65,
		"isSurface": true,
		"surfaceHeightPx": 30,
		"description": "Bàn trà kính: có thể đặt đồ trang trí nhỏ lên mặt bàn!",
	},
	{
		"id": "table_glass_round_2",
		"name": "Bàn Kính Thấp",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/table_glass_round_2.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.7,
		"isSurface": true,
		"surfaceHeightPx": 18,
		"description": "Bàn trà thấp đặt được đồ decor lên trên.",
	},
	{
		"id": "cabinet_tall",
		"name": "Tủ Đồ Cao",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/cabinet_tall.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.72,
		"isSurface": true,
		"surfaceHeightPx": 66,
		"description": "Tủ đứng chứa đồ phòng khách.",
	},
	{
		"id": "cabinet_shoes",
		"name": "Kệ Giày Sảnh Vào",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/cabinet_shoes.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.72,
		"isSurface": true,
		"surfaceHeightPx": 26,
		"description": "Kệ giày nhỏ gọn cạnh cửa ra vào.",
	},
	{
		"id": "metal_shelf",
		"name": "Kệ Sắt Đứng",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/metal_shelf.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.72,
		"isSurface": true,
		"surfaceHeightPx": 42,
		"description": "Kệ khung sắt đa năng để cây và phụ kiện.",
	},
	{
		"id": "watermelon_mat",
		"name": "Thảm Dưa Hấu",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/watermelon_mat.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.75,
		"walkable": true,
		"seatSlots": [
			{"id": "mat_1", "offsetGx": 0, "offsetGy": 0, "activity": "sit_floor", "label": "Ngồi Bệt Trên Thảm", "facing": "se"},
		],
		"description": "Thảm tròn dưa hấu êm ái — có thể đi lên hoặc ngồi chill.",
	},
	{
		"id": "altar",
		"name": "Bàn Thờ Ấm Cúng",
		"category": "living_room",
		"placement": "floor",
		"sprite": "res://sprites/living_room/altar.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.72,
		"isSurface": true,
		"surfaceHeightPx": 46,
		"lightEmitter": {"color": 0xffb347, "radius": 110, "intensity": 0.65, "offsetY": -50},
		"description": "Bàn thờ trang nghiêm tỏa ánh sáng ấm ban đêm.",
	},
	{
		"id": "window_curtains",
		"name": "Cửa Sổ Rèm Vải",
		"category": "living_room",
		"placement": "wall",
		"sprite": "res://sprites/living_room/window_curtains.png",
		"footprint": {"w": 2, "h": 1},
		"scale": 0.72,
		"wallElevationPx": 68,
		"wallRowSpan": {"start": 1, "end": 2},
		"lightEmitter": {"color": 0x93c5fd, "radius": 150, "intensity": 0.45, "offsetY": -65},
		"description": "Cửa sổ lớn có rèm trang trí treo tường.",
	},
	{
		"id": "sunburst_clock",
		"name": "Đồng Hồ Mặt Trời",
		"category": "living_room",
		"placement": "wall",
		"sprite": "res://sprites/living_room/sunburst_clock.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.55,
		"wallElevationPx": 75,
		"wallRowSpan": {"start": 1, "end": 1},
		"description": "Đồng hồ treo tường trang trí vintage.",
	},

	# ===================================================================
	# 2. GÓC HỌC TẬP & LÀM VIỆC (WORKSPACE / CO-FOCUS)
	# ===================================================================
	{
		"id": "double_desk",
		"name": "Bàn Làm Việc Đôi",
		"category": "workspace",
		"placement": "floor",
		"sprite": "res://sprites/workspace/double_desk.png",
		"footprint": {"w": 1, "h": 3},
		"footprintCells": [
			{"dx": 0, "dy": 0},
			{"dx": 0, "dy": 1},
			{"dx": 0, "dy": 2},
		],
		"scale": 0.52,
		"isSurface": true,
		"surfaceHeightPx": 44,
		"lightEmitter": {"color": 0xffd166, "radius": 180, "intensity": 0.55, "offsetY": -65},
		"description": "Bàn làm việc đôi rộng rãi — đặt laptop, màn hình, đèn lên mặt bàn!",
	},
	{
		"id": "chair_front",
		"name": "Ghế Học Tập (Chính Diện)",
		"category": "workspace",
		"placement": "floor",
		"sprite": "res://sprites/workspace/chair_front.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.38,
		"seatSlots": [
			{"id": "chair_f1", "offsetGx": 0, "offsetGy": 0.05, "activity": "focus_desk", "label": "Ngồi Focus", "facing": "nw"},
		],
		"description": "Ghế ngồi học — bấm vào để vào trạng thái Focus!",
	},
	{
		"id": "chair_side",
		"name": "Ghế Xoay (Góc Nghiêng)",
		"category": "workspace",
		"placement": "floor",
		"sprite": "res://sprites/workspace/chair_side.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.38,
		"seatSlots": [
			{"id": "chair_s1", "offsetGx": 0, "offsetGy": 0.05, "activity": "focus_desk", "label": "Ngồi Focus", "facing": "nw"},
		],
		"description": "Ghế ngồi làm việc góc nghiêng.",
	},
	{
		"id": "chair_back",
		"name": "Ghế Ngồi (Quay Sau)",
		"category": "workspace",
		"placement": "floor",
		"sprite": "res://sprites/workspace/chair_back.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.38,
		"seatSlots": [
			{"id": "chair_b1", "offsetGx": 0, "offsetGy": 0.05, "activity": "focus_desk", "label": "Ngồi Focus", "facing": "se"},
		],
		"description": "Ghế làm việc quay mặt về phía camera.",
	},
	{
		"id": "monitors",
		"name": "Màn Hình Kép Setup",
		"category": "workspace",
		"placement": "surface",
		"sprite": "res://sprites/workspace/monitors.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.36,
		"lightEmitter": {"color": 0x7dd3fc, "radius": 130, "intensity": 0.7, "offsetY": -22},
		"description": "Đặt lên mặt bàn — tỏa ánh sáng màn hình dịu nhẹ ban đêm.",
	},
	{
		"id": "laptops",
		"name": "Laptop Học Bài",
		"category": "workspace",
		"placement": "surface",
		"sprite": "res://sprites/workspace/laptops.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.36,
		"lightEmitter": {"color": 0xbae6fd, "radius": 110, "intensity": 0.65, "offsetY": -18},
		"description": "Laptop đặt trên bàn làm việc hoặc bàn trà.",
	},
	{
		"id": "mouse_keyboards",
		"name": "Bộ Bàn Phím Cơ & Chuột",
		"category": "workspace",
		"placement": "surface",
		"sprite": "res://sprites/workspace/mouse_keyboards.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.34,
		"description": "Phụ kiện gõ phím ASMR đặt lên mặt bàn.",
	},
	{
		"id": "ac_unit",
		"name": "Điều Hòa Treo Tường",
		"category": "workspace",
		"placement": "wall",
		"sprite": "res://sprites/workspace/ac_unit.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.65,
		"wallElevationPx": 132,
		"wallRowSpan": {"start": 2, "end": 2},
		"description": "Máy lạnh treo tường phía trên bàn làm việc.",
	},
	{
		"id": "pegboard",
		"name": "Bảng Pegboard Treo Đồ",
		"category": "workspace",
		"placement": "wall",
		"sprite": "res://sprites/workspace/pegboard.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.62,
		"wallElevationPx": 72,
		"wallRowSpan": {"start": 1, "end": 1},
		"description": "Bảng gỗ treo tường đựng tai nghe, note, bút.",
	},
	{
		"id": "wire_grid",
		"name": "Khung Lưới Ảnh Kỷ Niệm",
		"category": "workspace",
		"placement": "wall",
		"sprite": "res://sprites/workspace/wire_grid.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.58,
		"wallElevationPx": 75,
		"wallRowSpan": {"start": 1, "end": 1},
		"description": "Khung lưới sắt kẹp ảnh polaroid và đèn dây.",
	},
	{
		"id": "hanging_decor",
		"name": "Dây Đèn & Đồ Treo Tường",
		"category": "workspace",
		"placement": "wall",
		"sprite": "res://sprites/workspace/hanging_decor.png",
		"footprint": {"w": 2, "h": 1},
		"scale": 0.48,
		"wallElevationPx": 132,
		"wallRowSpan": {"start": 2, "end": 2},
		"lightEmitter": {"color": 0xfde047, "radius": 140, "intensity": 0.6, "offsetY": -30},
		"description": "Dây đèn led & phụ kiện trang trí tường cực chill.",
	},

	# ===================================================================
	# 3. NHÀ BẾP (KITCHEN)
	# ===================================================================
	{
		"id": "fridge",
		"name": "Tủ Lạnh Hai Cánh",
		"category": "kitchen",
		"placement": "floor",
		"sprite": "res://sprites/kitchen/fridge_closed.png",
		"altSprite": "res://sprites/kitchen/fridge_open.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.62,
		"lightEmitter": {"color": 0xe0f2fe, "radius": 120, "intensity": 0.5, "offsetY": -55},
		"description": "Tủ lạnh đồ ăn vặt (Bấm để mở/đóng cửa tủ).",
	},
	{
		"id": "l_counter",
		"name": "Quầy Bếp Chữ L",
		"category": "kitchen",
		"placement": "floor",
		"sprite": "res://sprites/kitchen/l_counter.png",
		"footprint": {"w": 3, "h": 2},
		"footprintCells": [
			{"dx": 0, "dy": 0},
			{"dx": 1, "dy": 0},
			{"dx": 2, "dy": 0},
			{"dx": 0, "dy": 1},
		],
		"scale": 0.64,
		"isSurface": true,
		"surfaceHeightPx": 48,
		"description": "Quầy bếp dài chữ L đặt được nồi, bình nước và đồ bếp lên trên.",
	},
	{
		"id": "stove_counter",
		"name": "Bếp Nấu Ăn",
		"category": "kitchen",
		"placement": "floor",
		"sprite": "res://sprites/kitchen/stove_counter.png",
		"footprint": {"w": 1, "h": 2},
		"footprintCells": [
			{"dx": 0, "dy": 0},
			{"dx": 0, "dy": 1},
		],
		"scale": 0.72,
		"isSurface": true,
		"surfaceHeightPx": 46,
		"lightEmitter": {"color": 0xfb923c, "radius": 100, "intensity": 0.55, "offsetY": -40},
		"description": "Bếp nấu đồ ăn ấm nóng cho những buổi đêm học bài.",
	},
	{
		"id": "upper_cabinets",
		"name": "Tủ Bếp Treo Trên",
		"category": "kitchen",
		"placement": "wall",
		"sprite": "res://sprites/kitchen/upper_cabinets.png",
		"footprint": {"w": 2, "h": 1},
		"scale": 0.45,
		"wallElevationPx": 80,
		"wallRowSpan": {"start": 1, "end": 1},
		"description": "Hệ tủ bếp treo tường gọn gàng.",
	},
	{
		"id": "window_kitchen",
		"name": "Cửa Sổ Bếp",
		"category": "kitchen",
		"placement": "wall",
		"sprite": "res://sprites/kitchen/window_closed.png",
		"altSprite": "res://sprites/kitchen/window_half_open.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.65,
		"wallElevationPx": 68,
		"wallRowSpan": {"start": 1, "end": 2},
		"lightEmitter": {"color": 0x93c5fd, "radius": 130, "intensity": 0.4, "offsetY": -50},
		"description": "Cửa sổ bếp có thể bấm để mở hé đón gió.",
	},
	{
		"id": "kitchen_props",
		"name": "Bộ Nồi & Dụng Cụ Bếp",
		"category": "kitchen",
		"placement": "surface",
		"sprite": "res://sprites/kitchen/kitchen_props.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.36,
		"description": "Đặt lên mặt quầy bếp chữ L hoặc bếp nấu.",
	},

	# ===================================================================
	# 4. PHÒNG TẮM (BATHROOM)
	# ===================================================================
	{
		"id": "bathroom_door",
		"name": "Cửa Phòng Tắm",
		"category": "bathroom",
		"placement": "floor",
		"sprite": "res://sprites/bathroom/bathroom_door.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.62,
		"description": "Cửa kính mờ ngăn cách phòng tắm.",
	},
	{
		"id": "glass_partition",
		"name": "Vách Kính Phòng Tắm",
		"category": "bathroom",
		"placement": "floor",
		"sprite": "res://sprites/bathroom/glass_partition.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.55,
		"description": "Vách kính hiện đại chia khu vực khô/ướt.",
	},
	{
		"id": "vanity",
		"name": "Tủ Lavabo & Gương",
		"category": "bathroom",
		"placement": "floor",
		"sprite": "res://sprites/bathroom/vanity.png",
		"altSprite": "res://sprites/bathroom/vanity_soap.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.6,
		"isSurface": true,
		"surfaceHeightPx": 42,
		"lightEmitter": {"color": 0xfef08a, "radius": 120, "intensity": 0.55, "offsetY": -80},
		"description": "Tủ rửa mặt kèm gương có đèn led ấm.",
	},
	{
		"id": "toilet",
		"name": "Bồn Cầu Thông Minh",
		"category": "bathroom",
		"placement": "floor",
		"sprite": "res://sprites/bathroom/toilet_closed.png",
		"altSprite": "res://sprites/bathroom/toilet_open.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.45,
		"description": "Bấm để đóng/mở nắp bồn cầu.",
	},
	{
		"id": "shower_set",
		"name": "Bộ Vòi Sen Tắm",
		"category": "bathroom",
		"placement": "wall",
		"sprite": "res://sprites/bathroom/shower_set.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.58,
		"wallElevationPx": 20,
		"wallRowSpan": {"start": 0, "end": 1},
		"description": "Vòi sen cây gắn tường phòng tắm.",
	},
	{
		"id": "heat_lamp",
		"name": "Đèn Sưởi Nhà Tắm",
		"category": "bathroom",
		"placement": "wall",
		"sprite": "res://sprites/bathroom/heat_lamp_off.png",
		"altSprite": "res://sprites/bathroom/heat_lamp_on.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.72,
		"wallElevationPx": 132,
		"wallRowSpan": {"start": 2, "end": 2},
		"lightEmitter": {"color": 0xfdba74, "radius": 160, "intensity": 0.85, "offsetY": -40},
		"description": "Đèn sưởi ấm áp (Bấm để bật/tắt đèn!).",
	},
	{
		"id": "trash_bin",
		"name": "Thùng Rác Nhỏ",
		"category": "bathroom",
		"placement": "floor",
		"sprite": "res://sprites/bathroom/trash_bin.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.42,
		"description": "Thùng rác gọn gàng cho phòng tắm hoặc bàn học.",
	},

	# ===================================================================
	# 5. ĐỒ TRANG TRÍ ĐỂ BÀN / SURFACE PROPS (KIỂU GOGH & PLAY TOGETHER)
	# ===================================================================
	{
		"id": "prop_bunny_heart",
		"name": "Thỏ Bông Ôm Tim",
		"category": "decor",
		"placement": "surface",
		"sprite": "res://sprites/character/prop_bunny_heart.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.42,
		"lightEmitter": {"color": 0xf472b6, "radius": 85, "intensity": 0.45, "offsetY": -16},
		"description": "Thỏ bông siêu dễ thương đặt lên bàn học hoặc bàn trà.",
	},
	{
		"id": "prop_gift_box",
		"name": "Hộp Quà Nơ Đỏ",
		"category": "decor",
		"placement": "surface",
		"sprite": "res://sprites/character/prop_gift_box.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.34,
		"description": "Hộp quà kỷ niệm nhỏ xinh đặt trên bàn hoặc kệ.",
	},
	{
		"id": "prop_phone",
		"name": "Điện Thoại Nhắn Tin",
		"category": "decor",
		"placement": "surface",
		"sprite": "res://sprites/character/prop_phone.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.32,
		"lightEmitter": {"color": 0x93c5fd, "radius": 75, "intensity": 0.5, "offsetY": -12},
		"description": "Điện thoại phát sáng đặt bên cạnh laptop.",
	},
	{
		"id": "prop_glasses",
		"name": "Kính Mắt Gọng Trong",
		"category": "decor",
		"placement": "surface",
		"sprite": "res://sprites/character/prop_glasses.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.3,
		"description": "Cặp kính đặt trên bàn lúc nghỉ giải lao.",
	},
	{
		"id": "sneakers",
		"name": "Đôi Giày Thể Thao",
		"category": "decor",
		"placement": "floor",
		"sprite": "res://sprites/living_room/sneakers.png",
		"footprint": {"w": 1, "h": 1},
		"scale": 0.46,
		"walkable": true,
		"description": "Đôi sneakers đặt ngay ngắn cạnh thảm cửa ra vào.",
	},
	{
		"id": "floor_clutter",
		"name": "Đồ Tiện Ích Góc Phòng",
		"category": "decor",
		"placement": "floor",
		"sprite": "res://sprites/workspace/floor_clutter.png",
		"footprint": {"w": 2, "h": 1},
		"scale": 0.4,
		"description": "Hộp đựng đồ, sách vở và phụ kiện decor góc phòng.",
	},
]

var CATALOG_MAP: Dictionary = {}
var _texture_cache: Dictionary = {}
var _image_cache: Dictionary = {}
var _glow_texture_cache: Dictionary = {}


func _ready() -> void:
	for item in CATALOG_ITEMS:
		CATALOG_MAP[item["id"]] = item


func to_res_path(p: String) -> String:
	if p.is_empty():
		return ""
	if p.begins_with("res://"):
		return p
	if p.begins_with("/"):
		return "res:/" + p
	return "res://" + p


func get_catalog_item(id: String) -> Dictionary:
	return CATALOG_MAP.get(id, {})


func get_texture(path: String) -> Texture2D:
	var res_path := to_res_path(path)
	if res_path.is_empty():
		return null
	if _texture_cache.has(res_path):
		return _texture_cache[res_path]

	var tex: Texture2D = null
	var src_img := get_image(res_path)
	if src_img != null and not src_img.is_empty():
		var mip_img := src_img.duplicate() as Image
		mip_img.generate_mipmaps()
		tex = ImageTexture.create_from_image(mip_img)
	elif ResourceLoader.exists(res_path):
		var loaded := ResourceLoader.load(res_path)
		if loaded is Texture2D:
			tex = loaded

	if tex != null:
		_texture_cache[res_path] = tex
	return tex


func get_image(path: String) -> Image:
	var res_path := to_res_path(path)
	if res_path.is_empty():
		return null
	if _image_cache.has(res_path):
		return _image_cache[res_path]

	var img: Image = null
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		img = Image.load_from_file(abs_path)

	if (img == null or img.is_empty()) and ResourceLoader.exists(res_path):
		var loaded := ResourceLoader.load(res_path)
		if loaded is Texture2D:
			img = (loaded as Texture2D).get_image()

	if (img == null or img.is_empty()) and FileAccess.file_exists(res_path):
		var buf := FileAccess.get_file_as_bytes(res_path)
		if not buf.is_empty():
			var tmp := Image.new()
			if tmp.load_png_from_buffer(buf) == OK:
				img = tmp

	if img != null and not img.is_empty():
		if img.is_compressed():
			img.decompress()
		if img.get_format() != Image.FORMAT_RGBA8:
			img.convert(Image.FORMAT_RGBA8)
		_image_cache[res_path] = img
	return img


func get_glow_texture(color_int: int) -> Texture2D:
	if _glow_texture_cache.has(color_int):
		return _glow_texture_cache[color_int]

	var size := 128
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var r := float((color_int >> 16) & 255) / 255.0
	var g := float((color_int >> 8) & 255) / 255.0
	var b := float(color_int & 255) / 255.0
	var center := float(size) * 0.5
	var max_radius := float(size) * 0.5

	for y in range(size):
		for x in range(size):
			var dx := float(x) + 0.5 - center
			var dy := float(y) + 0.5 - center
			var dist := sqrt(dx * dx + dy * dy)
			var t := clampf(dist / max_radius, 0.0, 1.0)
			var alpha: float = 0.0
			if t < 0.45:
				alpha = lerpf(0.85, 0.35, t / 0.45)
			else:
				alpha = lerpf(0.35, 0.0, (t - 0.45) / 0.55)
			img.set_pixel(x, y, Color(r, g, b, alpha))

	var tex := ImageTexture.create_from_image(img)
	_glow_texture_cache[color_int] = tex
	return tex


func color_from_int(color_int: int, alpha: float = 1.0) -> Color:
	var r := float((color_int >> 16) & 255) / 255.0
	var g := float((color_int >> 8) & 255) / 255.0
	var b := float(color_int & 255) / 255.0
	return Color(r, g, b, alpha)


func grid_to_screen(gx: float, gy: float) -> Vector2:
	return Vector2(
		(gx - gy) * (TILE_W * 0.5),
		(gx + gy) * (TILE_H * 0.5)
	)


func screen_to_grid(sx: float, sy: float) -> Vector2:
	var gx := (sx / (TILE_W * 0.5) + sy / (TILE_H * 0.5)) * 0.5
	var gy := (sy / (TILE_H * 0.5) - sx / (TILE_W * 0.5)) * 0.5
	return Vector2(gx, gy)


func get_relative_footprint_cells(cat: Dictionary, flipped: bool) -> Array:
	var base: Array = []
	var fp_cells: Array = cat.get("footprintCells", [])
	if fp_cells.size() > 0:
		for c in fp_cells:
			base.append({"dx": int(c["dx"]), "dy": int(c["dy"])})
	else:
		var fp: Dictionary = cat.get("footprint", {"w": 1, "h": 1})
		var w := maxi(1, int(fp.get("w", 1)))
		var h := maxi(1, int(fp.get("h", 1)))
		for dy in range(h):
			for dx in range(w):
				base.append({"dx": dx, "dy": dy})

	if not flipped:
		return base
	var mirrored: Array = []
	for c in base:
		mirrored.append({"dx": int(c["dy"]), "dy": int(c["dx"])})
	return mirrored


func get_item_occupied_cells(cat: Dictionary, origin_gx: float, origin_gy: float, flipped: bool) -> Array:
	var ox := int(floor(origin_gx))
	var oy := int(floor(origin_gy))
	var res: Array = []
	for c in get_relative_footprint_cells(cat, flipped):
		res.append({"gx": ox + int(c["dx"]), "gy": oy + int(c["dy"])})
	return res


func get_footprint_screen_metrics(cat: Dictionary, origin_gx: float, origin_gy: float, flipped: bool) -> Dictionary:
	var cells := get_item_occupied_cells(cat, origin_gx, origin_gy, flipped)
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	var sum_gx := 0.0
	var sum_gy := 0.0

	for cell in cells:
		var gx := float(cell["gx"])
		var gy := float(cell["gy"])
		sum_gx += gx + 0.5
		sum_gy += gy + 0.5
		var corners := [
			grid_to_screen(gx, gy),
			grid_to_screen(gx + 1.0, gy),
			grid_to_screen(gx + 1.0, gy + 1.0),
			grid_to_screen(gx, gy + 1.0),
		]
		for c in corners:
			if c.x < min_x: min_x = c.x
			if c.x > max_x: max_x = c.x
			if c.y < min_y: min_y = c.y
			if c.y > max_y: max_y = c.y

	var count := maxf(1.0, float(cells.size()))
	var centroid_gx := sum_gx / count
	var centroid_gy := sum_gy / count
	var off_x := float(cat.get("offsetX", 0.0))
	var off_y := float(cat.get("offsetY", 0.0))

	return {
		"minX": min_x,
		"maxX": max_x,
		"minY": min_y,
		"maxY": max_y,
		"spriteX": (min_x + max_x) * 0.5 + (-off_x if flipped else off_x),
		"spriteY": max_y + off_y,
		"centroidGx": centroid_gx,
		"centroidGy": centroid_gy,
		"depthScore": (centroid_gx + centroid_gy) * 100.0,
	}


func get_footprint_boundary_edges(cells: Array) -> Array:
	var occupied: Dictionary = {}
	for c in cells:
		occupied["%d,%d" % [int(c["gx"]), int(c["gy"])]] = true
	var edges: Array = []

	for c in cells:
		var gx := int(c["gx"])
		var gy := int(c["gy"])
		if not occupied.has("%d,%d" % [gx, gy - 1]):
			edges.append({"x1": gx, "y1": gy, "x2": gx + 1, "y2": gy})
		if not occupied.has("%d,%d" % [gx + 1, gy]):
			edges.append({"x1": gx + 1, "y1": gy, "x2": gx + 1, "y2": gy + 1})
		if not occupied.has("%d,%d" % [gx, gy + 1]):
			edges.append({"x1": gx + 1, "y1": gy + 1, "x2": gx, "y2": gy + 1})
		if not occupied.has("%d,%d" % [gx - 1, gy]):
			edges.append({"x1": gx, "y1": gy + 1, "x2": gx, "y2": gy})
	return edges


func mirror_facing_direction(facing: String) -> String:
	match facing:
		"se": return "sw"
		"sw": return "se"
		"nw": return "ne"
		"ne": return "nw"
		"left": return "right"
		"right": return "left"
		_: return facing


func format_footprint_label(cat: Dictionary) -> String:
	var placement := str(cat.get("placement", "floor"))
	var fp: Dictionary = cat.get("footprint", {"w": 1, "h": 1})
	var w := int(fp.get("w", 1))
	var h := int(fp.get("h", 1))
	if placement == "surface":
		return "Để bàn"
	if placement == "wall":
		return "Tường %d ô" % w
	var fp_cells: Array = cat.get("footprintCells", [])
	if fp_cells.size() > 0 and fp_cells.size() != w * h:
		return "Chữ L (%d ô)" % fp_cells.size()
	var area := w * h
	if area == 1:
		return "1×1 ô"
	return "%d×%d (%d ô)" % [w, h, area]


func count_floor_tiles(floor_map: Array) -> int:
	var count := 0
	for row_val in floor_map:
		var row := str(row_val)
		for i in range(row.length()):
			if row[i] != ".":
				count += 1
	return count


func auto_generate_walls_from_floor(floor_map: Array, max_walls: int = 50) -> Array:
	var walls: Array = []
	var has_tile := func(gx: int, gy: int) -> bool:
		if gy < 0 or gy >= floor_map.size():
			return false
		var row := str(floor_map[gy])
		if gx < 0 or gx >= row.length():
			return false
		return row[gx] != "."

	for gy in range(floor_map.size()):
		var row := str(floor_map[gy])
		for gx in range(row.length()):
			if not has_tile.call(gx, gy):
				continue
			if not has_tile.call(gx - 1, gy) and walls.size() < max_walls:
				walls.append("L:%d,%d" % [gx, gy])
			if not has_tile.call(gx, gy - 1) and walls.size() < max_walls:
				walls.append("R:%d,%d" % [gx, gy])
	return walls


func create_default_room_layout(room_code: String = "GENERAL", host_id: String = "host-local") -> Dictionary:
	var default_items: Array = [
		{
			"uid": "item_main_door",
			"catalogId": "main_door_b",
			"gx": 4,
			"gy": 9,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_mat",
			"catalogId": "watermelon_mat",
			"gx": 4,
			"gy": 8,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_shoes",
			"catalogId": "cabinet_shoes",
			"gx": 2,
			"gy": 9,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_double_desk",
			"catalogId": "double_desk",
			"gx": 0,
			"gy": 1,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_chair_1",
			"catalogId": "chair_front",
			"gx": 1,
			"gy": 1,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_chair_2",
			"catalogId": "chair_side",
			"gx": 1,
			"gy": 2,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_bunny_desk",
			"catalogId": "prop_bunny_heart",
			"gx": 0.5,
			"gy": 2.5,
			"rotation": 0,
			"flipped": false,
			"layer": "surface",
			"parentSurfaceUid": "item_double_desk",
			"elevationPx": 44,
			"toggled": false,
		},
		{
			"uid": "item_ac",
			"catalogId": "ac_unit",
			"gx": 3,
			"gy": 0,
			"rotation": 0,
			"flipped": false,
			"layer": "wall",
			"elevationPx": 110,
			"toggled": false,
		},
		{
			"uid": "item_window_1",
			"catalogId": "window_curtains",
			"gx": 0,
			"gy": 2,
			"rotation": 0,
			"flipped": true,
			"layer": "wall",
			"elevationPx": 65,
			"toggled": false,
		},
		{
			"uid": "item_clock",
			"catalogId": "sunburst_clock",
			"gx": 5,
			"gy": 0,
			"rotation": 0,
			"flipped": false,
			"layer": "wall",
			"elevationPx": 95,
			"toggled": false,
		},
		{
			"uid": "item_sofa",
			"catalogId": "sofa_iso",
			"gx": 0,
			"gy": 5,
			"rotation": 0,
			"flipped": true,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_glass_table",
			"catalogId": "table_glass_round_1",
			"gx": 2,
			"gy": 5,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_gift_table",
			"catalogId": "prop_gift_box",
			"gx": 2.5,
			"gy": 5.5,
			"rotation": 0,
			"flipped": false,
			"layer": "surface",
			"parentSurfaceUid": "item_glass_table",
			"elevationPx": 30,
			"toggled": false,
		},
		{
			"uid": "item_fridge",
			"catalogId": "fridge",
			"gx": 6,
			"gy": 0,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_l_counter",
			"catalogId": "l_counter",
			"gx": 7,
			"gy": 0,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_toilet",
			"catalogId": "toilet",
			"gx": 9,
			"gy": 6,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "item_vanity",
			"catalogId": "vanity",
			"gx": 9,
			"gy": 8,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
	]

	return {
		"roomCode": room_code,
		"roomName": "Căn Hộ Lo-Fi #%s" % room_code,
		"hostId": host_id,
		"allowGuestBuild": true,
		"floorMap": [
			"WWWWWWWWWW",
			"WWWWWWWWWW",
			"WWCCCCWWWW",
			"WWCCCCWWWW",
			"WWCCCCWWWW",
			"WWWWWWWWWW",
			"WWWWWWBBBB",
			"WWWWWWBBBB",
			"WWWWWWBBBB",
			"WWWWWWBBBB",
		],
		"wallTheme": "lofi_purple",
		"lightingMode": "day",
		"rainEnabled": false,
		"items": default_items,
	}


func create_personal_room_layout(room_code: String, owner_id: String = "host-local", owner_name: String = "Chủ phòng") -> Dictionary:
	var starter_floor_map: Array = [
		"..............",
		"..............",
		"..............",
		"...WWWWWW.....",
		"...WWCCWW.....",
		"...WWCCWW.....",
		"...WWWWWW.....",
		"...WWWWWW.....",
		"...WWWWWW.....",
		"..............",
		"..............",
		"..............",
		"..............",
		"..............",
	]

	var starter_items: Array = [
		{
			"uid": "p_door",
			"catalogId": "main_door_b",
			"gx": 5,
			"gy": 8,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "p_mat",
			"catalogId": "watermelon_mat",
			"gx": 5,
			"gy": 7,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "p_desk",
			"catalogId": "double_desk",
			"gx": 3,
			"gy": 4,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "p_chair",
			"catalogId": "chair_front",
			"gx": 4,
			"gy": 4,
			"rotation": 0,
			"flipped": false,
			"layer": "floor",
			"elevationPx": 0,
			"toggled": false,
		},
		{
			"uid": "p_laptop",
			"catalogId": "laptops",
			"gx": 3,
			"gy": 4,
			"rotation": 0,
			"flipped": false,
			"layer": "surface",
			"parentSurfaceUid": "p_desk",
			"elevationPx": 44,
			"toggled": false,
		},
		{
			"uid": "p_bunny",
			"catalogId": "prop_bunny_heart",
			"gx": 3,
			"gy": 5,
			"rotation": 0,
			"flipped": false,
			"layer": "surface",
			"parentSurfaceUid": "p_desk",
			"elevationPx": 44,
			"toggled": false,
		},
		{
			"uid": "p_clock",
			"catalogId": "sunburst_clock",
			"gx": 3,
			"gy": 4,
			"rotation": 0,
			"flipped": true,
			"layer": "wall",
			"elevationPx": 88,
			"toggled": false,
		},
	]

	return {
		"roomCode": room_code,
		"roomName": "Phòng của %s" % owner_name,
		"hostId": owner_id,
		"allowGuestBuild": false,
		"floorMap": starter_floor_map,
		"walls": auto_generate_walls_from_floor(starter_floor_map, 50),
		"wallTheme": "cream",
		"lightingMode": "day",
		"rainEnabled": false,
		"isPersonal": true,
		"ownerUid": owner_id,
		"maxItems": 30,
		"maxFloorTiles": 50,
		"maxWallTiles": 50,
		"items": starter_items,
	}


func is_iso_character(outfit: String) -> bool:
	return ISO_CHARACTER_IDS.has(outfit)


func is_sprite_hair_style(style: String) -> bool:
	return SPRITE_HAIR_STYLES.has(style)


func get_hair_sprite_path(style: String, is_back: bool) -> String:
	if not is_sprite_hair_style(style):
		return ""
	var suffix := "nw" if is_back else "se"
	return "res://sprites/characters/hair/%s_%s.png" % [style, suffix]


func resolve_iso_character_frame(
	outfit: String,
	facing: String,
	activity: String,
	is_moving: bool,
	walk_frame: int
) -> Dictionary:
	var safe_outfit := outfit if is_iso_character(outfit) else "c1"
	var is_north_side := (facing == "nw" or facing == "ne" or facing == "back")
	var flip_north := (facing == "ne")
	var flip_south := (facing == "sw" or facing == "left")

	var folder := "base" if safe_outfit == "custom" else safe_outfit
	var base_dir := "res://sprites/characters/%s" % folder

	if activity == "focus_desk":
		if is_north_side:
			return {"path": "%s/sit_typing_nw.png" % base_dir, "flipX": flip_north}
		return {"path": "%s/sit_typing_se.png" % base_dir, "flipX": flip_south}

	if activity == "chill_sofa" or activity == "coffee":
		return {"path": "%s/sit_chill_se.png" % base_dir, "flipX": flip_south}

	if activity == "sit_floor":
		return {"path": "%s/sit_floor_se.png" % base_dir, "flipX": flip_south}

	if is_moving:
		var idx := absi(walk_frame) % 4
		if is_north_side:
			return {"path": "%s/walk_nw_%d.png" % [base_dir, idx], "flipX": flip_north}
		return {"path": "%s/walk_se_%d.png" % [base_dir, idx], "flipX": flip_south}

	if is_north_side:
		return {"path": "%s/idle_nw.png" % base_dir, "flipX": flip_north}
	return {"path": "%s/idle_se.png" % base_dir, "flipX": flip_south}
