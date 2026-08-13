extends Area3D

func _on_body_entered(body):
	if body.name == "Player":
		# Save the exact X, Y, Z coordinates of this checkpoint to our permanent memory!
		Global.respawn_position = global_position
		Global.has_checkpoint = true
		print("Checkpoint Reached!")
