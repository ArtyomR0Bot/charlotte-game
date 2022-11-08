extends KinematicBody2D


# actions
enum {NONE, MOVE_RIGHT, MOVE_LEFT, MOVE_SIDEWAY, STOP_MOVING,
		MOVE_UP, STOP_MOVING_UP, MOVE_DOWN, STOP_MOVING_DOWN,
		FLY, STOP_FLYING, ACTION_A, STOP_ACTION_A, DASH, STOP_DASHING}
# states
enum {FALLING, IDLE, RUNNING, JUMPING, FLYING, DASHING}


export var max_speed = 700
export var gravity = 25
export var run_speed = 150
export var jump_speed = 510
export var max_jumps = 1
export var dash_multiplier = 2
export var dash_time = 200
export var dash_cooldown = 500

# control
var direction = Vector2.ZERO
var button_a = false

# inner state
var state = FALLING
var last_state = state
var last_direction = Vector2.ZERO
var last_button_a = false
var face_right = true
var velocity: Vector2
var move_speed: Vector2
var move_up = false
var move_down = false
var in_air = true
var in_air_start = 0
var num_jumps = 0
var dash_start = 0
var dash_end = 0
var on_ceiling = false
var on_floor = false
var on_wall = false
var limit_collision = false
var last_action = NONE
var last_action_time = 0
var snap_pos: Vector2


func _physics_process(delta):
	do_actions(get_input_actions())
	var inertia = 0.8
	if state == FLYING:
		velocity.y = move_speed.y * run_speed
	else:
		if on_floor:
			in_air = false
			num_jumps = 0
			if limit_collision:
				restore_collision()
			if move_speed.y < 0:
				move_speed.y = 0
			elif state == JUMPING or state == FALLING:
				if move_speed.x == 0:
					state = IDLE
				else:
					state = RUNNING
				$Animation.change()
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
		if OS.get_ticks_msec() - dash_start > dash_time:
			do_action(STOP_DASHING)
		else:
			inertia = 0.5
	velocity.x = velocity.x * inertia
	if move_speed.x != 0:
		velocity.x += move_speed.x * run_speed * (1 - inertia)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	set_collision_mask_bit(2, move_speed.y <= 0)
	move_body(delta)


func get_kb_input_state():
	direction = Vector2.ZERO
	if Input.is_action_just_pressed("move_right"):
		direction.x = 1
	elif Input.is_action_just_pressed("move_left"):
		direction.x = -1
	elif Input.is_action_pressed("move_right") and last_direction.x > 0.5:
		direction.x = 1
	elif Input.is_action_pressed("move_left") and last_direction.x < -0.5:
		direction.x = -1
	if Input.is_action_just_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_just_pressed("move_down"):
		direction.y = 1
	elif Input.is_action_pressed("move_up") and last_direction.y < -0.5:
		direction.y = -1
	elif Input.is_action_pressed("move_down") and last_direction.y > 0.5:
		direction.y = 1
	button_a = Input.is_action_pressed("button_a")


func get_input_actions():
	get_kb_input_state()
	var actions = []
	if direction.x > 0.5:
		if last_direction.x <= 0.5:
			actions.append(MOVE_RIGHT)
	elif direction.x < -0.5:
		if last_direction.x >= -0.5:
			actions.append(MOVE_LEFT)
	elif last_direction.x < -0.5 or last_direction.x > 0.5:
		actions.append(STOP_MOVING)
	if direction.y < -0.5:
		if last_direction.y >= -0.5:
			actions.append(MOVE_UP)
	elif direction.y > 0.5:
		if last_direction.y <= 0.5:
			actions.append(MOVE_DOWN)
	elif last_direction.y < -0.5:
		actions.append(STOP_MOVING_UP)
	elif last_direction.y > 0.5:
		actions.append(STOP_MOVING_DOWN)
	if button_a and not last_button_a:
		actions.append(ACTION_A)
	elif not button_a and last_button_a:
		actions.append(STOP_ACTION_A)
	last_direction = direction
	last_button_a = button_a
	return actions


func do_actions(actions):
	for action in actions:
		do_action(action)


func do_action(action):
	match action:
		MOVE_RIGHT:
			face_right = true
			move_speed.x = 1
			do_action(MOVE_SIDEWAY)
		MOVE_LEFT:
			face_right = false
			move_speed.x = -1
			do_action(MOVE_SIDEWAY)
		MOVE_SIDEWAY:
			if state == IDLE:
				state = RUNNING
			$Animation.change()
		STOP_MOVING:
			if state == DASHING:
				do_action(STOP_DASHING)
			move_speed.x = 0
			if state == RUNNING:
				state = IDLE
				$Animation.change()
		MOVE_UP:
			if state == DASHING:
				do_action(STOP_DASHING)
			move_speed.y = -1
			if (last_action == MOVE_UP
					and OS.get_ticks_msec() - last_action_time < 250):
				do_action(FLY)
			elif state != FLYING:
				if num_jumps < max_jumps:
					num_jumps += 1
					velocity.y = -jump_speed
					state = JUMPING
					$Animation.change()
			last_action = MOVE_UP
			last_action_time = OS.get_ticks_msec()
		STOP_MOVING_UP:
			if state == FLYING:
				move_speed.y = 0
			else:
				if state != DASHING:
					velocity.y /= 2
		MOVE_DOWN:
			move_speed.y = 1
			if (last_action == MOVE_DOWN
					and OS.get_ticks_msec() - last_action_time < 250):
				do_action(STOP_FLYING)
			last_action = MOVE_DOWN
			last_action_time = OS.get_ticks_msec()
		STOP_MOVING_DOWN:
			move_speed.y = 0
		FLY:
			state = FLYING
			$Animation.change()
		STOP_FLYING:
			state = FALLING
			$Animation.change()
		ACTION_A:
			if move_speed.x != 0:
				do_action(DASH)
		STOP_ACTION_A:
			if state == DASHING:
				do_action(STOP_DASHING)
		DASH:
			if OS.get_ticks_msec() - dash_end > dash_cooldown:
				last_state = state
				state = DASHING
				move_speed.x *= dash_multiplier
				dash_start = OS.get_ticks_msec()
				$Animation.change()
		STOP_DASHING:
			state = last_state
			move_speed.x = 1 * sign(move_speed.x)
			dash_end = OS.get_ticks_msec()
			$Animation.change()


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
			if collision.collider is KinematicBody2D:
				var body: KinematicBody2D = collision.collider
				if body["motion/sync_to_physics"]:
					if snap_pos:
						position += body.position - snap_pos - collision.travel
					snap_pos = body.position
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
	else:
		snap_pos = Vector2.ZERO
	if num_wall_collisions > 1 and state != FLYING:
		for owner_id in get_shape_owners():
			var shape_owner = shape_owner_get_owner(owner_id)
			if shape_owner.z_index < 0:
				shape_owner.disabled = true
		limit_collision = true


func move_and_collide_ex(vel):
	var collision = move_and_collide(vel)
	if not collision:
		return
	if collision.local_shape.z_index < 0:
		if collision.collider.get_collision_layer_bit(2):
			position += collision.remainder
			return
	return collision


func restore_collision():
	for owner_id in get_shape_owners():
		var shape_owner = shape_owner_get_owner(owner_id)
		if shape_owner.z_index < 0:
			shape_owner.disabled = false
	limit_collision = false


func reset():
	velocity = Vector2.ZERO
	state = IDLE


func set_face_right(value):
	face_right = value
