extends MovingBody


enum {DASHING = 1000}


export var can_dash = true
export var dash_multiplier = 3
export var dash_time = 200
export var dash_cooldown = 500

var dash_start = 0
var dash_end = 0


func process_state():
	match state:
		DASHING:
			var inertia = 0.5
			velocity.y = 0
			velocity.x = lerp(speed.x * movement_speed, velocity.x, inertia)
			if OS.get_ticks_msec() - dash_start > dash_time:
				stop_dashing()
		_:
			.process_state()


func move_sideway():
	if state == DASHING:
		stop_dashing()
	.move_sideway()


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
	if speed.x != 0:
		dash()


func dash():
	if (can_dash and state != DASHING
			and OS.get_ticks_msec() - dash_end > dash_cooldown):
		speed.x = sign(speed.x) * dash_multiplier
		set_state(DASHING, true)
		dash_start = OS.get_ticks_msec()
		change_animation()


func stop_dashing():
	set_state(state_stack.pop_back())
	speed.x = 1 * sign(speed.x)
	dash_end = OS.get_ticks_msec()
	change_animation()
