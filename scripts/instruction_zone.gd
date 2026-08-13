extends Area3D


@export var hint_text : String = "Type your hint here!"

func _on_body_entered(body):
	if body.name == "Player":
		body.show_instruction(hint_text)
func _on_body_exited(body):
	if body.name == "Player":
		body.hide_instruction()
