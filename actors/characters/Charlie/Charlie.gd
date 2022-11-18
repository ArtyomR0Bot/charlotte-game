extends MovingBody


enum {DASHING = 1000, PUNCHING}


export var can_dash = true
export var dash_multiplier = 3
export var dash_time = 200
export var dash_cooldown = 500
export var punch_speed = 20

var dash_start = 0
var dash_end = 0


func process_state():
	match state:
		PUNCHING:
			var inertia = 0.5
			velocity.y = 0
			velocity.x = lerp(speed.x * movement_speed, velocity.x, inertia)
		DASHING:
			var inertia = 0.5
			velocity.y = 0
			var target_velocity = speed.x * movement_speed * dash_multiplier
			velocity.x = lerp(target_velocity, velocity.x, inertia)
			if OS.get_ticks_msec() - dash_start > dash_time:
				stop_dashing()
		_:
			.process_state()


func move_sideway(speed_x):
	if state == DASHING:
		stop_dashing()
	.move_sideway(speed_x)


func stop_moving():
	if state == DASHING:
		stop_dashing()
	.stop_moving()


func move_up():
	if state == DASHING:
		stop_dashing()
	.move_up()


func move_down():
	if state == DASHING:
		stop_dashing()
	.move_down()


func stop_flying():
	if character_mode != CharacterMode.FLY:
		if state == DASHING:
			stop_dashing()
	.stop_flying()


func do_action_a():
	if speed.x == 0:
		punch()
	else:
		dash()


func punch():
	if state == ON_FLOOR:
		speed.x = 1 if face_right else -1
		set_state(PUNCHING)


func dash():
	if can_dash and OS.get_ticks_msec() - dash_end > dash_cooldown:
		dash_start = OS.get_ticks_msec()
		set_state(DASHING, true)
		change_animation()


func stop_dashing():
	set_state(state_stack.pop_back())
	dash_end = OS.get_ticks_msec()
	change_animation()
