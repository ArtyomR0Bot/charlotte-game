extends KinematicBody2D


enum {NONE, MOVE_RIGHT, MOVE_LEFT, JUMP, MOVE_DOWN}
enum {FALLING, IDLE, RUNNING, JUMPING, FLYING, DASHING}


export var gravity = 25
export var run_speed = 150
export var jump_speed = 510
export var max_speed = 700
export var max_jumps = 1
export var dash_multiplier = 5
export var dash_time = 150
export var dash_cooldown = 500


var dash_end = 0
var dash_start = 0
var direction = 1
var in_air = true
var in_air_start = 0
var jump_start
var last_input
var last_input_time = 0
var limit_collision = false
var move_down = false
var move_speed = 0
var move_up = false
var num_jumps = 0
var on_ceiling = false
var on_floor = false
var on_wall = false
var running = false
var state = FALLING
var state_mem
var velocity: Vector2


func _physics_process(delta):
	var inertia = 0.8
	if state == FLYING:
		if move_up:
			velocity.y = -run_speed * scale.y
		elif move_down:
			velocity.y = run_speed * scale.y
	else:
		if on_floor:
			in_air = false
			num_jumps = 0
			if limit_collision:
				restore_collision()
			if jump_start:
				state = JUMPING
				$Animation.change()
			elif state == FALLING or state == JUMPING:
				if move_speed == 0:
					state = IDLE
				else:
					state = RUNNING
				$Animation.change()
			if jump_start:
				jump_start = false
		else:
			if state != DASHING:
				inertia = 0.95
				if in_air:
					if (num_jumps == 0
							and OS.get_ticks_msec() - in_air_start > 0):
						num_jumps = 1
					if (state != FALLING and state != JUMPING
							and OS.get_ticks_msec() - in_air_start > 200):
						state = FALLING
						$Animation.change()
				else:
					in_air = true
					in_air_start = OS.get_ticks_msec()
		if state == DASHING:
			velocity.y = 0
		else:
			velocity.y += gravity
	if state == DASHING:
		inertia = 0.5
		if OS.get_ticks_msec() - dash_start > dash_time:
			action_stop_dash()
	var remaining_velocity_x = velocity.x * inertia
	var move_velocity_x = (direction * move_speed
							* run_speed * scale.x * (1 - inertia))
	velocity.x = remaining_velocity_x + move_velocity_x
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	set_collision_mask_bit(2, not move_down)
	move_body(delta)


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
	if event.is_action_pressed("dash"):
		action_dash()
	if event.is_action_released("dash"):
		action_stop_dash()


func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			if move_speed > 0:
				if direction > 0:
					action_stop_moving_right()
				else:
					action_stop_moving_left()
			if move_up:
				action_cancel_jump()
			if move_down:
				action_stop_moving_down()


func move_body(delta):
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
	if num_wall_collisions > 1 and state != FLYING:
		for owner_id in get_shape_owners():
			var shape_owner = shape_owner_get_owner(owner_id)
			if shape_owner.one_way_collision:
				shape_owner.disabled = true
		limit_collision = true


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


func action_move_sideway(input):
	if state == DASHING:
		action_stop_dash()
	direction = -1 if input == MOVE_LEFT else 1
	running = true
	move_speed = 1
	if state == IDLE:
		state = RUNNING
	$Animation.change()
	last_input = input
	last_input_time = OS.get_ticks_msec()


func action_stop_moving_sideway(input):
	if state == DASHING:
		action_stop_dash()
	var rev = -1 if input == MOVE_LEFT else 1
	if running and direction * rev > 0:
		running = false
		move_speed = 0
		if state == RUNNING:
			state = IDLE
		$Animation.change()


func action_move_right():
	action_move_sideway(MOVE_RIGHT)


func action_stop_moving_right():
	action_stop_moving_sideway(MOVE_RIGHT)


func action_move_left():
	action_move_sideway(MOVE_LEFT)


func action_stop_moving_left():
	action_stop_moving_sideway(MOVE_LEFT)


func action_jump():
	if state == DASHING:
		action_stop_dash()
	if (last_input == JUMP
			and OS.get_ticks_msec() - last_input_time < 250):
		action_fly()
	if state == FLYING:
		move_up = true
	else:
		if num_jumps < max_jumps:
			num_jumps += 1
			velocity.y = -jump_speed * scale.y
			jump_start = true
	last_input = JUMP
	last_input_time = OS.get_ticks_msec()


func action_cancel_jump():
	if state == FLYING:
		move_up = false
		velocity.y = 0
	else:
		if state != DASHING:
			velocity.y /= 2


func action_move_down():
	if last_input == MOVE_DOWN:
		if OS.get_ticks_msec() - last_input_time < 250:
			action_stop_flying()
	last_input = MOVE_DOWN
	last_input_time = OS.get_ticks_msec()
	move_down = true


func action_stop_moving_down():
	move_down = false
	if state == FLYING:
		velocity.y = 0


func action_dash():
	if running and OS.get_ticks_msec() - dash_end > dash_cooldown:
		state_mem = state
		state = DASHING
		dash_start = OS.get_ticks_msec()
		move_speed = dash_multiplier
		$Animation.change()


func action_stop_dash():
	if state == DASHING:
		if state_mem == FLYING:
			state = FLYING
		else:
			state = state_mem
		dash_end = OS.get_ticks_msec()
		if move_speed > 1:
			move_speed = 1 if running else 0
		$Animation.change()


func action_fly():
	if state != FLYING:
		state = FLYING
		in_air = false
		num_jumps = max_jumps
		if limit_collision:
			restore_collision()
		state = FLYING
		$Animation.change()


func action_stop_flying():
	state = FALLING
	$Animation.change()


func reset():
	velocity = Vector2.ZERO
	state = IDLE


func face_right():
	direction = 1


func face_left():
	direction = -1
