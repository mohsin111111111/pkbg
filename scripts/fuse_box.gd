extends StaticBody3D
@export var elevator: Node3D 
@export var blast_door: Node3D 
var health = 10 
func take_damage(amount):
	health -= amount
	if health <= 0:
		print("Fuse box destroyed!")
		if elevator:
			elevator.power_box_destroyed()
		if blast_door != null:
			print("SUCCESS: Blast door found! Deleting it now!")
			blast_door.queue_free() 
		else:
			print("ERROR: The Fuse doesn't know what door to delete! The slot is empty!")
		queue_free()
func hack_door():
	print("Drone zapped the fuse!")
	take_damage(10)
