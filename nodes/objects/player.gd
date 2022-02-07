extends KinematicBody2D

export var speed := 15

var velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * speed * delta

	var collisions = move_and_collide(velocity)
