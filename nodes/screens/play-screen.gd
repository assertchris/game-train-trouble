extends "res://nodes/screens/screen.gd"

export var CactusScene : PackedScene
export var RockScene : PackedScene
export var DirtScene : PackedScene

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

enum WHEEL_BAR_STATES {
	ONE,
	TWO,
	THREE,
	FOUR,
}

onready var _wheel_bar_timer := $WheelBarTimer
onready var _wheel_bar := $WheelBar
onready var _doodad_positions := $DoodadPositions
onready var _doodads := $Doodads

func _ready() -> void:
	randomize()
	_wheel_bar_timer.wait_time = start_wait_time

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
