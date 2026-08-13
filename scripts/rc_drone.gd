extends CharacterBody3D
const SPEED = 6.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_active = false 
@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_active:
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("interact"):
			zap_panel()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
func _input(event):
	if is_active and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.002)
		camera.rotate_x(-event.relative.y * 0.002)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(45))
func zap_panel():
	print("BZZT! Drone deployed taser!")
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.has_method("hack_door"):
			target.hack_door()
			print("Drone successfully hacked the system!")
