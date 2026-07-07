extends CharacterBody3D
const WALK_SPEED = 5.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 4.5

var current_speed=WALK_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002
var health=100
var score = 0
var has_red_key=false
var jump_count=0
var max_jumps=2
var max_ammo=10
var current_ammo= max_ammo
var is_reloading = false
var recoil_amount = 0.05
const BASE_FOV = 75.0
const AIM_FOV = 40.0

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var health_text = $HUD/HealthText
@onready var score_text = $HUD/ScoreText
@onready var ammo_text = $HUD/AmmoText 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_text.text = "Health:" + str(health)
	score_text.text= "Score:" + str(score)
	update_ammo_text()
	raycast.add_exception(self)
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90),deg_to_rad(90))
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("aim"):
		camera.fov = lerp(camera.fov, AIM_FOV, 10 * delta)
	else:
		camera.fov = lerp(camera.fov,BASE_FOV,10 * delta)
	if Input.is_action_just_pressed("shoot") and current_ammo>0 and not is_reloading:
		current_ammo -= 1
		update_ammo_text()
		camera.rotation.x -= recoil_amount
		camera.rotation.x=clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
		if raycast.is_colliding():
			var hit_object = raycast.get_collider()
			
			print("---PULLED TRIGGER---")
			print("My laser just hit this exact thing :",hit_object.name)
			if hit_object.has_method("take_damage"):
				hit_object.take_damage()
			elif hit_object.get_parent() !=null and hit_object.get_parent().has_method("take_damage"):
				hit_object.get_parent().take_damage() 
	if (Input.is_action_just_pressed("reload")or (Input.is_action_just_pressed("shoot")and current_ammo <=0)) and current_ammo< max_ammo and not is_reloading:
		reload_weapon()
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		jump_count=0
	if Input.is_action_just_pressed("ui_accept") and jump_count<max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count+=1
		
	if Input.is_action_pressed("sprint"):
		current_speed=SPRINT_SPEED
	else:
		current_speed=WALK_SPEED
		
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x,0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
			

func take_damage(amount):
	health-=amount
	health_text.text="Health:"+str(health)
	
	if health<=0:
		get_tree().call_deferred("reload_current_scene")
func add_score(amount):
	score += amount
	score_text.text= "Score: " + str(score)
func update_ammo_text():
		ammo_text.text = "Ammo:" + str(current_ammo) + "/" + str(max_ammo)
func reload_weapon():
	is_reloading = true
	ammo_text.text = "Reloading..."
	
	await get_tree().create_timer(1.5).timeout
	
	current_ammo = max_ammo
	is_reloading=false
	update_ammo_text() 
func heal(amount):
	health += amount
	if health > 100:
		health = 100
	health_text.text = "Health: " + str(health)
	
