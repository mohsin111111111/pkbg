extends Node3D

var enemy_blueprint = preload("res://enemy.tscn")
@onready var timer =$Timer
func _on_timer_timeout():
	var new_zombie = enemy_blueprint.instantiate()
	get_parent().add_child(new_zombie)
	new_zombie.global_position = self.global_position
