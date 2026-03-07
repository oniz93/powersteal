extends CharacterBody2D
## Gadget Sentry - Shoots at player and emits an EMP zone

const MAX_HEALTH: int = 3
const SHOOT_COOLDOWN: float = 2.0
const PROJECTILE_SCENE = preload("res://scenes/player/powers/fireball_projectile.tscn")

var current_health: int = MAX_HEALTH
var shoot_timer: float = 0.0
var player_ref: Node2D = null

@onready var sprite = $Sprite
@onready var emp_area = $EmpArea

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _physics_process(delta: float) -> void:
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	# Apply EMP to player if inside area
	for body in emp_area.get_overlapping_bodies():
		if body.collision_layer & 1 and body.has_method("apply_emp"):
			body.apply_emp(0.1) # Constantly refresh a tiny duration
			
	# Shoot at player
	shoot_timer -= delta
	if shoot_timer <= 0.0 and is_instance_valid(player_ref):
		if global_position.distance_to(player_ref.global_position) < 300.0:
			_shoot()
			shoot_timer = SHOOT_COOLDOWN

func _shoot() -> void:
	if not is_instance_valid(player_ref): return
	
	var dir = global_position.direction_to(player_ref.global_position)
	var proj = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + (dir * 15.0)
	proj.setup(dir, true)
	
	# Adjust projectile visually to look like a bullet
	var p_sprite = proj.get_node("Sprite")
	p_sprite.color = Color("#FFFF00") # Yellow bullet
	p_sprite.scale = Vector2(0.5, 0.5)

func take_damage(amount: int, _from_direction: Vector2 = Vector2.ZERO, _damage_type: String = "physical") -> void:
	current_health -= amount
	sprite.color = Color.WHITE
	var tw = create_tween()
	tw.tween_property(sprite, "color", Color("#505050"), 0.15)
	
	if current_health <= 0:
		queue_free()
