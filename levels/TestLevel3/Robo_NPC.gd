extends Node2D


enum {NONE, FOLLOW}


var state = NONE
var object_ref: WeakRef

onready var navi_map = get_world_2d().navigation_map


func _physics_process(_delta):
	if state == FOLLOW:
		var obj = object_ref.get_ref()
		if obj:
			pass
		else:
			state = NONE
			object_ref = null


func follow(object):
	state = FOLLOW
	object_ref = weakref(object)
