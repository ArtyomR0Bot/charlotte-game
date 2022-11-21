extends MovingBody


const DASH_MULTIPLIER = 3
const PUNCH_SPEED = 100


enum {DASHING = 1000}


var punching = false


onready var dash_timer = $DashTimer
onready var punch_timer = $PunchTimer
onready var dash_cooldown_timer = $DashCooldownTimer


func process_state():
	match state:
		DASHING:
			var inertia = 0.5
			velocity.y = 0
			var target_velocity = speed.x * movement_speed * DASH_MULTIPLIER
			velocity.x = lerp(target_velocity, velocity.x, inertia)
			if dash_timer.is_stopped():
				stop_dashing()
		_:
			.process_state()
	if punching:
		var inertia = 0.5
		var dir = 1 if face_right else -1
		velocity.x = lerp(PUNCH_SPEED * dir, velocity.x, inertia)
		if punch_timer.is_stopped():
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
	if dash_cooldown_timer.is_stopped():
		set_state(DASHING, true)
		dash_timer.start()


func stop_dashing():
	if state == DASHING:
		set_state(state_stack.pop_back())
		dash_cooldown_timer.start()


func punch():
	if not punching and (state == ON_FLOOR or state == FALLING
			or state == JUMPING or state == FLYING):
		punching = true
		punch_timer.start()


func stop_punching():
	if punching:
		punching = false
