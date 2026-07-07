extends  StaticBody3D
func take_damage():
	print("Camera destroyed! The area is secure.")
	queue_free()
func _on_vision_zone_body_entered(body):
	if body.is_in_group("Player"):
		print(" ALARM TRIGGERED! PLAYER DETECTED!")
		get_tree().call_group("Enemy", "sound_alarm")
