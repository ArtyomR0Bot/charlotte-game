extends Node2D


const DEBUG = false


onready var character = get_parent()
onready var last_state = character.state


func change():
	return
	var dir_str = "_l" if character.direction < 0 else "_r"
	match character.state:
		character.FALLING:
			if DEBUG:
				print("FALLING")
			set_animation($Body, "fall", dir_str, true)
			if last_state == character.FLYING:
				$AnimationPlayer.play("RESET")
		character.IDLE:
			if DEBUG:
				print("IDLE")
			set_animation($Body, "idle", dir_str)
		character.RUNNING:
			if DEBUG:
				print("RUNNING")
			set_animation($Body, "run", dir_str)
		character.JUMPING:
			if DEBUG:
				print("JUMPING")
			var keep_frame = character.state == last_state
			set_animation($Body, "jump", dir_str, keep_frame)
		character.FLYING:
			if DEBUG:
				print("FLYING")
			var keep_frame = character.state == last_state
			set_animation($Body, "fly", dir_str, keep_frame)
			$Wings.offset.x = 4 if character.direction < 0 else 0
			if not keep_frame:
				$AnimationPlayer.play("fly")
		character.DASHING:
			if DEBUG:
				print("DASHING")
		character.AFTER_DASH:
			if DEBUG:
				print("AFTER_DASH")
	last_state = character.state


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
