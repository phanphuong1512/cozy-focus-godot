extends Node2D

@onready var isometric_room: Node2D = $IsometricRoom
@onready var ui_layer: CanvasLayer = $UILayer


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#1b130f"))
	if DisplayServer.get_name() != "headless":
		if GameStore.is_embedded_display():
			# Godot 4.7 embedded Game dock can't resize or fullscreen natively;
			# bump content_scale_factor so UI & pixel art stay legible inside the dock.
			get_tree().root.content_scale_factor = 1.45
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	if ui_layer != null and isometric_room != null:
		ui_layer.bind_room(isometric_room)
	GameStore.init_network("GENERAL")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			GameStore.toggle_fullscreen()
