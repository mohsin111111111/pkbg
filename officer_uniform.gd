extends Area3D
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.is_wearing_disguise = true
		print("Equipped General's Uniform! Your cover is solid.")
		queue_free()
