extends Area2D


var floor_body_ref: WeakRef
var queue = []
var last_pos: Vector2
var shift: Vector2


func _physics_process(_delta):
	if floor_body_ref:
		var floor_body = floor_body_ref.get_ref()
		if floor_body:
			shift = floor_body.position - last_pos
			last_pos = floor_body.position
		else:
			next_body()


func _on_FloorArea_body_entered(body):
	if floor_body_ref:
		queue.append(weakref(body))
	else:
		switch_body(body)


func _on_FloorArea_body_exited(_body):
	next_body()


func switch_body(new_body):
	floor_body_ref = weakref(new_body)
	last_pos = new_body.position


func next_body():
	floor_body_ref = null
	shift = Vector2.ZERO
	if not queue.empty():
		var floor_body = queue.pop_front().get_ref()
		if floor_body:
			switch_body(floor_body)


func is_on_floor():
	return floor_body_ref != null
