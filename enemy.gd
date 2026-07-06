extends CharacterBody3D
const SPEED = 3
var health = 3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#var speed = 2.0 
@onready var player = get_tree().get_first_node_in_group("Player")
#@onready var nav_agent = $'NavigationAgent3D'
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if player !=null:
		var direction = global_position.direction_to(player.global_position)
		direction.y = 0
		#nav_agent.target_position = player.global_position
		#var next_location = nav_agent.get_next_path_position()
		#var direction = (next_location-global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z),Vector3.UP)
	move_and_slide()
func take_damage():
	health -= 1
	if health <= 0:
		player.add_score(1)
		queue_free()


#func _on_attack_zone_body_entered(body: Node3D) -> void:
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
	#pass # Replace with function body.


func _on_attack_zone_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
