extends Area2D
## Fire patch left by fireball impacts. Deals damage over time to enemies.

const LIFETIME: float = 2.5
const BURN_DAMAGE: int = 1
const TICK_RATE: float = 0.5  # Apply damage every 0.5 seconds

var lifetime_timer: float = 0.0
var tick_timer: float = 0.0

func _ready() -> void:
	# Add some slight randomization to rotation for visual variety
	rotation = randf() * PI * 2.0

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
		_apply_burn_damage()
		
func _apply_burn_damage() -> void:
	for body in get_overlapping_bodies():
		# Don't hurt the player (collision mask already prevents this, but double check)
		if body.collision_layer & 1:
			continue
			
		if body.has_method("take_damage"):
			# Direction is roughly upward for fire patches
			body.take_damage(BURN_DAMAGE, Vector2.UP, "fire")
