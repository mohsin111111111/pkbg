extends CharacterBody3D

@export var walk_speed: float = 3.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var original_post: Vector3
enum State { IDLE, INVESTIGATING, RETURNING }
var current_state = State.IDLE

func _ready():
	await get_tree().physics_frame
	original_post = global_position

func investigate_noise(noise_position: Vector3) -> void:
	print("Response Guard: Moving to investigate!")
	current_state = State.INVESTIGATING
	nav_agent.target_position = noise_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if current_state != State.IDLE:
		if nav_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0
			
			if current_state == State.INVESTIGATING:
				current_state = State.IDLE 
				print("Response Guard: Nothing here... returning to post.")
				await get_tree().create_timer(3.0).timeout
				current_state = State.RETURNING
				nav_agent.target_position = original_post
			elif current_state == State.RETURNING:
				print("Response Guard: Back at my post.")
				current_state = State.IDLE
		else:
			var next_pos = nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_pos)
			direction.y = 0 
			direction = direction.normalized()
			velocity.x = direction.x * walk_speed
			velocity.z = direction.z * walk_speed
			if direction.length_squared() > 0.01:
				look_at(global_position + direction, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	move_and_slide()
func _on_vision_zone_body_entered(body: Node3D) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	var player_node = null
	if players.size() > 0:
		player_node = players[0]
	if body.name == "Player": 
		if player_node != null and player_node.is_wearing_disguise == true:
			print("Response Guard: 'Prisoner transfer authorized, General.'")
		else:
			print("MISSION FAILED: Intruder spotted at the checkpoint!")
			get_tree().call_deferred("reload_current_scene") 
	elif body.is_in_group("Hostage"):
		if player_node != null and player_node.is_wearing_disguise == true:
			print("Response Guard: 'Keep those prisoners in line, General!'")
		else:
			print("MISSION FAILED: The hostages are escaping without an escort!")
			get_tree().call_deferred("reload_current_scene") 
func take_damage(amount: int) -> void:
	print("MISSION FAILED: This guard is heavily armored. Your attack triggered the alarm!")
	get_tree().call_deferred("reload_current_scene")
