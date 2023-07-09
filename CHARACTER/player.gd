extends CharacterBody2D

# inventory and stats
@export var WALK_SPEED : float = 150.0
@export var RUN_SPEED : float = 300.0
@export var JUMP_VELOCITY : float = -250.0
@export var health : float = 5
@export var max_health : float = 5 
var coins : float = 0
var points : float = 0

#state
var is_running : bool = false
var is_jumping : bool = false
var animation_lock : bool = false
var movement_lock : bool = false
var is_looking_to_left : bool = false
var direction : Vector2 = Vector2.ZERO #(0, 0)
var is_dead : bool = false
var has_died : bool = false

#prerequisite
@onready var animatedSprite2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var attackArea1 : Area2D = $AttackArea1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_dead && not has_died:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			is_jumping = false
		if not movement_lock:
			if Input.is_action_just_pressed("ui_accept"): #"ui_accept == spacebar"
				if not is_jumping:
					velocity.y = JUMP_VELOCITY
					is_jumping = true
			
			direction = Input.get_vector("TRADLEFT", "TRADRIGHT", "TRADUP", "TRADDOWN") 
			if direction:
				if Input.is_action_just_pressed("SPRINT"):
					velocity.x = direction.x * RUN_SPEED
				elif not is_running:
					velocity.x = direction.x * WALK_SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
				is_running = false
				
		animation_update()
		update_dir()
		jump()
		attack()
		move_and_slide()
	else:
		if is_dead && not has_died:
			animatedSprite2d.play("death")
	
func animation_update():
	if not animation_lock:
		if direction.x != 0:
			if Input.is_action_just_pressed("SPRINT"):
				animatedSprite2d.play("run")
				is_running = true
			else:
				if not is_running:
					animatedSprite2d.play("walk")
				else:
					animatedSprite2d.play("run")
		else:
			if not animation_lock:
				animatedSprite2d.play("idle")
	
func update_dir():
	if direction.x < 0:
		animatedSprite2d.flip_h = true
		attackArea1.scale.x = -1
		is_looking_to_left = true
	elif direction.x > 0:
		animatedSprite2d.flip_h = false
		attackArea1.scale.x = 1
		is_looking_to_left = false
	else:
		if is_looking_to_left:
			animatedSprite2d.flip_h = true
			attackArea1.scale.x = -1
		else:
			animatedSprite2d.flip_h = false
			attackArea1.scale.x = 1

func jump():
	if is_jumping:
		if velocity.y < 0:
			animatedSprite2d.play("jump_up")
			animation_lock = true
		if velocity.y == 0:
			animatedSprite2d.play("jump_stay")
			animation_lock = true
		if velocity.y > 0:
			animatedSprite2d.play("jump_down")
			animation_lock = true

func _on_animated_sprite_2d_animation_finished():
	if animatedSprite2d.animation == "jump_stay":
		animation_lock = false
	if animatedSprite2d.animation == "jump_up":
		animation_lock = false
	if animatedSprite2d.animation == "jump_down":
		animation_lock = false
	if animatedSprite2d.animation == "attack1":
		animation_lock = false
		$AttackArea1/CollisionShape2D.disabled = true
		movement_lock = false
	if animatedSprite2d.animation == "take_damage":
		animation_lock = false
		movement_lock = false
	if animatedSprite2d.animation == "death":
		has_died = true
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://SCENE/game_over_screen.tscn")

func attack():
	if Input.is_action_just_pressed("ATTACK"):
		if not animation_lock:
			velocity.x = 0
			movement_lock = true
			animatedSprite2d.play('attack1')
			$AttackArea1/CollisionShape2D.disabled = false
			animation_lock = true

func _on_hurt_box_area_entered(area):
	if area.is_in_group("ENEMY"):
		movement_lock = true
		if not animation_lock:
			animatedSprite2d.play("take_damage")
		animation_lock = true
		area.get_parent().is_attacking = false
		var knockbackDirection = (area.global_position - global_position).normalized()
		area.get_parent().applyKnockback(knockbackDirection)
		area.get_parent().SPEED = 50.0
		health -= 1
		is_dead_check()

func is_dead_check():
	if health <= 0:
		animation_lock = true
		is_dead = true

func _on_attack_area_1_body_entered(body):
	if body.is_in_group("ENEMY"):
		body.dead()
