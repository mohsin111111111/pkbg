extends CharacterBody3D

const SPEED = 3
var health = 3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var holds_key= false
@export var is_guard = false
@export var is_static = false
@export var is_sniper = false 

var key_blueprint = preload("res://red_key.tscn")
var tracer_scene = preload("res://tracer.tscn")

var player = null
var can_shoot = true 
var gun_damage = 10 
var alarm_sounded = false
@onready var gun_ray = $GunRay
@onready var nav_agent = $NavigationAgent3D 
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
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		if is_guard == false:
			var direction = global_position.direction_to(player.global_position)
			direction.y = 0
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		elif is_guard == true:
			if alarm_sounded == true and is_static == false:
				nav_agent.target_position = player.global_position
				var next_location = nav_agent.get_next_path_position()
				var new_direction = global_position.direction_to(next_location)
				new_direction.y = 0
				velocity.x = new_direction.x * SPEED
				velocity.z = new_direction.z * SPEED
			else:
				velocity.x = 0
				velocity.z = 0
			if is_sniper == true:
				if alarm_sounded == true:
					fire_at_player()
			else:
				fire_at_player()
	move_and_slide()

func fire_at_player():
	if player !=null:
		gun_ray.target_position = gun_ray.to_local(player.global_position + Vector3(0,1,0))
	if can_shoot and gun_ray.is_colliding():
		var hit_object = gun_ray.get_collider()
		print("Guard fired his laser, and it hit: ", hit_object.name) 
		
		var tracer = tracer_scene.instantiate()
		get_tree().root.add_child(tracer)
		tracer.global_transform = gun_ray.global_transform
		if hit_object.is_in_group("Player") and hit_object.has_method("take_damage"):
			hit_object.take_damage(gun_damage)
			print("Guard shot the player for ", gun_damage, "damage!")
		can_shoot = false
		await get_tree().create_timer(1.5).timeout
		can_shoot = true
func take_damage(amount):
	health -= amount
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
func _on_attack_zone_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
func sound_alarm():
	if is_guard == true:
		print("Guard heard the alarm! Engaging target!")
		alarm_sounded = true
