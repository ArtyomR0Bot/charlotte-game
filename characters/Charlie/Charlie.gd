extends KinematicBody2D


enum Action {JUMP, MOVE_DOWN}


export var gravity = 25
export var run_speed = 150
export var jump_speed = 500
export var max_speed = 500
export var max_jumps = 1


var velocity: Vector2
var direction = 1
var move_speed = 0
var jump = false
var jumping = false
var cancel_jump = false
var num_jumps = 0
var move_down = false
var on_floor = false
var on_wall = false
var on_ceiling = false
var in_air = false
var in_air_start = 0
var falling = true
var last_action
var last_action_time = 0
var fly = false
var flying = false
var limit_collision = false
var limit_collision_start = 0
var punch = false
var punching = false
var move = true


func _physics_process(delta):
	var inertia = 0.8
	if fly:
		flying = true
		jumping = false
		in_air = false
		falling = false
		if limit_collision:
			restore_collision()
		$Animation.update()
		fly = false
	elif punch:
		if not punching:
			punching = true
			$Animation.update()
		punch = false
	elif flying:
		pass
	elif on_floor:
		jumping = false
		in_air = false
		num_jumps = 0
		if falling:
			falling = false
			$Animation.update()
		if limit_collision:
			restore_collision()
	else:
		inertia = 0.95
		if in_air:
			if not num_jumps and OS.get_ticks_msec() - in_air_start > 1:
				num_jumps = 1
			if not falling and OS.get_ticks_msec() - in_air_start > 200:
				falling = true
				$Animation.update()
		else:
			in_air_start = OS.get_ticks_msec()
			in_air = true
	if not flying:
		velocity.y += gravity
	if flying:
		if jump:
			velocity.y = -run_speed * scale.y
		elif move_down:
			velocity.y = run_speed * scale.y
		else:
			velocity.y = 0
		if cancel_jump:
			jump = false
			cancel_jump = false
	else:
		if jump:
			if num_jumps < max_jumps:
				velocity.y = -jump_speed * scale.y
				num_jumps += 1
				jumping = true
				$Animation.update()
			jump = false
		if cancel_jump:
			if flying:
				velocity.y = 0
			elif velocity.y < 0:
				velocity.y /= 2
			jump = false
			cancel_jump = false
	if move and not punching:
		$Animation.update()
#		if (direction > 0 and velocity.x < 0
#			or direction < 0 and velocity.x > 0):
#			$Animation.update()
#			print("update")
	var remaining_velocity_x = velocity.x * inertia
	var move_velocity_x = (direction * move_speed
							* run_speed * scale.x * (1 - inertia))
	velocity.x = remaining_velocity_x + move_velocity_x
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	set_collision_mask_bit(2, not move_down)
	move(delta)


func _input(event):
	if event.is_action_pressed("move_right"):
		action_move_right()
	if event.is_action_released("move_right"):
		action_stop_moving_right()
	if event.is_action_pressed("move_left"):
		action_move_left()
	if event.is_action_released("move_left"):
		action_stop_moving_left()
	if event.is_action_pressed("jump"):
		action_jump()
	if event.is_action_released("jump"):
		action_cancel_jump()
	if event.is_action_pressed("move_down"):
		action_move_down()
	if event.is_action_released("move_down"):
		action_stop_moving_down()
	if event.is_action_pressed("action"):
		action_do_action()


func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			if move_speed > 0:
				if direction > 0:
					action_stop_moving_right()
				else:
					action_stop_moving_left()
			if jump:
				action_cancel_jump()
			if move_down:
				action_stop_moving_down()


func move(delta):
	on_floor = false
	on_wall = false
	on_ceiling = false
	var num_collisions = 0
	var num_wall_collisions = 0
	var collision = move_and_collide_ex(velocity * delta)
	while collision and num_collisions < 7:
		num_collisions += 1
		if collision.collider.has_method("collision"):
			collision.collider.call("collision")
		var angle = collision.get_angle(Vector2.UP)
		if angle > 1.6:
			on_ceiling = true
			if velocity.y < 0:
				velocity.y = 0
			var move_vec = Vector2(collision.remainder.x, 0)
			position += move_vec
			collision = move_and_collide_ex(Vector2.ZERO)
		elif angle > 0.8:
			on_wall = true
			num_wall_collisions += 1
			velocity.x = 0
			var remainder = collision.remainder
			var normal = collision.normal
			var ratio = 0 if normal.x == 0 else normal.y / normal.x
			var move_x = -remainder.y * ratio
			var move_vec = Vector2(move_x, remainder.y)
			collision = move_and_collide_ex(move_vec)
		else:
			on_floor = true
			velocity.y = 0
			var remainder = collision.remainder
			var normal = collision.normal
			var ratio = 0 if normal.y == 0 else normal.x / normal.y
			var move_y = -remainder.x * ratio
			var move_vec = Vector2(remainder.x, move_y)
			collision = move_and_collide_ex(move_vec)
	if on_floor:
		if on_wall:
			on_wall = false
		if on_ceiling:
			on_ceiling = false
	if num_wall_collisions > 1 and not flying:
		for owner_id in get_shape_owners():
			var shape_owner = shape_owner_get_owner(owner_id)
			if shape_owner.one_way_collision:
				shape_owner.disabled = true
		limit_collision = true
		limit_collision_start = OS.get_ticks_msec()


func move_and_collide_ex(vel):
	var collision = move_and_collide(vel)
	if not collision:
		return
	if collision.local_shape.one_way_collision:
		if collision.collider.get_collision_layer_bit(2):
			position += collision.remainder
			return
	return collision


func restore_collision():
	for owner_id in get_shape_owners():
		var shape_owner = shape_owner_get_owner(owner_id)
		if shape_owner.one_way_collision:
			shape_owner.disabled = false
	limit_collision = false


func action_move_right():
	if direction < 0:
		punching = false
	direction = 1
	move_speed = 1
	move = true


func action_stop_moving_right():
	if move_speed * direction > 0:
		move_speed = 0
		$Animation.update()


func action_move_left():
	if direction > 0:
		punching = false
	direction = -1
	move_speed = 1
	move = true


func action_stop_moving_left():
	if move_speed * direction < 0:
		move_speed = 0
		$Animation.update()


func action_jump():
	jump = true
	if last_action == Action.JUMP:
		var repeat_timeout = OS.get_ticks_msec() - last_action_time
		if repeat_timeout <= 250:
			fly = true
			$Animation.update()
	last_action = Action.JUMP
	last_action_time = OS.get_ticks_msec()


func action_cancel_jump():
	cancel_jump = true


func action_move_down():
	move_down = true
	if last_action == Action.MOVE_DOWN:
		var repeat_timeout = OS.get_ticks_msec() - last_action_time
		if repeat_timeout <= 250:
			flying = false
			falling = true
			$Animation.update()
	last_action = Action.MOVE_DOWN
	last_action_time = OS.get_ticks_msec()


func action_stop_moving_down():
	move_down = false


func action_do_action():
	punch = true


func stop():
	velocity = Vector2.ZERO


func face_right():
	direction = 1


func face_left():
	direction = -1
