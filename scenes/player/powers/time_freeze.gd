extends PowerBase
class_name PowerTimeFreeze

const FREEZE_COST: float = 40.0
const FREEZE_DURATION: float = 2.5

func _init() -> void:
	power_name = &"Time Freeze"
	power_color = Color("#E0E0E0") # White/Silver
	energy_cost = FREEZE_COST

func _do_effect() -> void:
	if not is_instance_valid(player_ref):
		return
		
	PowerManager.trigger_time_freeze(FREEZE_DURATION)
	player_ref._apply_screen_shake(3.0)
	
	# Temporary buff to player damage during time freeze handled in player or via global check,
	# but for simplicity we'll just let the freeze be the main benefit.
	
	# Small visual burst from player
	var burst = ColorRect.new()
	burst.color = Color.WHITE
	burst.size = Vector2(48, 48)
	burst.position = player_ref.global_position - Vector2(24, 24)
	get_tree().root.add_child(burst)
	var tw = create_tween()
	tw.tween_property(burst, "scale", Vector2(2, 2), 0.2)
	tw.parallel().tween_property(burst, "modulate:a", 0.0, 0.2)
	tw.tween_callback(burst.queue_free)
