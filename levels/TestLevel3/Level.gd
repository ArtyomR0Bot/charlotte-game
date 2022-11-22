extends Node2D


onready var character = $Player.character
onready var start_position = character.position


func _physics_process(_delta):
	if character.position.y > 368:
		character.reset(true)
		character.position = start_position
