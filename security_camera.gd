extends  StaticBody3D
@onready var status_light = $StatusLight
@onready var blink_timer = $BlinkTimer
func _ready():
	status_light.light_color = Color.WHITE
func take_damage():
	print("Camera destroyed! The area is secure.")
	queue_free()
func _on_vision_zone_body_entered(body):
	if body.is_in_group("Player"):
		print(" ALARM TRIGGERED! PLAYER DETECTED!")
		get_tree().call_group("Enemy", "sound_alarm")
		status_light.light_color = Color.RED
		blink_timer.wait_time = 0.15
func _on_blink_timer_timeout() -> void:
	status_light.visible = not status_light.visible
	pass # Replace with function body.
