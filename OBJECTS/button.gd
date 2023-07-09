extends Area2D

var has_turned_on : bool = false

@export var target : String


func _on_body_entered(body):
	if body.is_in_group('Player'):
		if not has_turned_on:
			$AnimatedSprite2D.play('default')
			get_parent().get_node(target).queue_free()
			has_turned_on = true
