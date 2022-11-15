extends KinematicBody2D

class_name MovingBody


enum CharacterMode {WALK_AND_FLY, WALK, FLY}
# actions
enum {NONE, MOVE_UP, MOVE_DOWN}
# states
enum {FALLING, ON_FLOOR, JUMPING, FLYING, DASHING}


export(CharacterMode) var character_mode = CharacterMode.WALK_AND_FLY
export var user_input = false
export var can_dash = true
export var max_speed = 700
export var gravity = 25
export var movement_speed = 150
export var jump_speed = 510
export var max_jumps = 1
export var dash_multiplier = 3
export var dash_time = 200
export var dash_cooldown = 500

# control
var direction = Vector2.ZERO
var button_a = false

# inner state
var state = FALLING
var state_stack = []
var last_direction = Vector2.ZERO
var last_button_a = false
var face_right = true
var velocity: Vector2
var speed: Vector2
var in_air = true
var in_air_start = 0
var num_jumps = 0
var dash_start = 0
var dash_end = 0
var on_ceiling = false
var on_floor = false
var on_wall = false
var last_action = NONE
var last_action_time = 0
var snap_pos: Vector2

onready var has_animation = has_node("Animation")


func _ready():
	if character_mode == CharacterMode.FLY:
		state = FLYING
	change_animation()


func _physics_process(delta):
	if user_input:
		get_user_input()
	do_input_actions()
	var inertia = 0.8
	if state == FLYING:
		velocity.y = lerp(speed.y * movement_speed, velocity.y, inertia)
	elif state == FALLING:
		velocity.y += gravity
		inertia = 0.95
		if on_floor and velocity.y >= 0:
			in_air = false
			num_jumps = 0
			state = ON_FLOOR
			change_animation()
	elif state == JUMPING:
		velocity.y += gravity
		inertia = 0.95
		if velocity.y >= 0:
			state = FALLING
			change_animation()
	elif state == ON_FLOOR:
		velocity.y += gravity
		if on_floor:
			if in_air:
				in_air = false
				if num_jumps > 0:
					num_jumps = 0
		else:
			if in_air:
				if num_jumps > 0:
					inertia = 0.95
					if OS.get_ticks_msec() - in_air_start > 200:
						state = FALLING
						change_animation()
				elif OS.get_ticks_msec() - in_air_start > 0:
					num_jumps = 1
			else:
				in_air = true
				in_air_start = OS.get_ticks_msec()
	elif state == DASHING:
		velocity.y = 0
		inertia = 0.5
		if OS.get_ticks_msec() - dash_start > dash_time:
			stop_dashing()
	velocity.x = lerp(speed.x * movement_speed, velocity.x, inertia)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	move_body(delta)


func get_user_input():
	get_kb_input_state()


func do_input_actions():
	if direction.x > 0.5:
		if last_direction.x <= 0.5:
			move_right()
	elif direction.x < -0.5:
		if last_direction.x >= -0.5:
			move_left()
	elif last_direction.x < -0.5 or last_direction.x > 0.5:
		stop_moving()
	if direction.y < -0.5:
		if last_direction.y >= -0.5:
			move_up()
	elif direction.y > 0.5:
		if last_direction.y <= 0.5:
			move_down()
	elif last_direction.y < -0.5:
		stop_moving_up()
	elif last_direction.y > 0.5:
		stop_moving_down()
	if button_a and not last_button_a:
		do_action_a()
	elif not button_a and last_button_a:
		stop_action_a()
	last_direction = direction
	last_button_a = button_a


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


func move_right():
	face_right = true
	speed.x = 1
	move_sideway()


func move_left():
	face_right = false
	speed.x = -1
	move_sideway()


func move_sideway():
	if state == DASHING:
		stop_dashing()
	change_animation()


func stop_moving():
	if state == DASHING:
		stop_dashing()
	speed.x = 0
	change_animation()


func move_up():
	speed.y = -1
	if state == DASHING:
		stop_dashing()
	if (last_action == MOVE_UP
			and OS.get_ticks_msec() - last_action_time < 250):
		fly()
	elif state == FALLING or state == ON_FLOOR or state == JUMPING:
		if num_jumps < max_jumps:
			num_jumps += 1
			velocity.y = -jump_speed
			state = JUMPING
			change_animation()
	last_action = MOVE_UP
	last_action_time = OS.get_ticks_msec()


func stop_moving_up():
	speed.y = 0
	if state == JUMPING:
		velocity.y /= 2


func move_down():
	speed.y = 1
	if (last_action == MOVE_DOWN
			and OS.get_ticks_msec() - last_action_time < 250):
		stop_flying()
	last_action = MOVE_DOWN
	last_action_time = OS.get_ticks_msec()


func stop_moving_down():
	speed.y = 0


func fly():
	if character_mode != CharacterMode.WALK:
		num_jumps = max_jumps
		state = FLYING
		change_animation()


func stop_flying():
	if character_mode != CharacterMode.FLY:
		if state == DASHING:
			stop_dashing()
		state = FALLING
		change_animation()


func do_action_a():
	if speed.x != 0:
		dash()


func stop_action_a():
	pass


func dash():
	if can_dash and OS.get_ticks_msec() - dash_end > dash_cooldown:
		state_stack.push_back(state)
		state = DASHING
		speed.x *= dash_multiplier
		dash_start = OS.get_ticks_msec()
		change_animation()


func stop_dashing():
	state = state_stack.pop_back()
	speed.x = 1 * sign(speed.x)
	dash_end = OS.get_ticks_msec()
	change_animation()


func move_body(delta):
	on_floor = false
	on_wall = false
	on_ceiling = false
	var num_collisions = 0
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


func move_and_collide_ex(vel):
	set_collision_mask_bit(2, speed.y <= 0)
	var collision = move_and_collide(vel)
	if (collision
			and collision.local_shape.z_index < 0
			and collision.collider.get_collision_layer_bit(2)):
		set_collision_mask_bit(2, false)
		collision = move_and_collide(collision.remainder)
		set_collision_mask_bit(2, speed.y <= 0)
	return collision


func restore_collision():
	for owner_id in get_shape_owners():
		var shape_owner = shape_owner_get_owner(owner_id)
		if shape_owner.z_index < 0:
			shape_owner.disabled = false


func reset(f_right = true):
	velocity = Vector2.ZERO
	face_right = f_right
	state = FALLING


func change_animation():
	if has_animation:
		$Animation.change()
