extends Node
## GameManager — Global game state, progression, room management.

# Boss completion tracking
var bosses_defeated: Array[bool] = [false, false, false, false, false]
var current_boss_index: int = 0
var current_room_index: int = 0

# Energy carry-over between rooms
var carried_energy: float = 0.0
var room_entry_energy: float = 0.0  # Energy when entering current room (for death reset)

# First power flag (controls energy bar visibility)
var first_power_acquired: bool = false

signal boss_defeated(boss_index: int)
signal power_first_acquired

const SAVE_PATH = "user://save_data.json"

func _ready() -> void:
	# Force window to 1080p for testing
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_position(Vector2i(0, 0)) # Center roughly, depends on OS
	load_game()

func mark_boss_defeated(index: int) -> void:
	if index >= 0 and index < bosses_defeated.size():
		bosses_defeated[index] = true
		boss_defeated.emit(index)
		save_game()


func is_boss_defeated(index: int) -> bool:
	if index >= 0 and index < bosses_defeated.size():
		return bosses_defeated[index]
	return false


func get_next_available_boss() -> int:
	for i in bosses_defeated.size():
		if not bosses_defeated[i]:
			return i
	return -1  # All defeated


func set_carried_energy(energy: float) -> void:
	carried_energy = energy


func get_carried_energy() -> float:
	return carried_energy


func save_room_entry_energy(energy: float) -> void:
	room_entry_energy = energy


func get_room_entry_energy() -> float:
	return room_entry_energy


func on_first_power_acquired() -> void:
	if not first_power_acquired:
		first_power_acquired = true
		power_first_acquired.emit()


const POWER_SWAP_SCENE: PackedScene = preload("res://scenes/ui/power_swap.tscn")

func trigger_power_swap(power_id: StringName) -> void:
	if power_id == &"none":
		_trigger_ending()
		return
		
	var tree = get_tree()
	
	# If there's an empty slot, don't show the menu, just equip it automatically
	var empty_slot = PowerManager.get_first_empty_slot()
	if empty_slot != -1:
		var power_path = "res://scenes/player/powers/" + power_id.trim_suffix("s") + ".gd"
		var power_script = load(power_path)
		if power_script:
			var power_node = power_script.new()
			PowerManager.add_child(power_node)
			if empty_slot == 0:
				PowerManager.slot1 = power_node
			else:
				PowerManager.slot2 = power_node
			PowerManager.equip_power(empty_slot, power_id)
		
		# Show energy bar if it's the first power
		if power_id == "fireballs" and not PowerManager.energy_bar_visible:
			PowerManager.reveal_energy_bar()
			
		_finish_mission()
		return

	# Show swap menu
	tree.paused = true
	var swap_menu = POWER_SWAP_SCENE.instantiate()
	tree.root.add_child(swap_menu)
	swap_menu.setup(power_id)
	
	swap_menu.power_swap_resolved.connect(_finish_mission)

func _trigger_ending() -> void:
	mark_boss_defeated(current_boss_index)
	# Fade to black and show credits
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	var bg = ColorRect.new()
	bg.color = Color.BLACK
	bg.modulate.a = 0.0
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)
	get_tree().root.add_child(canvas)
	
	# Pause the game for the dramatic fade
	get_tree().paused = true
	
	var tw = bg.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(2.0) # Wait a bit in silence
	tw.tween_property(bg, "modulate:a", 1.0, 3.0) # Slow fade
	
	var credits = Label.new()
	credits.text = "POWERSTEAL\n\nThanks for playing."
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	credits.set_anchors_preset(Control.PRESET_FULL_RECT)
	credits.modulate.a = 0.0
	bg.add_child(credits)
	
	tw.tween_property(credits, "modulate:a", 1.0, 2.0)

func _finish_mission() -> void:
	mark_boss_defeated(current_boss_index)
	# Load Hub Menu
	get_tree().change_scene_to_file("res://scenes/ui/hub_menu.tscn")

func save_game() -> void:
	var save_dict = {
		"bosses_defeated": bosses_defeated,
		"first_power_acquired": first_power_acquired,
		"slot1_id": PowerManager.slot1_id,
		"slot2_id": PowerManager.slot2_id,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(save_dict))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return # No save file yet
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_line())
		if error == OK:
			var data = json.data
			bosses_defeated.assign(data.get("bosses_defeated", [false, false, false, false, false]))
			first_power_acquired = data.get("first_power_acquired", false)
			
			var s1 = data.get("slot1_id", "")
			var s2 = data.get("slot2_id", "")
			
			if first_power_acquired:
				PowerManager.energy_bar_visible = true
				
			# We can't safely load nodes during _ready of an autoload easily,
			# so we'll just store them in PowerManager and let it instantiate them
			if s1 != "": PowerManager._deferred_load_power(0, s1)
			if s2 != "": PowerManager._deferred_load_power(1, s2)

func debug_unlock_all() -> void:
	bosses_defeated = [true, true, true, true, false] # Unlock 1-4, boss 5 is final
	first_power_acquired = true
	PowerManager.energy_bar_visible = true
	PowerManager._deferred_load_power(0, "fireballs")
	PowerManager._deferred_load_power(1, "telekinesis")
	save_game()
	# Reload hub scene to show new unlocks
	get_tree().change_scene_to_file("res://scenes/ui/hub_menu.tscn")

func reset_for_new_game() -> void:
	bosses_defeated = [false, false, false, false, false]
	current_boss_index = 0
	current_room_index = 0
	carried_energy = 0.0
	room_entry_energy = 0.0
	first_power_acquired = false
	bosses_defeated = [false, false, false, false, false]
	current_boss_index = 0
	current_room_index = 0
	carried_energy = 0.0
	room_entry_energy = 0.0
	first_power_acquired = false
