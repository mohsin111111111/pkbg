extends Area3D

func _on_body_entered(body):
	if body.name == "Player":
		print("Get to the chopper!")
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/victory_screen.tscn")
