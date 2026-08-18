extends CharacterBody2D
## Basic melee enemy — Fire Grunt

const MOVE_SPEED: float = 60.0
const MAX_HEALTH: int = 3
const DAMAGE: int = 1
const DETECTION_RANGE: float = 200.0
const ATTACK_RANGE: float = 30.0
const ATTACK_WINDUP: float = 0.4
const ATTACK_COOLDOWN: float = 1.0

var current_health: int = MAX_HEALTH
var player_ref: Node2D = null

# State machine
enum State {
	IDLE,
	CHASE,
	WINDUP,
	COOLDOWN,
	DEAD
}
var current_state: State = State.IDLE
var state_timer: float = 0.0

@onready var sprite: ColorRect = $Sprite
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

# For knockback
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_FRICTION: float = 800.0

func _ready() -> void:
	attack_shape.disabled = true
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
		
	if PowerManager.is_time_frozen:
		return
		
	# Handle knockback
	if knockback_velocity.length() > 10.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
		velocity = knockback_velocity
		move_and_slide()
		return
	else:
		knockback_velocity = Vector2.ZERO

	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.CHASE:
			_state_chase(delta)
		State.WINDUP:
			_state_windup(delta)
		State.COOLDOWN:
			_state_cooldown(delta)

	move_and_slide()

func _state_idle(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _can_see_player():
		current_state = State.CHASE

func _state_chase(_delta: float) -> void:
	if not _can_see_player():
		current_state = State.IDLE
		return
		
	var dir = global_position.direction_to(player_ref.global_position)
	velocity = dir * MOVE_SPEED
	
	# Face direction
	_update_facing(dir)
	
	if global_position.distance_to(player_ref.global_position) <= ATTACK_RANGE:
		_enter_windup()

func _enter_windup() -> void:
	current_state = State.WINDUP
	state_timer = ATTACK_WINDUP
	velocity = Vector2.ZERO
	sprite.color = Color(1.0, 0.8, 0.0) # Flash yellow to telegraph

func _state_windup(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		_do_attack()

func _do_attack() -> void:
	# Lunge forward slightly
	if is_instance_valid(player_ref):
		var dir = global_position.direction_to(player_ref.global_position)
		_update_facing(dir)
		position += dir * 10.0
		
	attack_shape.disabled = false
	sprite.color = Color(1.0, 1.0, 1.0) # Flash white on strike
	
	# Check hits immediately
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage") and body.collision_layer & 1: # Player
			var push_dir = global_position.direction_to(body.global_position)
			body.take_damage(DAMAGE, push_dir)
	
	# End attack quickly
	await get_tree().create_timer(0.1).timeout
	attack_shape.disabled = true
	sprite.color = Color(0.8, 0.3, 0.0) # Normal color
	
	current_state = State.COOLDOWN
	state_timer = ATTACK_COOLDOWN

func _state_cooldown(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.IDLE

func _can_see_player() -> bool:
	if not is_instance_valid(player_ref):
		return false
	return global_position.distance_to(player_ref.global_position) <= DETECTION_RANGE

func _update_facing(dir: Vector2) -> void:
	if dir.length() > 0:
		attack_area.rotation = dir.angle()

func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO, _damage_type: String = "physical") -> void:
	if current_state == State.DEAD:
		return
		
	current_health -= amount
	
	# Visual hit flash
	sprite.color = Color(1.0, 1.0, 1.0)
	var tween = create_tween()
	tween.tween_property(sprite, "color", Color(0.8, 0.3, 0.0), 0.15)
	
	# Knockback
	knockback_velocity = from_direction * 150.0
	
	if current_health <= 0:
		_die()

func _die() -> void:
	current_state = State.DEAD
	attack_shape.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Leave a fire patch
	var patch_scene = load("res://scenes/player/powers/fire_patch.tscn")
	if patch_scene:
		var patch = patch_scene.instantiate()
		get_parent().call_deferred("add_child", patch)
		patch.global_position = global_position
	
	# Simple death animation
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
