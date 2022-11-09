extends Node2D


onready var start_position = $Charlie.position


func _physics_process(delta):
	if $Charlie.position.y > 500:
		$Charlie.position = start_position
		$Charlie.reset(true, $Charlie.IDLE)
		$TestScript.reset()
