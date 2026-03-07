extends CanvasLayer

var incoming_power_id: StringName = &""

@onready var panel = $Panel
@onready var title = $Panel/Title
@onready var slot1_btn = $Panel/VBox/Slot1Button
@onready var slot2_btn = $Panel/VBox/Slot2Button
@onready var discard_btn = $Panel/VBox/DiscardButton

signal power_swap_resolved

func setup(power_id: StringName) -> void:
	incoming_power_id = power_id
	title.text = "Acquired: " + power_id.capitalize()
	
	_update_slot_button(slot1_btn, 0)
	_update_slot_button(slot2_btn, 1)
	
	slot1_btn.grab_focus()

func _update_slot_button(btn: Button, slot_idx: int) -> void:
	var current_power_id = PowerManager.slot1_id if slot_idx == 0 else PowerManager.slot2_id
	if current_power_id == &"":
		btn.text = "Equip to Slot " + str(slot_idx + 1) + " (Empty)"
	else:
		btn.text = "Replace " + current_power_id.capitalize() + " (Slot " + str(slot_idx + 1) + ")"

func _on_slot1_pressed() -> void:
	_equip_power(0)

func _on_slot2_pressed() -> void:
	_equip_power(1)

func _on_discard_pressed() -> void:
	_resolve()

func _equip_power(slot_idx: int) -> void:
	PowerManager.clear_slot(slot_idx)
	
	# Load the new power
	var power_path = "res://scenes/player/powers/" + incoming_power_id.trim_suffix("s") + ".gd"
	var power_script = load(power_path)
	if power_script:
		var power_node = power_script.new()
		PowerManager.add_child(power_node)
		if slot_idx == 0:
			PowerManager.slot1 = power_node
		else:
			PowerManager.slot2 = power_node
		
		PowerManager.equip_power(slot_idx, incoming_power_id)
		
	_resolve()

func _resolve() -> void:
	# Hide UI and resume game
	get_tree().paused = false
	power_swap_resolved.emit()
	queue_free()
