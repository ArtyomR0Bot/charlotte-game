extends Node


func _ready():
	reset()


func _on_Start_body_entered(body: Character):
	if body.character_mode != Character.CharacterMode.FLY and body.can_dash:
		body.user_input = false
		body.stop_flying()
		body.move_right()
		$Jump.set_deferred("monitoring", true)


func _on_Jump_body_entered(body: Character):
	$Jump.set_deferred("monitoring", false)
	body.move_up()
	$JumpAndDash.set_deferred("monitoring", true)


func _on_JumpAndDash_body_entered(body: Character):
	body.move_up()


func _on_JumpAndDash_body_exited(body: Character):
	body.dash()
	$JumpAndDash.set_deferred("monitoring", false)
	$Stop.set_deferred("monitoring", true)


func _on_Stop_body_entered(body: Character):
	$Stop.set_deferred("monitoring", false)
	body.stop_moving()
	body.user_input = true


func reset():
	$Start/AnimationPlayer.play("RESET")
	$Start/AnimationPlayer.play("move")
