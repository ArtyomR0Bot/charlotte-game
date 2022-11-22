extends Node


export var user_input = false


var direction = Vector2.ZERO
var last_direction = Vector2.ZERO
var button_a = false


onready var character = $"../Charlie"


func _physics_process(_delta):
	get_user_input()


func get_user_input():
	if user_input and character:
		get_kb_input_state()
		set_last_input_state()
		set_character_input()


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


func set_last_input_state():
	last_direction = direction


func set_character_input():
	character.direction = direction
	character.button_a = button_a
