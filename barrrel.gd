extends StaticBody3D
@onready var explosion_zone = $ExplosionZone
func take_damage(_amount):
	var targets= explosion_zone.get_overlapping_bodies()
	for target in targets:
		if target.is_in_group("Player"):
			target.take_damage(50)
		elif target.has_method("take_damage") and target != self:
			target.take_damage()
			target.take_damage()
			target.take_damage()
		queue_free()
