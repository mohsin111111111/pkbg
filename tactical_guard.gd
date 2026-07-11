extends CharacterBody3D

var health = 3
var gun_damage = 5
var tracer_scene = preload("res://tracer.tscn")
var player = null 
var is_hiding = false 
var original_y_position = 0.0

@onready var gun_ray = $GunRay
@onready var cover_timer = Timer.new()

func _ready():
	original_y_position = global_position.y 
	if gun_ray != null:
		gun_ray.add_exception(self)
		
	add_child(cover_timer)
	cover_timer.timeout.connect(_on_cover_timer_timeout)
	cover_timer.start(2.5)
	
func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player != null and is_hiding == false:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		fire_at_player()
		
func _on_cover_timer_timeout():
	is_hiding = !is_hiding
	if is_hiding:
		var duck_tween = create_tween()
		duck_tween.tween_property(self, "global_position:y", original_y_position - 1.2, 0.3)
	else:
		var stand_tween = create_tween()
		stand_tween.tween_property(self, "global_position:y", original_y_position, 0.3)

func fire_at_player():
	if player != null:
		gun_ray.target_position = gun_ray.to_local(player.global_position + Vector3(0,1,0))
	if gun_ray.is_colliding():
		var hit_object = gun_ray.get_collider()
		if hit_object.is_in_group("Player"):
			var tracer = tracer_scene.instantiate()
			get_tree().root.add_child(tracer)
			tracer.global_transform = gun_ray.global_transform
			
			if hit_object.has_method("take_damage"):
				hit_object.take_damage(gun_damage)
				
			gun_ray.enabled = false
			await get_tree().create_timer(1.0).timeout
			gun_ray.enabled = true

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
