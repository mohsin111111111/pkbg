extends Node3D
var is_rescued = false
func rescue():
	if not is_rescued:
		is_rescued = true
		print("Hostage Rescued! Team secured.")
		queue_free()
