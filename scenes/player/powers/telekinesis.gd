extends PowerBase
class_name PowerTelekinesis

const GRAB_COST: float = 15.0
const THROW_COST: float = 5.0
const GRAB_RANGE: float = 150.0
const GRAB_RADIUS: float = 20.0

var grabbed_object: Node2D = null

func _init() -> void:
	power_name = &"Telekinesis"
	power_color = Color("#9B30FF") # Purple
	energy_cost = GRAB_COST # Initial cost just to grab

func _do_effect() -> void:
	if not is_instance_valid(player_ref):
		return
		
	if is_instance_valid(grabbed_object):
		return # Already holding something
		
	# Find nearest grabbable object in aim direction
	var best_target: Node2D = null
	var best_score: float = -1.0 # Higher is better
	
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	
	for g in grabbables:
		if not is_instance_valid(g) or g == player_ref:
			continue
			
		var dist = player_ref.global_position.distance_to(g.global_position)
		if dist > GRAB_RANGE:
			continue
			
		var dir_to_obj = player_ref.global_position.direction_to(g.global_position)
		var dot = player_ref.aim_direction.dot(dir_to_obj)
		
		# Must be somewhat in front of the player (roughly 90 degree cone)
		if dot > 0.5:
			# Score based on how directly we are aiming at it and how close it is
			var score = dot * (1.0 - (dist / GRAB_RANGE))
			if score > best_score:
				best_score = score
				best_target = g

	if best_target and best_target.has_method("grab"):
		grabbed_object = best_target
		grabbed_object.grab(player_ref)
		
		# Brief screen shake
		player_ref._apply_screen_shake(1.5)
	else:
		# Failed to grab anything, refund energy
		PowerManager.current_energy += GRAB_COST
		PowerManager.energy_changed.emit(PowerManager.current_energy, PowerManager.MAX_ENERGY)

func deactivate() -> void:
	if not is_instance_valid(grabbed_object):
		return
		
	if not is_instance_valid(player_ref):
		return

	# Try to pay the throw cost
	if PowerManager.consume_energy(THROW_COST):
		if grabbed_object.has_method("throw"):
			grabbed_object.throw(player_ref.aim_direction)
			player_ref._apply_screen_shake(3.0)
	else:
		# Not enough energy to throw, just drop it
		if grabbed_object.has_method("drop"):
			grabbed_object.drop()
			
	grabbed_object = null
