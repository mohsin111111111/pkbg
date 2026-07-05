extends CharacterBody3D
const WALK_SPEED = 5.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 4.5

var current_speed=WALK_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002
var health=100
var score = 0

var jump_count=0
var max_jumps=2

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var health_text = $HUD/HealthText
@onready var score_text = $HUD/ScoreText

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_text.text = "Health:" + str(health)
	score_text.text = "Score:" + str(score) 
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90),deg_to_rad(90))
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("shoot"):
		if raycast.is_colliding():
			var hit_object = raycast.get_collider()
			if hit_object.has_method("take_damage"):
				hit_object.take_damage()
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
	health_text.text="Health"+str(health)
	
	if health<=0:
		get_tree().call_deferred("reload_current_scene")
func add_score(amount):
	score += amount
	score_text.text = "Score: " + str(score) 
