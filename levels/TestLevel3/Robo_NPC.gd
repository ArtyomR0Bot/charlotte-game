extends Node2D


enum {NONE, FOLLOW_OBJECT}


var state = NONE
var object_ref: WeakRef


func _physics_process(delta):
	if state == FOLLOW_OBJECT:
		var obj = object_ref.get_ref()
		if obj:
			$Line.points[1] = to_local(obj.position)
		else:
			state = NONE


func follow_object(object):
	state = FOLLOW_OBJECT
	object_ref = weakref(object)
