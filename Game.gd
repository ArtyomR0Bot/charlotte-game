extends Node2D


var key_pressed = false


func _ready():
	OS.window_size = Vector2(1280, 720)
	OS.center_window()


func _unhandled_key_input(event):
	if event.is_pressed() and event.scancode == KEY_ENTER and event.alt:
		OS.window_fullscreen = not OS.window_fullscreen
