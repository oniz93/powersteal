extends Area2D
## Poison patch left by Hunter boss. Deals damage over time to player.

const LIFETIME: float = 4.0
const POISON_DAMAGE: int = 1
const TICK_RATE: float = 0.5  # Apply damage every 0.5 seconds

var lifetime_timer: float = 0.0
var tick_timer: float = 0.5 # Start ready to tick

func _physics_process(delta: float) -> void:
	if PowerManager.is_time_frozen:
		return
		
	lifetime_timer += delta
	if lifetime_timer >= LIFETIME:
		queue_free()
		return
		
	tick_timer += delta
	if tick_timer >= TICK_RATE:
		tick_timer -= TICK_RATE
		_apply_poison_damage()
		
func _apply_poison_damage() -> void:
	for body in get_overlapping_bodies():
		if body.collision_layer & 1:
			if body.has_method("take_damage"):
				# Direction is Vector2.ZERO because it's an environmental dot
				body.take_damage(POISON_DAMAGE, Vector2.ZERO, "poison")
