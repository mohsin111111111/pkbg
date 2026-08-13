extends Control
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass 


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.scn")
