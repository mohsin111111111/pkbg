extends CSGBox3D
var is_opening = false
func _process(delta):
	if is_opening == true:
		position.y += 2.0 * delta 
		if position.y > 5.0: 
			queue_free()
func open_door():
	print("Computer signal received! Opening blast door...")
	is_opening = true
