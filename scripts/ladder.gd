extends Area3D

func _on_body_entered(body):
	if body.name == "Player":
		body.is_on_ladder = true

func _on_body_exited(body):
	if body.name == "Player":
		body.is_on_ladder = false
		
