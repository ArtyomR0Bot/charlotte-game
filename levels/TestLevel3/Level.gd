extends Node2D


onready var start_position = $Charlie.position
onready var navi_map = get_world_2d().navigation_map


func _physics_process(_delta):
	if $Charlie.position.y > 368:
		$Charlie.position = start_position
		$Charlie.reset(true)
