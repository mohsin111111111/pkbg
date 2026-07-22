extends Area3D
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.heal(25)
		queue_free() 
		
