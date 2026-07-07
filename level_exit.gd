extends Area3D
func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player rreached the door! Loading the Bunker...")
		get_tree().change_scene_to_file.call_deferred("res://bunker_level.tscn")
