extends Node3D

var is_rescued = false

func rescue():
	if not is_rescued:
		is_rescued = true
		print("HOSTAGE: Thank you! They might have taken him with others long time since we saw him")
		print("HOSTAGE: There is a supply chopper out back. Take it and go find him!")
		queue_free()
