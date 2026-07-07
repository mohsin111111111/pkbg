extends CharacterBody3D
const SPEED = 3
var health = 3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var holds_key= false
@export var is_guard = false
var key_blueprint = preload("res://red_key.tscn")
var player = null
@onready var gun_ray = $GunRay
var can_shoot = true 
var gun_damage = 10 
func _ready():
	print("A zombie just spawnned! Is it a guard?" , is_guard)
	if gun_ray != null:
		gun_ray.add_exception(self)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player != null:
		if is_guard == false:
			var direction = global_position.direction_to(player.global_position)
			direction.y = 0
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		elif is_guard == true:
			velocity.x = 0
			velocity.z = 0
			fire_at_player()
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z),Vector3.UP)
	move_and_slide()
func fire_at_player():
	if can_shoot and gun_ray.is_colliding():
		var hit_object = gun_ray.get_collider()
		if hit_object.is_in_group("Player") and hit_object.has_method("take_damage"):
			hit_object.take_damage(gun_damage)
			print("Guard shot the player for ", gun_damage, "damage!")
			can_shoot = false
			await get_tree().create_timer(1.5).timeout
			can_shoot = true
func take_damage():
	health -= 1
	print("Body took damage! Health is now: ", health)
	if health <= 0:
		print("Health hit 0. Zombie is dying!")
		if holds_key == true:
			var dropped_key = key_blueprint.instantiate()
			get_parent().add_child(dropped_key)
			dropped_key.global_position = self.global_position +  Vector3(0,1,0)
		if player !=null:
			player.add_score(1)
		queue_free()


#func _on_attack_zone_body_entered(body: Node3D) -> void:
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
	#pass # Replace with function body.


func _on_attack_zone_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(20)#: Node3D) -> void:
	#pass # Replace with function body.
