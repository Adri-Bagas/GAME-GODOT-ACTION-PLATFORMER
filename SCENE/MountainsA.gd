extends Sprite2D

@onready var camera : Camera2D = get_parent().get_node("Player/PlayerCamera")

func _physics_process(delta):
	if camera:
		position = camera.global_position
