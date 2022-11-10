extends Node


func _ready():
	reset()


func _on_Start_body_entered(body):
	body.user_input = false
	body.action_stop_flying()
	body.action_move_right()
	$Jump.set_deferred("monitoring", true)


func _on_Jump_body_entered(body):
	$Jump.set_deferred("monitoring", false)
	body.action_move_up()
	$JumpAndDash.monitoring = true


func _on_JumpAndDash_body_entered(body):
	body.action_move_up()


func _on_JumpAndDash_body_exited(body):
	body.action_dash()
	$JumpAndDash.set_deferred("monitoring", false)
	$Stop.set_deferred("monitoring", true)


func _on_Stop_body_entered(body):
	$Stop.set_deferred("monitoring", false)
	body.action_stop_moving()
	body.user_input = true


func reset():
	$Start/AnimationPlayer.play("RESET")
	$Start/AnimationPlayer.play("move")
