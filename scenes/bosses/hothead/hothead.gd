extends BossBase

const MOVE_SPEED: float = 140.0
const CHARGE_SPEED_MULT: float = 1.5 # 50% faster than player base speed
const FIREBALL_SCENE: PackedScene = preload("res://scenes/player/powers/fireball_projectile.tscn")
const FIRE_PATCH_SCENE: PackedScene = preload("res://scenes/player/powers/fire_patch.tscn")

# Phase state tracking
var charge_timer: float = 0.0
var pause_timer: float = 0.0
var is_charging: bool = false
var charge_direction: Vector2 = Vector2.ZERO

var trail_timer: float = 0.0
const TRAIL_SPAWN_RATE: float = 0.2

var attacks_since_pause: int = 0
var contact_damage_cooldown: float = 0.0

@onready var sprite: ColorRect = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var aura_area: Area2D = $AuraArea

func _ready() -> void:
	max_health = 25 # He takes 25 melee hits to die (or fewer if we hit him with his own element, though he's fire so maybe we don't have it yet)
	super._ready()
	aura_area.monitoring = false

func _on_phase_entered(phase: int) -> void:
	match phase:
		1:
			pause_timer = 2.0 # Initial pause before he starts
		2:
			sprite.color = Color("#ff4400") # slightly more intense
		3:
			sprite.color = Color("#ff2200") 
		4:
			sprite.color = Color("#ff0000") # Berserk red
			aura_area.monitoring = true # Activate contact damage aura
			$AuraArea/AuraVisual.visible = true

func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO, damage_type: String = "physical") -> void:
	if damage_type == "fire":
		return # Hothead is immune to fire
		
	super.take_damage(amount, from_direction, damage_type)

func _on_damage_taken() -> void:
	# Flash white
	var old_color = sprite.color
	sprite.color = Color.WHITE
	await get_tree().create_timer(0.05).timeout
	if current_state != State.DEAD:
		sprite.color = old_color

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or current_state == State.IDLE:
		return
		
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	if contact_damage_cooldown > 0.0:
		contact_damage_cooldown -= delta
		
	# Phase logic
	match current_state:
		State.PHASE1:
			_process_combat_loop(delta, 1.0, 2.0, 1) # Normal speed, 2s pause, 1 fireball
		State.PHASE2:
			_process_combat_loop(delta, 1.5, 1.5, 3) # Fast charge, 1.5s pause, 3 fireballs
		State.PHASE3:
			_process_combat_loop(delta, 1.5, 1.5, 3, true) # Adds ground slam (handled in attacks count)
		State.PHASE4:
			_process_combat_loop(delta, 1.8, 1.0, 3, true) # Berserk speed, 1s pause

	move_and_slide()
	_check_player_contact()

func _check_player_contact() -> void:
	if contact_damage_cooldown > 0.0 or not is_instance_valid(player_ref):
		return
		
	# Simple distance check for contact damage (radius roughly 24 + player radius 12 = 36)
	if global_position.distance_to(player_ref.global_position) < 32.0:
		if player_ref.has_method("take_damage"):
			var push_dir = global_position.direction_to(player_ref.global_position)
			player_ref.take_damage(1, push_dir, "physical")
			contact_damage_cooldown = 1.0 # 1 second cooldown before hitting player again

func _process_combat_loop(delta: float, speed_mult: float, max_pause: float, fireball_count: int, allow_slam: bool = false) -> void:
	if pause_timer > 0.0:
		pause_timer -= delta
		velocity = Vector2.ZERO
		if pause_timer <= 0.0:
			_start_attack(allow_slam, fireball_count)
		return
		
	if is_charging:
		charge_timer -= delta
		velocity = charge_direction * MOVE_SPEED * speed_mult
		
		# Drop fire trails while charging
		trail_timer -= delta
		if trail_timer <= 0.0:
			trail_timer = TRAIL_SPAWN_RATE
			_spawn_fire_patch()
			
		# Bounce off walls (rough estimate if we hit something)
		if is_on_wall():
			charge_direction = charge_direction.bounce(get_wall_normal())
			
		if charge_timer <= 0.0:
			is_charging = false
			pause_timer = max_pause
			attacks_since_pause += 1

func _start_attack(allow_slam: bool, fireball_count: int) -> void:
	if not is_instance_valid(player_ref):
		return
		
	var dir_to_player = global_position.direction_to(player_ref.global_position)
	
	# Decide attack type
	if allow_slam and attacks_since_pause >= 2:
		# Do Ground Slam
		_do_ground_slam()
		attacks_since_pause = 0
		pause_timer = 1.0 # Recovery
	elif randf() > 0.5:
		# Charge
		is_charging = true
		charge_timer = 1.5 # Charge for 1.5 seconds
		charge_direction = dir_to_player
	else:
		# Shoot fireballs
		_shoot_fireballs(dir_to_player, fireball_count)
		pause_timer = 1.0 # Recovery from shooting

func _shoot_fireballs(dir: Vector2, count: int) -> void:
	if count == 1:
		_spawn_fireball(dir)
	else:
		# 3-spread
		var angle_offset = deg_to_rad(15)
		_spawn_fireball(dir.rotated(-angle_offset))
		_spawn_fireball(dir)
		_spawn_fireball(dir.rotated(angle_offset))

func _spawn_fireball(dir: Vector2) -> void:
	var proj = FIREBALL_SCENE.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + (dir * 20.0)
	proj.setup(dir, true) # true = is_enemy

func _spawn_fire_patch() -> void:
	var patch = FIRE_PATCH_SCENE.instantiate()
	get_parent().add_child(patch)
	patch.global_position = global_position

func _do_ground_slam() -> void:
	# Flash yellow to telegraph
	sprite.color = Color.YELLOW
	
	# Freeze briefly
	await get_tree().create_timer(0.5).timeout
	if current_state == State.DEAD: return
	
	# Reset color
	sprite.color = Color("#ff2200") if current_state == State.PHASE3 else Color("#ff0000")
	
	# Spawn a ring of fireballs outward
	var num_projectiles = 8
	for i in range(num_projectiles):
		var angle = (PI * 2.0 / num_projectiles) * i
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_fireball(dir)
		
	# Screen shake
	if is_instance_valid(player_ref) and player_ref.has_method("_apply_screen_shake"):
		player_ref._apply_screen_shake(5.0)

func _on_death() -> void:
	sprite.color = Color.DARK_GRAY
	aura_area.monitoring = false
	$AuraArea/AuraVisual.visible = false
	
	# Become interactable for ritual
	$InteractArea/CollisionShape2D.set_deferred("disabled", false)
	$RitualPrompt.visible = true
	$RitualPrompt/ProgressBar.value = 0.0
	
	# Small visual death flourish
	if is_instance_valid(player_ref) and player_ref.has_method("_apply_screen_shake"):
		player_ref._apply_screen_shake(6.0)

# Contact damage for berserk aura
func _on_aura_area_body_entered(body: Node2D) -> void:
	if current_state == State.PHASE4 and body.collision_layer & 1:
		if body.has_method("take_damage"):
			var push_dir = global_position.direction_to(body.global_position)
			body.take_damage(1, push_dir)
