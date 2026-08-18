extends CharacterBody2D
class_name BossBase
## Base class for all Boss encounters

signal phase_changed(new_phase: int)
signal health_changed(current: int, max_health: int)
signal boss_died

@export var max_health: int = 100
@export var granted_power_id: StringName = &"fireballs"
var current_health: int = 100
var current_phase: int = 1

enum State {
	IDLE,
	PHASE1,
	PHASE2,
	PHASE3,
	PHASE4,
	STUNNED,
	DEAD
}
var current_state: State = State.IDLE

var player_ref: Node2D = null

func _ready() -> void:
	current_health = max_health
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]
		
	# Delay starting Phase 1 slightly to let the scene load
	await get_tree().create_timer(1.0).timeout
	if current_state != State.DEAD:
		_transition_to_phase(1)

func take_damage(amount: int, _from_direction: Vector2 = Vector2.ZERO, _damage_type: String = "physical") -> void:
	if current_state == State.DEAD or current_state == State.IDLE:
		# IDLE is the brief pre-fight window before Phase 1 starts. Ignore
		# damage here so an early hit cannot advance phases and then be
		# overwritten by the delayed _transition_to_phase(1) in _ready().
		return

	current_health -= amount
	health_changed.emit(current_health, max_health)

	_on_damage_taken()
	_check_phase_transition()
	
	if current_health <= 0:
		_die()

## Override to add custom hit flash / effects
func _on_damage_taken() -> void:
	pass

func _check_phase_transition() -> void:
	var hp_percent = float(current_health) / float(max_health)
	
	if hp_percent <= 0.75 and current_phase == 1:
		_transition_to_phase(2)
	elif hp_percent <= 0.50 and current_phase == 2:
		_transition_to_phase(3)
	elif hp_percent <= 0.25 and current_phase == 3:
		_transition_to_phase(4)

func _transition_to_phase(phase: int) -> void:
	current_phase = phase
	phase_changed.emit(phase)
	
	match phase:
		1: current_state = State.PHASE1
		2: current_state = State.PHASE2
		3: current_state = State.PHASE3
		4: current_state = State.PHASE4
		
	_on_phase_entered(phase)

## Override in specific boss scripts to setup attacks/speeds for the new phase
func _on_phase_entered(_phase: int) -> void:
	pass

func _die() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	boss_died.emit()
	_on_death()

## Override for specific death animation (e.g. ritual prompt)
func _on_death() -> void:
	pass
