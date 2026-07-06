extends Area3D


func take_damage():
	print("BOOM HEADSHOT!")
	var zombie=get_parent()
	
	zombie.take_damage()
	zombie.take_damage()
	zombie.take_damage()
