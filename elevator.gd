extends AnimatableBody3D

var is_moving = false
var ride_height = 35.0 
var ride_time = 5.0 

var fuses_remaining = 3 
func power_box_destroyed():
	fuses_remaining -= 1
	print("Fuses left: ", fuses_remaining)
	
	if fuses_remaining <= 0 and not is_moving:
		start_elevator()

func start_elevator():
	is_moving = true
	print("Power restored! Elevator going up...")
	var tween = get_tree().create_tween()
	var target_y = global_position.y + ride_height
	tween.tween_property(self, "global_position:y", target_y, ride_time)
