extends Node2D
## TestRoom — Basic room for testing player mechanics.

@onready var player: CharacterBody2D = $Player
@onready var health_bar: HBoxContainer = $HUD/HealthBar
@onready var energy_bar: ProgressBar = $HUD/EnergyBar
@onready var dash_indicator: ColorRect = $HUD/DashCooldownIndicator
@onready var debug_label: Label = $HUD/DebugLabel


func _ready() -> void:
	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.player_died.connect(_on_player_died)

	# Connect energy signal
	PowerManager.energy_changed.connect(_on_energy_changed)
	PowerManager.energy_bar_revealed.connect(_on_energy_bar_revealed)

	# Set energy bar visibility based on game state
	energy_bar.visible = PowerManager.energy_bar_visible

	# Restore carried energy
	PowerManager.set_energy(GameManager.get_carried_energy())
	GameManager.save_room_entry_energy(PowerManager.current_energy)

	# Init HUD
	_on_player_health_changed(player.current_health, player.MAX_HEALTH)


func _process(_delta: float) -> void:
	_update_debug_label()
	_update_dash_indicator()


func _update_debug_label() -> void:
	var state_name: String
	match player.current_state:
		player.State.IDLE: state_name = "IDLE"
		player.State.MOVE: state_name = "MOVE"
		player.State.ATTACK: state_name = "ATTACK"
		player.State.DASH: state_name = "DASH"
		player.State.DEAD: state_name = "DEAD"
		_: state_name = "???"

	var dash_status := "ready" if player.dash_cooldown_timer <= 0.0 else "%.1f" % player.dash_cooldown_timer
	var energy_text := "%.0f/%.0f" % [PowerManager.current_energy, PowerManager.MAX_ENERGY]

	debug_label.text = "State: %s\nCombo: %d\nDash: %s\nEnergy: %s" % [
		state_name,
		player.melee_combo_index,
		dash_status,
		energy_text,
	]


func _update_dash_indicator() -> void:
	if player.dash_cooldown_timer <= 0.0:
		dash_indicator.color = Color(0.2, 0.8, 0.2, 0.7)  # Green = ready
	else:
		dash_indicator.color = Color(0.5, 0.5, 0.5, 0.3)  # Gray = cooling down


func _on_player_health_changed(new_health: int, max_health: int) -> void:
	# Ensure we have enough pips in the UI for the debug health
	while health_bar.get_child_count() < max_health:
		var new_pip = health_bar.get_child(0).duplicate()
		health_bar.add_child(new_pip)

	for i in health_bar.get_child_count():
		var pip := health_bar.get_child(i) as ColorRect
		if pip:
			if i < new_health:
				pip.color = Color(0.8, 0.0, 0.0, 1.0)  # Red = alive
			else:
				pip.color = Color(0.2, 0.2, 0.2, 0.4)  # Dark = lost


func _on_energy_changed(new_value: float, max_value: float) -> void:
	energy_bar.max_value = max_value
	energy_bar.value = new_value


func _on_energy_bar_revealed() -> void:
	energy_bar.visible = true


func _on_player_died() -> void:
	# Energy resets to room entry value on death
	GameManager.set_carried_energy(GameManager.get_room_entry_energy())
