extends PowerBase
class_name PowerFireball

const FIREBALL_SCENE: PackedScene = preload("res://scenes/player/powers/fireball_projectile.tscn")

func _init() -> void:
	power_name = &"Fireballs"
	power_color = Color("#FF6B1A")
	energy_cost = 20.0

func _do_effect() -> void:
	if not is_instance_valid(player_ref):
		return
		
	var projectile = FIREBALL_SCENE.instantiate()
	
	# Add to the current room/level, not as a child of the player 
	# so it doesn't move with the player
	player_ref.get_parent().add_child(projectile)
	
	projectile.global_position = player_ref.global_position + (player_ref.aim_direction * 15.0)
	projectile.setup(player_ref.aim_direction)
	
	# Apply some screen shake for punchiness
	player_ref._apply_screen_shake(2.0)
