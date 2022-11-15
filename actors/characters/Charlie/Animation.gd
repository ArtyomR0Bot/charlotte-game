extends Node2D


const DEBUG = false


onready var character = get_parent()
onready var last_state = character.state


func change():
	var dir_str = "_r" if character.face_right else "_l"
	match character.state:
		character.FALLING:
			if DEBUG:
				print("FALLING")
			var same_state = last_state == character.state
			set_animation($Body, "fall", dir_str, same_state)
			if last_state == character.FLYING:
				$AnimationPlayer.play("RESET")
		character.ON_FLOOR:
			if DEBUG:
				print("ON_FLOOR")
			if character.speed.x == 0:
				set_animation($Body, "idle", dir_str)
			else:
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
			$Wings.offset.x = 0 if character.face_right else 4
			if not keep_frame:
				$AnimationPlayer.play("fly")
		character.DASHING:
			if DEBUG:
				print("DASHING")
	last_state = character.state


func set_animation(sprite, name, dir_str, keep_frame = false):
	var full_name = name + dir_str
	if sprite.animation != full_name:
		if keep_frame:
			var current_frame = sprite.frame
			sprite.animation = full_name
			sprite.frame = current_frame
		else:
			sprite.animation = full_name
			sprite.frame = 0
		if not sprite.playing:
			sprite.play()
