extends CharacterBody3D

var health = 3
var speed = 2.0 
@onready var player = get_tree().get_first_node_in_group("Player")
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	if player:
		var direction = (player.global_position).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	move_and_slide()
func take_damage():
	health -= 1
	if health <= 0:
		queue_free()
