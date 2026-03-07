extends CanvasLayer

@onready var mission_list = $Panel/HBox/VBox_Missions/MissionList
@onready var dossier_text = $Panel/HBox/VBox_Dossier/Panel/RichTextLabel
@onready var start_btn = $Panel/HBox/VBox_Dossier/StartButton

var selected_boss_index: int = 0

var dossiers: Array[String] = [
	"[b]TARGET: DESIGNATION 'HOTHEAD'[/b]\n\nLocation: Industrial district, warehouse 14B.\n\nAbility: Pyrokinesis. Generates and projects fire through physical contact and directed bursts.\n\nThreat assessment: Moderate. Aggressive, poor impulse control. Known to cause collateral damage. Multiple arson incidents attributed.\n\nApproach: Direct engagement recommended. Target is reckless — exploit openings after committed attacks.\n\nNote: First acquisition. Proceed with caution.",
	"It's getting easier. The ritual. The heat is still in my veins, but I need more.\n\n[b]TARGET: THE HURLER[/b]\n\nLocation: Abandoned shipping yard.\n\nAbility: Telekinesis. Moves objects with their mind. A coward who hides behind makeshift shields.\n\nApproach: They'll throw everything they have. I just need to get close enough. They can't throw me.",
	"They think it's a game. Blinking around, laughing. They don't know what's coming.\n\n[b]TARGET: THE BLITZER[/b]\n\nLocation: Neon rooftops.\n\nAbility: Phase Shift. Can teleport short distances instantly. Extremely elusive.\n\nApproach: Don't chase. Wait for the green flash. Anticipate where they will be, not where they are.",
	"I can feel the gap. Two powers and it's not enough. It's never enough. There's someone who can SLOW TIME. Think about that. Think about what that means — what I could do with that. What I could become.\n\n[b]TARGET: THE WARDEN[/b]\n\nLocation: The Clean Room.\n\nAbility: Time Distortion. Can warp local time fields.\n\nApproach: They think they are untouchable. They won't slow me down.",
	"I'm being followed. Someone is tracking my kills. They leave no signature, no trace. They don't have a power. They're just... waiting.\n\n[b]TARGET: THE HUNTER[/b]\n\nLocation: The Steelworks.\n\nAbility: None.\n\nApproach: They know what I can do. They've built counters. I have to be unpredictable. This ends tonight."
]

func _ready() -> void:
	# Populate list
	for i in range(5):
		var btn = Button.new()
		btn.text = "Mission " + str(i + 1)
		btn.add_theme_font_size_override("font_size", 8)
		if GameManager.is_boss_defeated(i):
			btn.text += " [COMPLETED]"
		
		# Only allow clicking available or completed missions
		if i > GameManager.get_next_available_boss() and GameManager.get_next_available_boss() != -1:
			btn.disabled = true
			
		btn.pressed.connect(_on_mission_selected.bind(i))
		mission_list.add_child(btn)
	
	# Select highest available
	var next = GameManager.get_next_available_boss()
	if next != -1:
		_on_mission_selected(next)
		mission_list.get_child(next).grab_focus()
	else:
		_on_mission_selected(0) # All done
		
	# Hook up debug button
	var debug_btn = $Panel/HBox/VBox_Dossier/DebugUnlockButton
	if debug_btn:
		debug_btn.pressed.connect(_on_debug_pressed)

func _on_debug_pressed() -> void:
	GameManager.debug_unlock_all()

func _on_mission_selected(index: int) -> void:
	selected_boss_index = index
	dossier_text.text = dossiers[index]
	
	if GameManager.is_boss_defeated(index):
		start_btn.text = "Replay Mission"
	else:
		start_btn.text = "Start Mission"

func _on_start_pressed() -> void:
	GameManager.current_boss_index = selected_boss_index
	GameManager.current_room_index = 0
	GameManager.set_carried_energy(0.0) # Reset energy on new mission
	
	match selected_boss_index:
		0: get_tree().change_scene_to_file("res://scenes/rooms/boss1_arena.tscn")
		1: get_tree().change_scene_to_file("res://scenes/rooms/boss2_arena.tscn")
		2: get_tree().change_scene_to_file("res://scenes/rooms/boss3_arena.tscn")
		3: get_tree().change_scene_to_file("res://scenes/rooms/boss4_arena.tscn")
		4: get_tree().change_scene_to_file("res://scenes/rooms/boss5_arena.tscn")
		_: print("Mission not built yet!")

const SETTINGS_SCENE = preload("res://scenes/ui/settings_menu.tscn")

func _on_settings_pressed() -> void:
	var settings = SETTINGS_SCENE.instantiate()
	get_tree().root.add_child(settings)

func _on_quit_pressed() -> void:
	get_tree().quit()
