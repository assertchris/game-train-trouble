extends "res://nodes/screens/screen.gd"

func _process(delta: float) -> void:
	for child in get_children():
		child.global_position.x = round(child.global_position.x)
