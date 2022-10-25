extends StaticBody2D


var collapsing = false


func collision():
	if not collapsing:
		collapsing = true
		$AnimationPlayer.play("collapsing")
		$Timer.start()


func _on_Timer_timeout():
	queue_free()
