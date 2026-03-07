extends CharacterBody2D
## Player — Main player character with state machine, movement, melee, dash, and aiming.

# Movement
const MOVE_SPEED: float = 120.0  # pixels/sec at native 480x270

# Dash
const DASH_SPEED: float = 350.0
const DASH_DURATION: float = 0.12  # seconds
const DASH_COOLDOWN: float = 0.5
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_invincible: bool = false

# Melee
const MELEE_COMBO_COUNT: int = 3
const MELEE_SWING_DURATION: float = 0.12  # each swing
const MELEE_COMBO_WINDOW: float = 0.3  # time to press next swing
const MELEE_RECOVERY: float = 0.25  # recovery after 3rd hit
const MELEE_DAMAGE: int = 1
const MELEE_RANGE: float = 20.0
var melee_combo_index: int = 0
var melee_timer: float = 0.0
var melee_window_timer: float = 0.0
var melee_input_buffered: bool = false
var _melee_hit_checked: bool = false  # Prevent double-hits per swing

# Swing flash (replaces await-based flash)
const SWING_FLASH_DURATION: float = 0.05
var _swing_flash_timer: float = 0.0

# Hit freeze (frame-based since Engine.time_scale affects all deltas)
const HIT_FREEZE_FRAMES: int = 3  # ~0.05s at 60fps
var _hit_freeze_frames_remaining: int = 0
var _is_hit_frozen: bool = false

# Health
const MAX_HEALTH: int = 30 # HACK: Set to 30 for debugging (normally 5)
var current_health: int = MAX_HEALTH
var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.5

# Slow multiplier (for Warden boss)
var slow_multiplier: float = 1.0
var slow_duration_left: float = 0.0

# EMP Status (for Hunter boss)
var is_emped: bool = false
var emp_duration_left: float = 0.0

# State machine
enum State {
	IDLE,
	MOVE,
	ATTACK,
	DASH,
	RITUAL,
	DEAD,
}
var current_state: State = State.IDLE

# Ritual
var _ritual_target: Node2D = null
var _ritual_progress: float = 0.0
const RITUAL_DURATION: float = 2.0

# Aim
var aim_direction: Vector2 = Vector2.RIGHT

# References
@onready var sprite: ColorRect = $Sprite
@onready var aim_indicator: ColorRect = $AimIndicator
@onready var melee_area: Area2D = $MeleeArea
@onready var melee_shape: CollisionShape2D = $MeleeArea/CollisionShape2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interact_area: Area2D = $InteractArea
@onready var hit_flash_timer: Timer = $HitFlashTimer
@onready var camera: Camera2D = $Camera2D

# Screen shake
var shake_intensity: float = 0.0
var shake_decay: float = 8.0

# Signals
signal health_changed(new_health: int, max_health: int)
signal player_died


func _ready() -> void:
	InputManager.register_player(self)
	melee_shape.disabled = true
	current_health = MAX_HEALTH
	health_changed.emit(current_health, MAX_HEALTH)
	
	# Setup powers on player load
	if PowerManager.slot1:
		PowerManager.slot1.setup(self)
	if PowerManager.slot2:
		PowerManager.slot2.setup(self)
	
	PowerManager.power_slot_changed.connect(_on_power_slot_changed)


func _on_power_slot_changed(slot_index: int, _power_id: StringName) -> void:
	# Ensure new powers get the player reference
	if slot_index == 0 and PowerManager.slot1:
		PowerManager.slot1.setup(self)
	elif slot_index == 1 and PowerManager.slot2:
		PowerManager.slot2.setup(self)


func _physics_process(delta: float) -> void:
	# Handle hit freeze (frame-based to avoid time_scale issues)
	if _is_hit_frozen:
		return  # Skip all gameplay logic during freeze

	# Update aim direction
	aim_direction = InputManager.get_aim_direction()
	_update_aim_indicator()

	# Handle power inputs
	_handle_power_inputs()

	# Update timers
	_update_invincibility(delta)
	_update_screen_shake(delta)
	_update_swing_flash(delta)
	_update_slow(delta)
	_update_emp(delta)

	# State machine
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.MOVE:
			_state_move(delta)
		State.ATTACK:
			_state_attack(delta)
		State.DASH:
			_state_dash(delta)
		State.RITUAL:
			_state_ritual(delta)
		State.DEAD:
			pass

	# Dash cooldown always ticks
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if current_state != State.DEAD:
		move_and_slide()


func _process(_delta: float) -> void:
	# Hit freeze countdown (frame-based, unaffected by time_scale)
	if _is_hit_frozen:
		_hit_freeze_frames_remaining -= 1
		if _hit_freeze_frames_remaining <= 0:
			_is_hit_frozen = false
			Engine.time_scale = 1.0


# --- POWERS ---
func _handle_power_inputs() -> void:
	if current_state == State.DEAD or is_emped:
		return
		
	if Input.is_action_just_pressed("power1") and PowerManager.slot1:
		PowerManager.slot1.activate()
	elif Input.is_action_just_released("power1") and PowerManager.slot1:
		PowerManager.slot1.deactivate()
		
	if Input.is_action_just_pressed("power2") and PowerManager.slot2:
		PowerManager.slot2.activate()
	elif Input.is_action_just_released("power2") and PowerManager.slot2:
		PowerManager.slot2.deactivate()


func _update_slow(delta: float) -> void:
	if slow_duration_left > 0.0:
		slow_duration_left -= delta
		if slow_duration_left <= 0.0:
			slow_multiplier = 1.0

func apply_slow(duration: float) -> void:
	slow_multiplier = 0.5
	slow_duration_left = maxf(slow_duration_left, duration)

func _update_emp(delta: float) -> void:
	if emp_duration_left > 0.0:
		emp_duration_left -= delta
		if emp_duration_left <= 0.0:
			is_emped = false

func apply_emp(duration: float) -> void:
	is_emped = true
	emp_duration_left = maxf(emp_duration_left, duration)

# --- STATE: IDLE ---
func _state_idle(_delta: float) -> void:
	velocity = Vector2.ZERO

	# Transitions
	if Input.is_action_pressed("interact") and _can_start_ritual():
		_enter_ritual()
		return
	if Input.is_action_just_pressed("dash") and _can_dash():
		_enter_dash()
		return
	if Input.is_action_just_pressed("melee"):
		_enter_attack()
		return
	if InputManager.get_movement_vector().length() > 0.1:
		current_state = State.MOVE


# --- STATE: MOVE ---
func _state_move(_delta: float) -> void:
	var input_dir := InputManager.get_movement_vector()

	if input_dir.length() < 0.1:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		return

	velocity = input_dir.normalized() * MOVE_SPEED * slow_multiplier

	# Transitions
	if Input.is_action_pressed("interact") and _can_start_ritual():
		_enter_ritual()
		return
	if Input.is_action_just_pressed("dash") and _can_dash():
		_enter_dash()
		return
	if Input.is_action_just_pressed("melee"):
		_enter_attack()
		return


# --- STATE: ATTACK ---
func _state_attack(delta: float) -> void:
	# Allow movement during attack, but slightly slower (75% speed)
	var input_dir := InputManager.get_movement_vector()
	velocity = input_dir.normalized() * (MOVE_SPEED * 0.75) * slow_multiplier

	melee_timer -= delta

	# Buffer next input during swing
	if Input.is_action_just_pressed("melee"):
		melee_input_buffered = true

	# Check for hits during active swing (once per swing)
	if melee_timer > 0.0 and not _melee_hit_checked:
		_check_melee_hits()
		_melee_hit_checked = true

	if melee_timer <= 0.0:
		melee_shape.disabled = true

		# Check if we can continue the combo
		if melee_combo_index < MELEE_COMBO_COUNT:
			# In combo window — waiting for next press
			melee_window_timer -= delta
			if melee_input_buffered or Input.is_action_just_pressed("melee"):
				_do_melee_swing()
				melee_input_buffered = false
			elif melee_window_timer <= 0.0:
				# Combo window expired
				_end_attack()
		else:
			# After 3rd hit — recovery period
			melee_window_timer -= delta
			if melee_window_timer <= 0.0:
				_end_attack()

	# Allow dash cancel during attack
	if Input.is_action_just_pressed("dash") and _can_dash():
		melee_shape.disabled = true
		_enter_dash()


func _enter_attack() -> void:
	current_state = State.ATTACK
	melee_combo_index = 0
	melee_input_buffered = false
	_do_melee_swing()


func _do_melee_swing() -> void:
	melee_combo_index += 1
	_melee_hit_checked = false

	# Each swing gets slightly faster
	var speed_mult := 1.0 - (melee_combo_index - 1) * 0.1  # 1.0, 0.9, 0.8
	melee_timer = MELEE_SWING_DURATION * speed_mult

	if melee_combo_index >= MELEE_COMBO_COUNT:
		melee_window_timer = MELEE_RECOVERY  # Recovery after 3rd hit
	else:
		melee_window_timer = MELEE_COMBO_WINDOW

	# Position and activate melee hitbox
	_position_melee_hitbox()
	melee_shape.disabled = false
	melee_input_buffered = false

	# Visual feedback — flash white briefly using timer (no await)
	sprite.color = Color(1.0, 1.0, 1.0)
	_swing_flash_timer = SWING_FLASH_DURATION

	# Apply screen shake on swing
	_apply_screen_shake(1.5)


func _position_melee_hitbox() -> void:
	melee_area.position = aim_direction * MELEE_RANGE
	melee_area.rotation = aim_direction.angle()


func _check_melee_hits() -> void:
	var current_dmg = MELEE_DAMAGE
	if PowerManager.get("is_time_frozen"):
		current_dmg += 1 # 1.5x rounded up essentially (1 -> 2)
		
	for body in melee_area.get_overlapping_bodies():
		if body.has_method("take_damage") and body != self:
			body.take_damage(current_dmg, aim_direction, "physical")
			_apply_screen_shake(3.0)
			_do_hit_freeze()


func _end_attack() -> void:
	melee_combo_index = 0
	melee_shape.disabled = true
	current_state = State.IDLE


func _update_swing_flash(delta: float) -> void:
	if _swing_flash_timer > 0.0:
		_swing_flash_timer -= delta
		if _swing_flash_timer <= 0.0 and current_state != State.DEAD:
			sprite.color = Color(0.8, 0.0, 0.0)  # Back to player red


# --- STATE: DASH ---
func _enter_dash() -> void:
	current_state = State.DASH
	dash_cooldown_timer = DASH_COOLDOWN
	dash_timer = DASH_DURATION
	dash_invincible = true

	# Dash in movement direction, or aim direction if standing still
	var move_input := InputManager.get_movement_vector()
	if move_input.length() > 0.1:
		dash_direction = move_input.normalized()
	else:
		dash_direction = aim_direction

	# Visual feedback
	modulate.a = 0.5  # Semi-transparent during dash


func _state_dash(delta: float) -> void:
	velocity = dash_direction * DASH_SPEED * slow_multiplier
	dash_timer -= delta

	if dash_timer <= 0.0:
		dash_invincible = false
		modulate.a = 1.0
		current_state = State.IDLE


func _can_dash() -> bool:
	return dash_cooldown_timer <= 0.0 and current_state != State.DEAD


# --- STATE: RITUAL ---
func _can_start_ritual() -> bool:
	var bodies = interact_area.get_overlapping_areas()
	for body in bodies:
		if body.is_in_group("interactable"):
			_ritual_target = body.get_parent() # Boss node is parent of InteractArea
			return true
	return false

func _enter_ritual() -> void:
	current_state = State.RITUAL
	_ritual_progress = 0.0
	velocity = Vector2.ZERO

func _state_ritual(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if not Input.is_action_pressed("interact"):
		# Cancel ritual
		current_state = State.IDLE
		_reset_ritual_visuals()
		return
		
	# Update progress
	_ritual_progress += delta
	_update_ritual_visuals()
	
	if _ritual_progress >= RITUAL_DURATION:
		_complete_ritual()

func _update_ritual_visuals() -> void:
	_apply_screen_shake(1.0 + (_ritual_progress * 1.5))
	
	# Update the boss's prompt progress bar if it exists
	if is_instance_valid(_ritual_target) and _ritual_target.has_node("RitualPrompt/ProgressBar"):
		_ritual_target.get_node("RitualPrompt/ProgressBar").value = _ritual_progress

func _reset_ritual_visuals() -> void:
	if is_instance_valid(_ritual_target) and _ritual_target.has_node("RitualPrompt/ProgressBar"):
		_ritual_target.get_node("RitualPrompt/ProgressBar").value = 0.0

func _complete_ritual() -> void:
	_apply_screen_shake(8.0)
	
	# White flash
	var bg = ColorRect.new()
	bg.color = Color.WHITE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(bg)
	# Bind tween to the background itself, so if the player node is destroyed on scene change, the tween finishes
	var tw = bg.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Keep running even if game pauses for menu
	tw.tween_property(bg, "modulate:a", 0.0, 0.5)
	tw.tween_callback(bg.queue_free)
	
	# Remove boss interaction
	if is_instance_valid(_ritual_target):
		_ritual_target.get_node("InteractArea/CollisionShape2D").disabled = true
		_ritual_target.get_node("RitualPrompt").visible = false
	
	current_state = State.IDLE
	
	# Determine which power to give based on the target
	var power_to_grant: StringName = &"fireballs" # default
	if is_instance_valid(_ritual_target) and _ritual_target is BossBase:
		power_to_grant = _ritual_target.granted_power_id
		
	# Trigger power swap logic via GameManager
	GameManager.trigger_power_swap(power_to_grant)

# --- HEALTH ---
func take_damage(amount: int, _from_direction: Vector2 = Vector2.ZERO, _damage_type: String = "physical") -> void:
	if dash_invincible or invincibility_timer > 0.0 or current_state == State.DEAD:
		return

	current_health -= amount
	health_changed.emit(current_health, MAX_HEALTH)

	# Hit feedback
	invincibility_timer = INVINCIBILITY_DURATION
	_apply_screen_shake(4.0)
	_do_hit_freeze()

	# Visual flash
	sprite.color = Color(1.0, 1.0, 1.0)
	hit_flash_timer.start(0.1)

	if current_health <= 0:
		_die()


func _update_invincibility(delta: float) -> void:
	if invincibility_timer > 0.0:
		invincibility_timer -= delta
		# Blink effect
		sprite.visible = fmod(invincibility_timer, 0.12) > 0.06
	else:
		sprite.visible = true


func _die() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	melee_shape.set_deferred("disabled", true)
	player_died.emit()

	# Brief death visual
	sprite.color = Color(0.3, 0.0, 0.0)
	modulate.a = 0.5

	# Restart room after brief delay
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(self):
		get_tree().reload_current_scene()


func heal_to_full() -> void:
	current_health = MAX_HEALTH
	health_changed.emit(current_health, MAX_HEALTH)


# --- AIM ---
func _update_aim_indicator() -> void:
	aim_indicator.position = aim_direction * 18.0


# --- SCREEN SHAKE ---
func _apply_screen_shake(intensity: float) -> void:
	shake_intensity = maxf(shake_intensity, intensity)


func _update_screen_shake(delta: float) -> void:
	if shake_intensity > 0.0:
		camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = maxf(0.0, shake_intensity - shake_decay * delta)
	else:
		camera.offset = Vector2.ZERO


# --- HIT FREEZE ---
func _do_hit_freeze() -> void:
	if _is_hit_frozen:
		return  # Don't stack freezes
	_is_hit_frozen = true
	_hit_freeze_frames_remaining = HIT_FREEZE_FRAMES
	Engine.time_scale = 0.05


# --- SIGNALS ---
func _on_hit_flash_timer_timeout() -> void:
	if current_state != State.DEAD:
		sprite.color = Color(0.8, 0.0, 0.0)  # Player base red
