extends Area2D
## The projectile fired by the Fireball power (and the Hothead boss)

const SPEED: float = 300.0
const DAMAGE: int = 1
const LIFETIME: float = 2.0

const FIRE_PATCH_SCENE: PackedScene = preload("res://scenes/player/powers/fire_patch.tscn")

var direction: Vector2 = Vector2.RIGHT
var lifetime_timer: float = 0.0
var is_enemy_projectile: bool = false

func setup(dir: Vector2, is_enemy: bool = false) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
	is_enemy_projectile = is_enemy
	
	if is_enemy:
		# Update collision masks so enemy fireballs hit the player (layer 1)
		collision_mask = 1 | 4 # Player | Walls
		$Sprite.color = Color("#ff4400") # Slightly different hue for enemy fireballs
	else:
		# Player fireballs hit enemies (layer 2) and walls (layer 4)
		collision_mask = 2 | 4

func _physics_process(delta: float) -> void:
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return # Time freeze mechanic placeholder
		
	position += direction * SPEED * delta
	
	lifetime_timer += delta
	if lifetime_timer >= LIFETIME:
		_destroy()

func _on_body_entered(body: Node2D) -> void:
	if is_enemy_projectile:
		if body.is_in_group("enemies"):
			return # Enemies don't hurt themselves with fireballs
	else:
		if body.collision_layer & 1: 
			return # Player doesn't hurt themselves
		
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE, direction, "fire")
	
	_destroy()

func _destroy() -> void:
	# Spawn fire patch
	var patch = FIRE_PATCH_SCENE.instantiate()
	get_parent().call_deferred("add_child", patch)
	patch.global_position = global_position
	
	queue_free()
