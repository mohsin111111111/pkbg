extends RigidBody3D
@export var noise_radius: float = 10.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		return
	print("Clatter! Rock hit: ", body.name)
	alert_nearby_guards()
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
func alert_nearby_guards() -> void:
	var guards = get_tree().get_nodes_in_group("Guard")
	for guard in guards:
		var distance = global_position.distance_to(guard.global_position)
		if distance <= noise_radius:
			if guard.has_method("investigate_noise"):
				guard.investigate_noise(global_position)
