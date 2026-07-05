extends CharacterBody3D

var health = 3
var speed = 2.0 
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var nav_agent = $'NavigationAgent3D'
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	if player:
		nav_agent.target_position = player.global_position
		var next_location = nav_agent.get_next_path_position()
		var direction = (next_location-global_position).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	move_and_slide()
func take_damage():
	health -= 1
	if health <= 0:
		player.add_score(1)
		queue_free()


func _on_attack_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(20)
	#pass # Replace with function body.
