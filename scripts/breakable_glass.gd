extends StaticBody3D

@onready var glass_mesh = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@onready var shatter_particles = $GPUParticles3D

var is_broken = false
func take_damage(_amount):
	if is_broken:
		return 
	is_broken = true
	print("SMASH! Glass broken.")
	glass_mesh.visible = false
	collision_shape.set_deferred("disabled", true)
	shatter_particles.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
