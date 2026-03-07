extends Node2D
class_name PowerBase
## Base class for all equippable powers

var power_name: StringName = &"Unknown"
var power_color: Color = Color.WHITE
var energy_cost: float = 0.0
var player_ref: CharacterBody2D = null

func _init() -> void:
	pass

func setup(player: CharacterBody2D) -> void:
	player_ref = player

## Called when the player presses the power button
func activate() -> bool:
	if PowerManager.consume_energy(energy_cost):
		_do_effect()
		PowerManager.power_used.emit(power_name.to_lower())
		return true
	return false

## Called when the player releases the power button (for hold-to-use powers like TK)
func deactivate() -> void:
	pass

## Override this in child classes to implement the actual power logic
func _do_effect() -> void:
	pass
