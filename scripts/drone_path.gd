extends Path3D

@export var drone_speed: float = 5.0 

@onready var patrol_follower: PathFollow3D = $DronePatrol
@onready var sight_cone: Area3D = $DronePatrol/SurveillanceDrone/SightCone
@onready var line_of_sight: RayCast3D = $DronePatrol/SurveillanceDrone/LineOfSight
var player: CharacterBody3D = null
func _ready() -> void:
	sight_cone.body_entered.connect(_on_sight_cone_body_entered)
	sight_cone.body_exited.connect(_on_sight_cone_body_exited)
func _process(delta: float) -> void:
	patrol_follower.progress += drone_speed * delta
	if player != null:
		check_if_player_is_seen()
func _on_sight_cone_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
func _on_sight_cone_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
func check_if_player_is_seen() -> void:
	var player_position = player.global_position + Vector3(0, 1, 0) 
	line_of_sight.target_position = line_of_sight.to_local(player_position)
	line_of_sight.force_raycast_update() 
	if line_of_sight.is_colliding():
		var hit_object = line_of_sight.get_collider()
		if hit_object == player:
			print("CAUGHT BY THE DRONE! MISSION FAILED.")
			get_tree().reload_current_scene()
