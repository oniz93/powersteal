extends Node2D

@onready var boss = $Warden
@onready var player = $Player
@onready var boss_health_bar = $HUD/BossHealthBar
@onready var player_health_bar = $HUD/HealthBar
@onready var energy_bar = $HUD/EnergyBar
@onready var slot1_ui = $HUD/PowerSlots/Slot1
@onready var slot2_ui = $HUD/PowerSlots/Slot2

func _ready() -> void:
	boss_health_bar.max_value = boss.max_health
	boss_health_bar.value = boss.current_health
	
	boss.health_changed.connect(_on_boss_health_changed)
	boss.phase_changed.connect(_on_boss_phase_changed)
	boss.boss_died.connect(_on_boss_died)
	
	player.health_changed.connect(_on_player_health_changed)
	
	PowerManager.power_slot_changed.connect(_on_power_slot_changed)
	PowerManager.energy_changed.connect(_on_energy_changed)
	PowerManager.energy_bar_revealed.connect(_on_energy_bar_revealed)
	
	energy_bar.visible = PowerManager.energy_bar_visible
	PowerManager.set_energy(GameManager.get_carried_energy())
	GameManager.save_room_entry_energy(PowerManager.current_energy)
	
	_on_player_health_changed(player.current_health, player.MAX_HEALTH)
	_on_power_slot_changed(0, PowerManager.slot1_id)
	_on_power_slot_changed(1, PowerManager.slot2_id)

func _on_boss_health_changed(current: int, _max: int) -> void:
	boss_health_bar.value = current

func _on_boss_phase_changed(_new_phase: int) -> void:
	player._apply_screen_shake(4.0)
	
func _on_boss_died() -> void:
	boss_health_bar.visible = false

func _on_player_health_changed(new_health: int, max_health: int) -> void:
	while player_health_bar.get_child_count() < max_health:
		var new_pip = player_health_bar.get_child(0).duplicate()
		player_health_bar.add_child(new_pip)

	for i in player_health_bar.get_child_count():
		var pip := player_health_bar.get_child(i) as ColorRect
		if pip:
			if i < new_health:
				pip.color = Color(0.8, 0.0, 0.0, 1.0)
			else:
				pip.color = Color(0.2, 0.2, 0.2, 0.4)

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
		if slot_idx == 0 and PowerManager.slot1: p_color = PowerManager.slot1.power_color
		elif slot_idx == 1 and PowerManager.slot2: p_color = PowerManager.slot2.power_color
		slot_ui.color = p_color
