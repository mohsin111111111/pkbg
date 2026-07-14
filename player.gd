extends CharacterBody3D

enum WeaponType {LASER, SHOTGUN, SNIPER}
var current_weapon = WeaponType.LASER
var weapon_db = {
	WeaponType.LASER: {"damage": 10, "rate": 0.2, "rays": 1, "spread": 0.0,"range": -50.0},
	WeaponType.SHOTGUN: {"damage": 12, "rate": 0.8, "rays": 6, "spread": 0.15, "range": -15.0},
	WeaponType.SNIPER: {"damage": 50, "rate": 1.5, "rays": 1, "spread": 0.0, "range": -2000.0}
}

const WALK_SPEED = 5.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 4.5

var current_speed = WALK_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002 
var health = 100
var score = 0
var has_red_key = false
var jump_count = 0
var max_jumps = 2
var is_crouching = false
var normal_speed = 5
var crouch_speed = 2
var max_ammo = 10
var current_ammo = max_ammo
var is_reloading = false
var recoil_amount = 0.05
var can_shoot = true 

const BASE_FOV = 75.0
const AIM_FOV = 40.0
const SNIPER_FOV = 15.0 

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var health_text = $HUD/HealthText
@onready var score_text = $HUD/ScoreText
@onready var ammo_text = $HUD/AmmoText 
@onready var damage_overlay = $CanvasLayer/DamageOverlay
@onready var sniper_scope = $HUD/SniperScope 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_text.text = "Health:" + str(health)
	score_text.text= "Score:" + str(score)
	update_ammo_text()
	raycast.add_exception(self)

func _unhandled_input(event):
	if event.is_action_pressed("weapon_1"): current_weapon = WeaponType.LASER
	if event.is_action_pressed("weapon_2"): current_weapon = WeaponType.SHOTGUN
	if event.is_action_pressed("weapon_3"): current_weapon = WeaponType.SNIPER

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("aim"):
		if current_weapon == WeaponType.SNIPER:
			camera.fov = lerp(camera.fov, SNIPER_FOV, 12 * delta)
			mouse_sensitivity = 0.0005 
			if sniper_scope:
				sniper_scope.visible = true
		else:
			mouse_sensitivity = 0.002 
			if sniper_scope:
				sniper_scope.visible = false
	else:
		camera.fov = lerp(camera.fov, BASE_FOV, 10 * delta)
		mouse_sensitivity = 0.002 
		if sniper_scope:
			sniper_scope.visible = false
	if Input.is_action_pressed("shoot") and current_ammo > 0 and not is_reloading and can_shoot:
		fire_weapon()
	if (Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("shoot") and current_ammo <= 0)) and current_ammo < max_ammo and not is_reloading:
		reload_weapon()
	if Input.is_action_just_pressed("melee") and can_shoot:
		melee_attack()
	if Input.is_action_just_pressed("interact"):
		try_interact()
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		jump_count = 0
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	var target_fov = BASE_FOV
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		current_speed = crouch_speed
		camera.position.y = 0.5
	elif Input.is_action_pressed("sprint"):
		is_crouching = false
		current_speed = SPRINT_SPEED
		#print("___ SIFT KEY DETECTED___")
		camera.position.y = 1.5
		target_fov = 95.0
	else:
		is_crouching = false
		current_speed = WALK_SPEED
		camera.position.y = 1.5
	if not Input.is_action_pressed("aim"):
		camera.fov = lerp(camera.fov, target_fov, 10 * delta)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	if velocity.y < -12.0:
		camera.fov = lerp(camera.fov, 100.0, 5 * delta)
		camera.rotation.z = lerp(camera.rotation.z, deg_to_rad(10), 3 * delta)
	elif is_on_floor():
		camera.rotation.z = lerp(camera.rotation.z, 0.0, 10 * delta)
	move_and_slide()
func fire_weapon():
	can_shoot = false
	current_ammo -= 1
	update_ammo_text()
	var stats = weapon_db[current_weapon]
	raycast.target_position = Vector3(0,0, stats.range)
	var original_target = raycast.target_position
	for i in range(stats.rays):
		var offset = Vector3.ZERO
		if stats.spread > 0:
			offset = Vector3(randf_range(-stats.spread, stats.spread), randf_range(-stats.spread, stats.spread), 0)
			camera.rotation.x += recoil_amount
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		raycast.target_position = original_target + (offset * original_target.length())
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var hit_object = raycast.get_collider()
			#var distance = global_position.distance_to(hit_object.global_position)
			print("---PULLED TRIGGER---")
			if hit_object.name == "StealthGuard":
				#if distance < 3.0:
					#print("Silent Takedown! Guard eliminated")
					#hit_object.queue_free()
				if current_weapon == WeaponType.SNIPER:
					print("Sniper Assasination! Guard eliminated cleanly.")
					hit_object.queue_free()
				else:
					print("Gunshot heard! Mission Failed.")
					get_tree().call_deferred("change_scene_to_file", "res://bunker_level.tscn")
					return
			else:
				print("Hit: ", hit_object.name, " with ", stats.damage, " damage!")
				if hit_object.has_method("take_damage"):
					hit_object.take_damage(stats.damage) 
				elif hit_object.get_parent() != null and hit_object.get_parent().has_method("take_damage"):
					hit_object.get_parent().take_damage(stats.damage)
	raycast.target_position = original_target
	await get_tree().create_timer(stats.rate).timeout
	can_shoot = true
func take_damage(amount):
	health -= amount
	health_text.text = "Health:" + str(health)
	print("Player took damage! Health is now:", health)
	flash_damage_screen()
	if health <= 0:
		print("Player died! Game Over!")
		get_tree().call_deferred("reload_current_scene")
func flash_damage_screen():
	var tween = get_tree().create_tween()
	tween.tween_property(damage_overlay, "color:a", 0.4, 0.1)
	tween.tween_property(damage_overlay, "color:a", 0.0, 0.5)
func add_score(amount):
	score += amount
	score_text.text = "Score: " + str(score)
func update_ammo_text():
	ammo_text.text = "Ammo:" + str(current_ammo) + "/" + str(max_ammo)
func reload_weapon():
	is_reloading = true
	ammo_text.text = "Reloading..."
	await get_tree().create_timer(1.5).timeout
	current_ammo = max_ammo
	is_reloading = false
	update_ammo_text() 
func heal(amount):
	health += amount
	if health > 100:
		health = 100
	health_text.text = "Health: " + str(health)
	
func try_interact():
	var original_target = raycast.target_position
	raycast.target_position = Vector3(0, 0, -3.0) 
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.has_method("rescue"):
			target.rescue()
			add_score(100) 
			print("Interaction Success!")
		elif target.get_parent() !=null and target.get_parent().has_method("rescue"):
			target.get_parent().rescue()
			add_score(100)
			print("Interaction Successful: Hostage Parent Saved!")
	raycast.target_position = original_target
	
func melee_attack():
	can_shoot = false 
	print("Swung Knife!")
	var original_target = raycast.target_position
	raycast.target_position = Vector3(0, 0, -2.5) 
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.name == "StealthGuard":
			print("Knife Execution! Guard eliminated silently.")
			target.queue_free()
		elif target.has_method("take_damage"):
			print("Stabbed ", target.name, " for 50 damage!")
			target.take_damage(50)
	raycast.target_position = original_target
	await get_tree().create_timer(0.5).timeout 
	can_shoot = true
