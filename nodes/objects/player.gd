extends KinematicBody2D
class_name Player

export var speed := 15
export var carrying_nothing_texture : Texture
export var carrying_bucket_texture : Texture
export var carrying_gun_texture : Texture

var velocity := Vector2.ZERO
var carrying : int = CARRYING.NOTHING

onready var _sprite := $Sprite

enum CARRYING {
	NOTHING,
	BUCKET,
	GUN,
}

func _physics_process(delta: float) -> void:
	velocity.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * speed * delta
	move_and_collide(velocity)

func _process(_delta: float) -> void:
	match carrying:
		CARRYING.NOTHING:
			_sprite.texture = carrying_nothing_texture
		CARRYING.BUCKET:
			_sprite.texture = carrying_bucket_texture
		CARRYING.GUN:
			_sprite.texture = carrying_gun_texture
