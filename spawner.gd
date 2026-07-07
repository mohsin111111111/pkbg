extends Node3D

var enemy_blueprint = preload("res://enemy.tscn")
@onready var timer =$Timer
func _on_timer_timeout():
	var new_zombie = enemy_blueprint.instantiate()
	get_parent().add_child(new_zombie)
	var random_x = randf_range(-3.0 ,3.0)
	var random_z = randf_range(-3.0 , 3.0)
	new_zombie.global_position = self.global_position + Vector3(random_x , 0 , random_z)
