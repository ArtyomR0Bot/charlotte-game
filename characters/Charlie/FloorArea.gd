extends Area2D


var bodies = []
var shift: Vector2


func _physics_process(_delta):
	var sum = Vector2.ZERO
	var i = 0
	var size = bodies.size()
	while i < size:
		var body = bodies[i].body.get_ref()
		if body:
			sum += body.position - bodies[i].pos
			bodies[i].pos = body.position
			i += 1
		else:
			bodies.remove(i)
			size -= 1
	if sum:
		shift = sum / bodies.size()
	else:
		shift = Vector2.ZERO


func _on_FloorArea_body_entered(body):
	bodies.append({'body': weakref(body), 'pos': body.position})


func _on_FloorArea_body_exited(body):
	for i in bodies.size():
		if bodies[i].body.get_ref() == body:
			bodies.remove(i)
			break


func is_on_floor():
	return not bodies.empty()
