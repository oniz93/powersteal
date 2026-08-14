extends CharacterBody2D
## Slow Drone - Emits a slow aura

const MAX_HEALTH: int = 2
var current_health: int = MAX_HEALTH

@onready var sprite = $Sprite
@onready var aura_area = $AuraArea

var patrol_center: Vector2
var patrol_angle: float = 0.0
var patrol_radius: float = 40.0
var patrol_speed: float = 1.0

func _ready() -> void:
	patrol_center = global_position

func _physics_process(delta: float) -> void:
	if PowerManager.is_time_frozen:
		return
		
	# Simple circular patrol
	patrol_angle += patrol_speed * delta
	var target_pos = patrol_center + Vector2(cos(patrol_angle), sin(patrol_angle)) * patrol_radius
	velocity = (target_pos - global_position) * 5.0
	move_and_slide()
	
	# Apply slow to player if inside aura
	for body in aura_area.get_overlapping_bodies():
		if body.collision_layer & 1 and body.has_method("apply_slow"): # Player
			body.apply_slow(0.1) # Constantly refresh a tiny duration while inside

func take_damage(amount: int, _from_direction: Vector2 = Vector2.ZERO, _damage_type: String = "physical") -> void:
	current_health -= amount
	sprite.color = Color.WHITE
	var tw = create_tween()
	tw.tween_property(sprite, "color", Color("#E0E0E0"), 0.15)
	
	if current_health <= 0:
		_die()

func _die() -> void:
	queue_free()
