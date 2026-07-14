extends StaticBody3D
@onready var path_follower = get_parent()
var patrol_speed = 3.0
var player_in_hearing_zone = false
var player_node = null
func _physics_process(delta):
	
	if path_follower is PathFollow3D:
		path_follower.progress += patrol_speed * delta
	if player_in_hearing_zone and player_node != null:
		if player_node.is_crouching == false:
			catch_player("The guard heard your footsteps!")
func _on_vision_zone_body_entered(body):
	if body.name == "Player":
		catch_player("The guard saw you!")
func _on_hearing_zone_body_entered(body):
	if body.name == "Player":
		player_in_hearing_zone = true
		player_node = body 
func _on_hearing_zone_body_exited(body):
	if body.name == "Player":
		player_in_hearing_zone = false
		player_node = null
func catch_player(reason):
	print("MISSION FAILED: ", reason)
	get_tree().call_deferred("change_scene_to_file","res://bunker_level.tscn")
