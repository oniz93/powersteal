extends CharacterBody2D

const MAX_HEALTH: int = 2
const DAMAGE: int = 1
const BLINK_DISTANCE: float = 60.0
const AGGRO_RANGE: float = 250.0

var current_health: int = MAX_HEALTH
var player_ref: Node2D = null

enum State { IDLE, PRE_BLINK, BLINKING, RECOVERY, DEAD }
var current_state: State = State.IDLE
var state_timer: float = 0.0

@onready var sprite: ColorRect = $Sprite
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

# For knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	attack_shape.disabled = true
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
		
	if PowerManager.is_time_frozen:
		return
		
	if knockback_velocity.length() > 10.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800.0 * delta)
		velocity = knockback_velocity
		move_and_slide()
		return
	else:
		knockback_velocity = Vector2.ZERO

	match current_state:
		State.IDLE:
			_state_idle()
		State.PRE_BLINK:
			_state_pre_blink(delta)
		State.RECOVERY:
			_state_recovery(delta)

	move_and_slide()

func _state_idle() -> void:
	velocity = Vector2.ZERO
	if is_instance_valid(player_ref) and global_position.distance_to(player_ref.global_position) <= AGGRO_RANGE:
		current_state = State.PRE_BLINK
		state_timer = 0.8 + randf_range(0.0, 0.4) # Randomize so they don't sync up perfectly

func _state_pre_blink(delta: float) -> void:
	state_timer -= delta
	
	# Flash before blinking
	if state_timer < 0.2:
		sprite.color = Color.WHITE
		
	if state_timer <= 0.0:
		_do_blink_attack()

func _do_blink_attack() -> void:
	if not is_instance_valid(player_ref):
		current_state = State.IDLE
		return
		
	# Calculate destination towards player
	var start_pos = global_position
	var dir_to_player = global_position.direction_to(player_ref.global_position)
	var dist_to_player = global_position.distance_to(player_ref.global_position)
	
	# Don't blink past them if they are close
	var actual_dist = min(BLINK_DISTANCE, dist_to_player - 15.0)
	var target_pos = global_position + (dir_to_player * actual_dist)
	
	# Visuals: Ghost at start
	_spawn_ghost(start_pos)
	
	# Teleport
	global_position = target_pos
	
	# Attack immediately
	attack_area.rotation = dir_to_player.angle()
	attack_shape.disabled = false
	sprite.color = Color("#39FF14") # Neon green
	
	for body in attack_area.get_overlapping_bodies():
		if body.collision_layer & 1 and body.has_method("take_damage"):
			body.take_damage(DAMAGE, dir_to_player, "physical")
			
	# Transition to recovery
	current_state = State.RECOVERY
	state_timer = 0.5
	
func _state_recovery(delta: float) -> void:
	# Disable attack after a brief moment
	if state_timer < 0.4:
		attack_shape.disabled = true
		sprite.color = Color(0.2, 0.6, 0.2) # Dim green while recovering
		
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.IDLE

func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO, _damage_type: String = "physical") -> void:
	if current_state == State.DEAD: return
		
	current_health -= amount
	knockback_velocity = from_direction * 150.0
	
	sprite.color = Color.WHITE
	var tween = create_tween()
	tween.tween_property(sprite, "color", Color(0.2, 0.6, 0.2), 0.15)
	
	if current_health <= 0:
		_die()

func _die() -> void:
	current_state = State.DEAD
	attack_shape.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _spawn_ghost(pos: Vector2) -> void:
	var ghost = ColorRect.new()
	ghost.color = Color("#39FF14")
	ghost.color.a = 0.5
	ghost.size = Vector2(12, 12)
	ghost.position = pos - Vector2(6, 6)
	get_tree().root.add_child(ghost)
	var tw = create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tw.tween_callback(ghost.queue_free)
