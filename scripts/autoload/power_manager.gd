extends Node
## PowerManager — Handles power inventory, energy, and swap logic.

# Energy system
const MAX_ENERGY: float = 100.0
const ENERGY_REGEN_RATE: float = 5.0  # per second
var current_energy: float = 0.0

# Power slots
var slot1: Node = null  # Holds instances of PowerBase
var slot2: Node = null
var slot1_id: StringName = &""
var slot2_id: StringName = &""

# Energy bar visibility
var energy_bar_visible: bool = false

# Time Freeze mechanic
var is_time_frozen: bool = false
var time_freeze_timer: float = 0.0
var freeze_overlay: ColorRect = null

signal energy_changed(new_value: float, max_value: float)
signal power_slot_changed(slot_index: int, power_id: StringName)
signal energy_bar_revealed
signal power_used(power_id: StringName)

func _ready() -> void:
	# Setup global time freeze overlay
	var canvas = CanvasLayer.new()
	canvas.layer = 5 # Below UI, above game
	add_child(canvas)
	freeze_overlay = ColorRect.new()
	freeze_overlay.color = Color(0.8, 0.8, 0.8, 0.3)
	freeze_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	freeze_overlay.visible = false
	canvas.add_child(freeze_overlay)

func _process(delta: float) -> void:
	# Time freeze logic
	if is_time_frozen:
		time_freeze_timer -= delta
		if time_freeze_timer <= 0.0:
			is_time_frozen = false
			freeze_overlay.visible = false

	# Passive energy regeneration
	if current_energy < MAX_ENERGY:
		current_energy = minf(current_energy + ENERGY_REGEN_RATE * delta, MAX_ENERGY)
		energy_changed.emit(current_energy, MAX_ENERGY)


func trigger_time_freeze(duration: float) -> void:
	is_time_frozen = true
	time_freeze_timer = duration
	freeze_overlay.visible = true

func can_use_power(energy_cost: float) -> bool:
	return current_energy >= energy_cost


func consume_energy(amount: float) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		energy_changed.emit(current_energy, MAX_ENERGY)
		return true
	return false


func set_energy(value: float) -> void:
	current_energy = clampf(value, 0.0, MAX_ENERGY)
	energy_changed.emit(current_energy, MAX_ENERGY)


func reveal_energy_bar() -> void:
	if not energy_bar_visible:
		energy_bar_visible = true
		energy_bar_revealed.emit()
		GameManager.on_first_power_acquired()


func equip_power(slot_index: int, power_id: StringName) -> void:
	match slot_index:
		0:
			slot1_id = power_id
			power_slot_changed.emit(0, power_id)
		1:
			slot2_id = power_id
			power_slot_changed.emit(1, power_id)
			
	GameManager.save_game()

func get_first_empty_slot() -> int:
	## Returns 0 or 1 for empty slot, -1 if both full.
	if slot1_id == &"":
		return 0
	if slot2_id == &"":
		return 1
	return -1


func has_power(power_id: StringName) -> bool:
	return slot1_id == power_id or slot2_id == power_id

func _deferred_load_power(slot_idx: int, power_id: String) -> void:
	var power_path = "res://scenes/player/powers/" + power_id.trim_suffix("s") + ".gd"
	if ResourceLoader.exists(power_path):
		var power_script = load(power_path)
		if power_script:
			var power_node = power_script.new()
			add_child(power_node)
			if slot_idx == 0:
				if is_instance_valid(slot1): slot1.queue_free()
				slot1 = power_node
				slot1_id = power_id
			else:
				if is_instance_valid(slot2): slot2.queue_free()
				slot2 = power_node
				slot2_id = power_id

func clear_slot(slot_index: int) -> void:
	match slot_index:
		0:
			slot1_id = &""
			if is_instance_valid(slot1):
				slot1.queue_free()
			slot1 = null
			power_slot_changed.emit(0, &"")
		1:
			slot2_id = &""
			if is_instance_valid(slot2):
				slot2.queue_free()
			slot2 = null
			power_slot_changed.emit(1, &"")
			
	GameManager.save_game()


func reset() -> void:
	current_energy = 0.0
	clear_slot(0)
	clear_slot(1)
	energy_bar_visible = false
