extends CharacterBody3D 
const WALK_SPEED = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_following = false
var player_node = null
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_following and player_node != null:
		nav_agent.target_position = player_node.global_position
		if global_position.distance_to(player_node.global_position) > 2.0:
			var next_pos = nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_pos)
			direction.y = 0 
			direction = direction.normalized()
			
			velocity.x = direction.x * WALK_SPEED
			velocity.z = direction.z * WALK_SPEED
			
			if direction.length_squared() > 0.01:
				look_at(global_position + direction, Vector3.UP)
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
			velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
			
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
	move_and_slide()
func rescue() -> void:
	if not is_following:
		print("HOSTAGE: Thank you! They might have taken him with others long time since we saw him")
		print("HOSTAGE: There is a supply chopper out back. Take it and go find him!")
		is_following = true 
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player_node = players[0]
