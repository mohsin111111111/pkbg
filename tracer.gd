extends Node3D
const SPEED = 40
func _ready():
	await get_tree().create_timer(1.0).timeout
	queue_free()
func _process(delta):
	global_position += -global_transform.basis.z * SPEED * delta
