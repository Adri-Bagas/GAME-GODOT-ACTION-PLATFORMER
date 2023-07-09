extends CharacterBody2D


var SPEED : float = 50.0
var WALK_SPEED : float = 100.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_attacking : bool = false
var is_walking_left : bool = false
var is_walking : bool = false
var is_looking_to_left : bool = false
var is_dead : bool = false
var has_died : bool = false

var knockbackPower = 500
var knockbackDuration = 0.5
var knockbackTimer = 0.0
var knockbackDirection = Vector2.ZERO


func _physics_process(delta):
	if not is_dead && not has_died:
		if knockbackTimer > 0.0:
			knockbackTimer -= delta
			var knockbackVelocity = knockbackDirection * knockbackPower
			move_and_collide(knockbackVelocity * delta)
		else:
			if not is_on_floor():
				velocity.y += gravity * delta
			
			animation_update()
			update_dir()
			attack()
			move_and_slide()
	else:
		if is_dead && not has_died:
			$AnimatedSprite2D.play("die")

func update_dir():
	if velocity.x < 0 || is_looking_to_left:
		$AnimatedSprite2D.flip_h = true
		$DetectArea.scale.x = -1
	else:
		$AnimatedSprite2D.flip_h = false
		$DetectArea.scale.x = 1

func animation_update():
	if velocity.x != 0:
		$AnimatedSprite2D.play("attacking")
	else:
		$AnimatedSprite2D.play("idle")

func attack():
	if is_attacking:
		if is_looking_to_left:
			SPEED += 0.3
			velocity.x = -SPEED
			SPEED += 0.3
		else:
			SPEED += 0.3
			velocity.x = SPEED
			SPEED += 0.3

func _on_detect_area_body_entered(body):
	if body.is_in_group('Player'):
		is_attacking = true

func _on_timer_timeout():
	if not is_dead:
		if not is_attacking:
			if not is_walking:
				if not is_walking_left:
					is_looking_to_left = false
					velocity.x = WALK_SPEED
					is_walking = true
					is_walking_left = true
					$Timer.wait_time = 4.0
				else: 
					is_looking_to_left = true
					velocity.x = -WALK_SPEED
					is_walking = true
					is_walking_left = false
					$Timer.wait_time = 4.0
			else:
				velocity.x = 0
				is_walking = false
				$Timer.wait_time = 1.0

func applyKnockback(direction: Vector2):
	knockbackDirection = direction.normalized()
	knockbackTimer = knockbackDuration


func _on_detect_area_body_exited(body):
	if body.is_in_group('Player'):
		is_attacking = false
		SPEED = 50.0
		
func dead():
	is_dead = true


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "die":
		queue_free()
