extends Node2D


const WIDTH = ProjectSettings["display/window/size/width"]
const HEIGHT = ProjectSettings["display/window/size/height"]


var key_pressed = false


func _ready():
	pass
	#get_viewport().connect("size_changed", self, "_on_size_changed")


func _unhandled_key_input(event):
	if event.is_pressed() and event.scancode == KEY_ENTER and event.alt:
		OS.window_fullscreen = not OS.window_fullscreen


func _on_size_changed():
	var viewport = get_viewport()
	var mul_x = max(floor(viewport.size.x / WIDTH), 1)
	var mul_y = max(floor(viewport.size.y / HEIGHT), 1)
	var mul = min(mul_x, mul_y)
	var new_size = Vector2(WIDTH * mul, HEIGHT * mul)
	var margin = viewport.size - new_size
	viewport.canvas_transform.x = Vector2(mul, 0)
	viewport.canvas_transform.y = Vector2(0, mul)
	viewport.canvas_transform.origin = margin / 2
