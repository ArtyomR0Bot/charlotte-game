extends Node


var start_position: Vector2


func _ready():
	$Player.character = $Charlie
	$Player.camera = $Camera2D
	start_position = $Player.character.position


func _physics_process(_delta):
	var character = $Player.character
	if character.position.y > 368:
		character.reset(true)
		character.position = start_position
