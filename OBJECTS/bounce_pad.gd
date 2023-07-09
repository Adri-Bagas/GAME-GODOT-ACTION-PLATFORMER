extends RigidBody2D

@export var jump_velocity : float = 200.0

func _on_jump_area_body_entered(body):
	if body.is_in_group('Player'):
		$AnimatedSprite2D.play('bounce')
		body.velocity.y -= jump_velocity
		body.is_jumping = true
