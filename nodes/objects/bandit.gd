extends Node2D
class_name Bandit

signal has_shot

onready var _bang_sprite := $BangSprite
onready var _animator := $Animator

export var health := 4

var running_away := false

func _ready() -> void:
	_bang_sprite.visible = false
	_animator.play("MoveUp")

func shoot() -> void:
	_bang_sprite.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	_bang_sprite.visible = false
	emit_signal("has_shot")

func retreat() -> void:
	running_away = true
	_animator.play_backwards("MoveUp")

func _on_Animator_animation_finished(anim_name: String) -> void:
	if anim_name == "MoveUp":
		if running_away:
			queue_free()
		else:
			_animator.play("Bob")
