extends Node
## InputManager — Handles input abstraction for controller/keyboard.

# Tracks whether the player is using controller or keyboard
var using_controller: bool = false

# Aim direction (always normalized)
var aim_direction: Vector2 = Vector2.RIGHT

# Cache the player node reference
var player_node: Node2D = null


func _input(event: InputEvent) -> void:
	# Detect input device switching
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_controller = true
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		using_controller = false


func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func get_aim_direction() -> Vector2:
	if using_controller:
		# Right stick aiming
		var stick := Vector2(
			Input.get_axis("aim_right_left", "aim_right_right"),
			Input.get_axis("aim_right_up", "aim_right_down")
		)
		if stick.length() > 0.2:  # Dead zone
			aim_direction = stick.normalized()
	else:
		# Mouse aiming - requires player position
		if player_node and is_instance_valid(player_node):
			var mouse_pos := player_node.get_global_mouse_position()
			var dir := (mouse_pos - player_node.global_position).normalized()
			if dir.length() > 0.0:
				aim_direction = dir

	return aim_direction


func register_player(node: Node2D) -> void:
	player_node = node
