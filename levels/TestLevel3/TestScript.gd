extends Node


func _ready():
	reset()


func _on_Start_body_entered(body):
	body.user_input = false
	body.do_action(body.MOVE_RIGHT)
	$Jump.set_deferred("monitoring", true)


func _on_Jump_body_entered(body):
	$Jump.set_deferred("monitoring", false)
	body.do_action(body.MOVE_UP)
	$JumpAndDash.monitoring = true


func _on_JumpAndDash_body_entered(body):
	body.do_action(body.MOVE_UP)


func _on_JumpAndDash_body_exited(body):
	body.do_action(body.DASH)
	$JumpAndDash.set_deferred("monitoring", false)
	$Stop.set_deferred("monitoring", true)


func _on_Stop_body_entered(body):
	$Stop.set_deferred("monitoring", false)
	body.do_action(body.STOP_MOVING)
	body.user_input = true


func reset():
	$Start/AnimationPlayer.play("RESET")
	$Start/AnimationPlayer.play("move")
