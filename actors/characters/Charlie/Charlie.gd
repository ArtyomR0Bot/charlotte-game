extends MovingBody


const DASH_MULTIPLIER = 3
const DASH_TIME = 200
const DASH_COOLDOWN = 500
const PUNCH_SPEED = 100
const PUNCH_TIME = 200


enum {DASHING = 1000}


var dash_start: int
var dash_end: int
var punching: bool
var punch_start: int


func time_elapsed(start: int, timeout: int):
	return OS.get_ticks_msec() - start >= timeout


func process_state():
	match state:
		DASHING:
			var inertia = 0.5
			velocity.y = 0
			var target_velocity = speed.x * movement_speed * DASH_MULTIPLIER
			velocity.x = lerp(target_velocity, velocity.x, inertia)
			if time_elapsed(dash_start, DASH_TIME):
				stop_dashing()
		_:
			.process_state()
	if punching:
		var inertia = 0.5
		var dir = 1 if face_right else -1
		velocity.x = lerp(PUNCH_SPEED * dir, velocity.x, inertia)
		if time_elapsed(punch_start, PUNCH_TIME):
			stop_punching()


func move_sideway(speed_x):
	if state == DASHING:
		stop_dashing()
	if punching:
		stop_punching()
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
		if punching:
			stop_punching()
	.stop_flying()


func do_action_a():
	if speed.x != 0:
		dash()
	else:
		punch()


func dash():
	if time_elapsed(dash_end, DASH_COOLDOWN):
		set_state(DASHING, true)
		dash_start = OS.get_ticks_msec()


func stop_dashing():
	if state == DASHING:
		set_state(state_stack.pop_back())
		dash_end = OS.get_ticks_msec()


func punch():
	if (state == ON_FLOOR or state == FALLING
			or state == JUMPING or state == FLYING):
		if not punching:
			punching = true
			punch_start = OS.get_ticks_msec()


func stop_punching():
	if punching:
		punching = false
