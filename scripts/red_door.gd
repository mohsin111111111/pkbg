extends StaticBody3D

func _on_unblock_zone_body_entered(body):
		if body.is_in_group("Player"):
			if body.has_red_key ==true:
				queue_free()
		else:
			print("The door is locked. You need a red key!")
		
