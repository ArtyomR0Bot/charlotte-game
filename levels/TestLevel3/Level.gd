extends Node2D


onready var start_position = $Charlie.position
onready var navi_map = get_world_2d().navigation_map


func _ready():
	Navigation2DServer.map_set_active(navi_map, true)


func _physics_process(_delta):
	if $Charlie.position.y > 368:
		$Charlie.position = start_position
		$Charlie.reset(true)
	var path = Navigation2DServer.map_get_path(navi_map,
		$Robo.global_position, $Charlie.global_position, false, 1)
	$Line.points = path
