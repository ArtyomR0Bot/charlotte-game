extends Node2D


enum State {FALLING, IDLE, RUNNING, JUMPING, FLYING, PUNCHING}


var last_state = State.FALLING
var state


onready var character = get_parent()


func update():
	var dir_str = "_l" if character.direction < 0 else "_r"
	if character.punching:
		state = State.PUNCHING
	elif character.flying:
		state = State.FLYING
	elif character.jumping:
		state = State.JUMPING
	elif character.falling:
		state = State.FALLING
	elif character.move_speed > 0:
		state = State.RUNNING
	else:
		state = State.IDLE
	match last_state:
		State.FLYING:
			if state == State.PUNCHING:
				var anim_name = $AnimationPlayer.current_animation
				var anim = $AnimationPlayer.get_animation(anim_name)
				var tr_id_1 = anim.find_track("Body:animation")
				var tr_id_2 = anim.find_track("Body:frame")
				anim.track_set_enabled(tr_id_1, false)
				anim.track_set_enabled(tr_id_2, false)
			elif state != last_state:
				$AnimationPlayer.play("RESET")


	match state:
		State.FLYING:
			$AnimationPlayer.play("fly" + dir_str)
		State.PUNCHING:
			$ActionPlayer.play("punch" + dir_str)
		State.JUMPING:
			if character.jump:
				set_animation($Body, "jump", dir_str, false, true)
			else:
				set_animation($Body, "jump", dir_str, true)
		State.FALLING:
			set_animation($Body, "fall", dir_str, true)
		State.RUNNING:
			set_animation($Body, "run", dir_str)
		State.IDLE:
			set_animation($Body, "idle", dir_str)
	last_state = state


func set_animation(sprite, name, dir_str, keep_frame = false, restart = false):
	var full_name = name + dir_str
	if restart or sprite.animation != full_name:
		if keep_frame:
			var current_frame = sprite.frame
			sprite.animation = full_name
			sprite.frame = current_frame
		else:
			sprite.animation = full_name
			sprite.frame = 0
		if not sprite.playing:
			sprite.play()


func _on_ActionPlayer_animation_finished(anim_name):
	if anim_name == "punch_r" or anim_name == "punch_l":
		character.punching = false
		$ActionPlayer.stop()
		$ActionPlayer.play("RESET")
		for anim_name_2 in ["fly_r", "fly_l"]:
			var anim = $AnimationPlayer.get_animation(anim_name_2)
			var tr_id_1 = anim.find_track("Body:animation")
			var tr_id_2 = anim.find_track("Body:frame")
			anim.track_set_enabled(tr_id_1, true)
			anim.track_set_enabled(tr_id_2, true)
		update()
