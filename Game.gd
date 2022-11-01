extends Node2D


var camera: Camera2D
var zoom = 2


func _ready():
	camera = create_camera($Level.character)


func _input(event):
	if event.is_action_pressed("zoom_in"):
		if zoom < 4:
			zoom *= 2
			camera.zoom = Vector2.ONE / zoom
	if event.is_action_pressed("zoom_out"):
		if zoom > 1:
			zoom /= 2
			camera.zoom = Vector2.ONE / zoom


func create_camera(character):
	camera = Camera2D.new()
	camera.current = true
	camera.zoom = Vector2.ONE / zoom
	camera.offset_v = -0.3
	character.add_child(camera)
	return camera
