extends Node2D
## Boss 2 Arena - The Hurler

@onready var boss = $Hurler
@onready var player = $Player
@onready var boss_health_bar = $HUD/BossHealthBar
@onready var player_health_bar = $HUD/HealthBar
@onready var energy_bar = $HUD/EnergyBar
@onready var slot1_ui = $HUD/PowerSlots/Slot1
@onready var slot2_ui = $HUD/PowerSlots/Slot2

const CRATE_SCENE = preload("res://scenes/player/powers/throwable_crate.tscn")
var spawn_timer: float = 0.0
const SPAWN_INTERVAL: float = 3.0 # Spawn a crate every 3 seconds
const MAX_CRATES: int = 15

func _ready() -> void:
	# Setup boss health bar
	boss_health_bar.max_value = boss.max_health
	boss_health_bar.value = boss.current_health
	
	boss.health_changed.connect(_on_boss_health_changed)
	boss.phase_changed.connect(_on_boss_phase_changed)
	boss.boss_died.connect(_on_boss_died)
	
	player.health_changed.connect(_on_player_health_changed)
	player.player_died.connect(_on_player_died)
	
	PowerManager.power_slot_changed.connect(_on_power_slot_changed)
	PowerManager.energy_changed.connect(_on_energy_changed)
	PowerManager.energy_bar_revealed.connect(_on_energy_bar_revealed)
	
	# Set energy bar visibility based on game state
	energy_bar.visible = PowerManager.energy_bar_visible
	
	# Restore carried energy
	PowerManager.set_energy(GameManager.get_carried_energy())
	GameManager.save_room_entry_energy(PowerManager.current_energy)
	
	# Init HUD
	_on_player_health_changed(player.current_health, player.MAX_HEALTH)
	_on_power_slot_changed(0, PowerManager.slot1_id)
	_on_power_slot_changed(1, PowerManager.slot2_id)

func _process(delta: float) -> void:
	if boss.current_state != boss.State.DEAD:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_timer = SPAWN_INTERVAL
			_try_spawn_crate()

func _try_spawn_crate() -> void:
	var existing = get_tree().get_nodes_in_group("grabbable").size()
	if existing >= MAX_CRATES:
		return
		
	var crate = CRATE_SCENE.instantiate()
	$Crates.add_child(crate)
	
	# Pick a random spot along the edges of the room
	var spawn_x = randf_range(50.0, 590.0)
	var spawn_y = randf_range(50.0, 310.0)
	crate.global_position = Vector2(spawn_x, spawn_y)
	
	# Pop in effect
	crate.scale = Vector2.ZERO
	var tw = create_tween()
	tw.tween_property(crate, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_boss_health_changed(current: int, _max: int) -> void:
	boss_health_bar.value = current

func _on_boss_phase_changed(new_phase: int) -> void:
	player._apply_screen_shake(4.0)
	
func _on_boss_died() -> void:
	boss_health_bar.visible = false

func _on_player_health_changed(new_health: int, max_health: int) -> void:
	# Ensure we have enough pips in the UI for the debug health
	while player_health_bar.get_child_count() < max_health:
		var new_pip = player_health_bar.get_child(0).duplicate()
		player_health_bar.add_child(new_pip)

	for i in player_health_bar.get_child_count():
		var pip := player_health_bar.get_child(i) as ColorRect
		if pip:
			if i < new_health:
				pip.color = Color(0.8, 0.0, 0.0, 1.0)  # Red = alive
			else:
				pip.color = Color(0.2, 0.2, 0.2, 0.4)  # Dark = lost

func _on_energy_changed(new_value: float, max_value: float) -> void:
	if energy_bar:
		energy_bar.max_value = max_value
		energy_bar.value = new_value

func _on_energy_bar_revealed() -> void:
	if energy_bar:
		energy_bar.visible = true

func _on_power_slot_changed(slot_idx: int, power_id: StringName) -> void:
	var slot_ui = slot1_ui if slot_idx == 0 else slot2_ui
	
	if power_id == &"":
		slot_ui.color = Color(0.2, 0.2, 0.2, 0.5)
	else:
		var p_color = Color.WHITE
		if slot_idx == 0 and PowerManager.slot1:
			p_color = PowerManager.slot1.power_color
		elif slot_idx == 1 and PowerManager.slot2:
			p_color = PowerManager.slot2.power_color
			
		slot_ui.color = p_color

func _on_player_died() -> void:
	pass
