extends RigidBody2D

func _on_death_area_body_entered(body):
	if body.is_in_group("Player"):
		body.is_dead = true
