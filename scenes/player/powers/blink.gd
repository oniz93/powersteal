extends PowerBase
class_name PowerBlink

const BLINK_COST: float = 25.0
const BLINK_DISTANCE: float = 120.0

func _init() -> void:
	power_name = &"Blink"
	power_color = Color("#39FF14") # Neon green
	energy_cost = BLINK_COST

func _do_effect() -> void:
	if not is_instance_valid(player_ref):
		return
		
	# Calculate target position
	var start_pos = player_ref.global_position
	var target_pos = start_pos + (player_ref.aim_direction * BLINK_DISTANCE)
	
	# Raycast to ensure we don't land INSIDE a solid wall (layer 4)
	# But we DO want to allow passing THROUGH thin walls
	var space_state = player_ref.get_world_2d().direct_space_state
	
	# First, check if the final destination is inside a wall
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target_pos
	query.collision_mask = 4 # Only check walls
	
	var is_inside_wall = space_state.intersect_point(query).size() > 0
	
	if is_inside_wall:
		# We would land inside a wall. Let's trace backwards from the target
		# to find the edge of the wall closest to the player
		var ray = PhysicsRayQueryParameters2D.create(target_pos, start_pos, 4)
		var result = space_state.intersect_ray(ray)
		
		if result:
			# Snap to just outside the wall on the side we came from
			target_pos = result.position + (player_ref.aim_direction * -10.0)
		else:
			# Fallback if something weird happens
			target_pos = start_pos
			
	# Apply the teleport
	player_ref.global_position = target_pos
	
	# Brief invulnerability so you don't instantly take damage upon appearing
	player_ref.invincibility_timer = max(player_ref.invincibility_timer, 0.2)
	
	# Visual effects
	_play_blink_vfx(start_pos, target_pos)

func _play_blink_vfx(start: Vector2, end: Vector2) -> void:
	# Ghost afterimage at start
	var ghost = ColorRect.new()
	ghost.color = Color("#39FF14")
	ghost.color.a = 0.5
	ghost.size = Vector2(12, 12)
	ghost.position = start - Vector2(6, 6)
	get_tree().root.add_child(ghost)
	
	var tw = create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tw.tween_callback(ghost.queue_free)
	
	# Player flash at end
	player_ref.sprite.color = Color.WHITE
	player_ref._swing_flash_timer = 0.1 # Reuse the melee flash timer for convenience
	
	player_ref._apply_screen_shake(1.5)
