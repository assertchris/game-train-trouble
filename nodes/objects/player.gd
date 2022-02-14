extends KinematicBody2D
class_name Player

signal has_shot
signal has_reloaded

export var speed := 15
export var carrying_nothing_texture : Texture
export var carrying_bucket_texture : Texture
export var carrying_gun_texture : Texture

var velocity := Vector2.ZERO
var ammo_count := 6
var has_water := false
var carrying : int = CARRYING.NOTHING

onready var _sprite := $Sprite
onready var _bang_sprite := $BangSprite

enum CARRYING {
	NOTHING,
	BUCKET,
	GUN,
}

func _ready() -> void:
	_bang_sprite.visible = false

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

func shoot() -> void:
	_bang_sprite.visible = true
	ammo_count -= 1
	yield(get_tree().create_timer(0.5), "timeout")
	_bang_sprite.visible = false
	emit_signal("has_shot")

func reload() -> void:
	ammo_count = 6
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("has_reloaded")
