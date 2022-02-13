extends "res://nodes/screens/screen.gd"

export var CactusScene : PackedScene
export var RockScene : PackedScene
export var DirtScene : PackedScene
export var BulletScene : PackedScene
export var BucketScene : PackedScene
export var FlameScene : PackedScene

var is_playing := true
var velocity := 0
var acceleration := 3
var max_speed := 150
var start_wait_time := 1.5
var mix_wait_time := 0.03
var decrease_wait_time_by := 0.01
var wheel_bar_state : int = WHEEL_BAR_STATES.ONE
var remaining_doodad_timeout_ticks := 0
var additional_doodad_timeout_ticks := 40
var is_overlapping_engine := false
var is_overlapping_water := false
var is_overlapping_ammo := false
var is_shooting := false
var is_reloading := false

enum WHEEL_BAR_STATES {
	ONE,
	TWO,
	THREE,
	FOUR,
}

onready var _player := $Player
onready var _wheel_bar_timer := $WheelBarTimer
onready var _wheel_bar := $WheelBar
onready var _doodad_positions := $DoodadPositions
onready var _doodads := $Doodads
onready var _ammo := $Ammo

func _ready() -> void:
	randomize()
	_wheel_bar_timer.wait_time = start_wait_time
	Variables.current_player = _player

func _process(delta: float) -> void:
	for child in get_children():
		if child is Node2D:
			child.global_position.x = round(child.global_position.x)

func _on_WheelBarTimer_timeout() -> void:
	_wheel_bar_timer.wait_time = clamp(start_wait_time - (velocity * decrease_wait_time_by), mix_wait_time, start_wait_time)
	velocity = clamp(velocity + acceleration, 0, max_speed)

	animate_wheel_bar()

	remaining_doodad_timeout_ticks = clamp(remaining_doodad_timeout_ticks - 1, 0, additional_doodad_timeout_ticks)

	for child in _doodads.get_children():
		if child is Node2D:
			if child.is_in_group("doodad"):
				child.global_position.x -= 1

func animate_wheel_bar() -> void:
	match wheel_bar_state:
		WHEEL_BAR_STATES.ONE:
			_wheel_bar.global_position.x += 1
			_wheel_bar.global_position.y -= 1
			wheel_bar_state = WHEEL_BAR_STATES.TWO
		WHEEL_BAR_STATES.TWO:
			_wheel_bar.global_position.x += 1
			_wheel_bar.global_position.y += 1
			wheel_bar_state = WHEEL_BAR_STATES.THREE
		WHEEL_BAR_STATES.THREE:
			_wheel_bar.global_position.x -= 1
			_wheel_bar.global_position.y += 1
			wheel_bar_state = WHEEL_BAR_STATES.FOUR
		WHEEL_BAR_STATES.FOUR:
			_wheel_bar.global_position.x -= 1
			_wheel_bar.global_position.y -= 1
			wheel_bar_state = WHEEL_BAR_STATES.ONE

func _on_DoodadSpawnTimer_timeout() -> void:
	spawn_doodad()

func spawn_doodad() -> void:
	if rand_range(0.0, 1.0) > 0.9 and remaining_doodad_timeout_ticks == 0:
		var doodad = null

		if rand_range(0.0, 1.0) <= 0.3:
			doodad = CactusScene.instance()
		elif rand_range(0.0, 1.0) <= 0.6:
			doodad = RockScene.instance()
		else:
			doodad = DirtScene.instance()

		_doodads.add_child(doodad)

		var i = randi() % _doodad_positions.get_child_count()
		doodad.global_position = _doodad_positions.get_children()[i].global_position

		remaining_doodad_timeout_ticks += additional_doodad_timeout_ticks

func _on_EngineArea_body_entered(body: Node) -> void:
	if body is Player:
		is_overlapping_engine = true

func _on_EngineArea_body_exited(body: Node) -> void:
	if body is Player:
		is_overlapping_engine = false

func _on_WaterArea_body_entered(body: Node) -> void:
	if body is Player:
		is_overlapping_water = true

func _on_WaterArea_body_exited(body: Node) -> void:
	if body is Player:
		is_overlapping_water = false

func _on_AmmoArea_body_entered(body: Node) -> void:
	if body is Player:
		is_overlapping_ammo = true

func _on_AmmoArea_body_exited(body: Node) -> void:
	if body is Player:
		is_overlapping_ammo = false

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action("ui_accept"):
		if is_overlapping_engine and Variables.current_player.carrying == Player.CARRYING.NOTHING:
			pass # add coal

		if is_overlapping_water and Variables.current_player.carrying == Player.CARRYING.BUCKET and not Variables.current_player.has_water:
			print("get water")
			Variables.current_player.has_water = true

		if is_overlapping_engine and Variables.current_player.carrying == Player.CARRYING.BUCKET and Variables.current_player.has_water:
			print("lose water")
			Variables.current_player.has_water = false
			pass # add water

		if is_overlapping_ammo and Variables.current_player.carrying == Player.CARRYING.GUN:
			is_reloading = true
			Variables.current_player.reload()
			yield(Variables.current_player, "has_reloaded")
			is_reloading = false

	if event.is_action("ui_select"):
		if Player.CARRYING.GUN and Variables.current_player.ammo_count > 0 and not is_shooting:
			is_shooting = true
			Variables.current_player.bang()
			yield(Variables.current_player, "has_banged")
			is_shooting = false

func _on_InterfaceTimer_timeout() -> void:
	while _ammo.get_child_count() > 0:
		_ammo.remove_child(_ammo.get_child(0))

	while _ammo.get_child_count() < Variables.current_player.ammo_count:
		var new_ammo = BulletScene.instance()
		_ammo.add_child(new_ammo)
