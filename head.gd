extends Area3D


func take_damage(amount):
	print("BOOM HEADSHOT!")
	var main_zombie=get_parent()
	if main_zombie != null and main_zombie.has_method("take_damage"):
		main_zombie.health = 0
		main_zombie.take_damage(amount)
