extends Node2D


onready var start_position = $Charlie.position


func _ready():
	$Robo/NPC.follow_object($Charlie)


func _physics_process(_delta):
	if $Charlie.position.y > 368:
		$Charlie.position = start_position
		$Charlie.reset(true)
