extends Node2D

var is_overlapped_by : Player = null

func _on_Hitbox_body_entered(body: Node) -> void:
	if body is Player:
		is_overlapped_by = body

func _on_Hitbox_body_exited(body: Node) -> void:
	if body is Player:
		is_overlapped_by = null

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("ui_accept") and is_overlapped_by:
		if is_overlapped_by.carrying == Player.CARRYING.BUCKET:
			var new_bucket = load("res://nodes/objects/bucket.tscn").instance()
			is_overlapped_by.get_parent().find_node("Interactables").add_child(new_bucket)
			new_bucket.global_position = is_overlapped_by.global_position

		is_overlapped_by.carrying = Player.CARRYING.GUN
		queue_free()
