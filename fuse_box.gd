extends StaticBody3D
@export var elevator: Node3D 
var health = 10 
func take_damage(amount):
	health -= amount
	if health <= 0:
		print("Fuse box destroyed!")
		if elevator:
			elevator.power_box_destroyed()
		queue_free()
