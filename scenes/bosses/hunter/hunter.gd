extends BossBase

const RUN_SPEED: float = 100.0
const PROJECTILE_SCENE = preload("res://scenes/player/powers/fireball_projectile.tscn")
const SENTRY_SCENE = preload("res://scenes/bosses/hunter/gadget_sentry.tscn")

const POISON_SCENE = preload("res://scenes/bosses/hunter/poison_patch.tscn")

@onready var sprite = $Sprite
@onready var interact_col = $InteractArea/CollisionShape2D
@onready var ritual_prompt = $RitualPrompt
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D

var action_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var counter_cooldown: float = 0.0
var sentry_cooldown: float = 5.0
var poison_timer: float = 0.0

func _ready() -> void:
	max_health = 50
	granted_power_id = &"none" # Final boss
	
	PowerManager.power_used.connect(_on_player_power_used)
	attack_shape.disabled = true
	super._ready()

func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO, damage_type: String = "physical") -> void:
	if damage_type == "poison":
		return
	super.take_damage(amount, from_direction, damage_type)

func _on_phase_entered(phase: int) -> void:
	match phase:
		1:
			action_timer = 2.0
		2:
			sprite.color = Color("#554444")
		3:
			sprite.color = Color("#443333")
		4:
			sprite.color = Color("#332222")

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or current_state == State.IDLE:
		return
		
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	counter_cooldown -= delta
	
	sentry_cooldown -= delta
	if sentry_cooldown <= 0.0 and current_state >= State.PHASE1:
		var minions = get_tree().get_nodes_in_group("hunter_minions")
		if minions.size() < 2:
			_spawn_sentry()
			sentry_cooldown = 15.0
			
	if current_state >= State.PHASE2:
		poison_timer -= delta
		if poison_timer <= 0.0:
			_spawn_poison_trail()
			poison_timer = 0.5 # Drop a trail every 0.5s
		
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * 300.0
		move_and_slide()
		if dash_timer <= 0.0:
			is_dashing = false
			attack_shape.disabled = true
		return
		
	if is_instance_valid(player_ref):
		var dist = global_position.distance_to(player_ref.global_position)
		var dir = global_position.direction_to(player_ref.global_position)
		
		if dist > 80.0:
			velocity = dir * RUN_SPEED
		else:
			# Kite away slightly or circle
			var perpendicular = Vector2(-dir.y, dir.x)
			velocity = perpendicular * RUN_SPEED
			
		move_and_slide()
			
	action_timer -= delta
	if action_timer <= 0.0:
		_do_random_action()

func _do_random_action() -> void:
	if not is_instance_valid(player_ref): return
	
	var r = randf()
	if current_state >= State.PHASE3 and r < 0.2:
		_melee_combo()
	elif r < 0.35:
		_throw_flash()
	elif r < 0.6:
		_shoot_grapple()
	else:
		_shoot_projectile()
		
	match current_state:
		State.PHASE1: action_timer = 2.0
		State.PHASE2: action_timer = 1.5
		State.PHASE3: action_timer = 1.0
		State.PHASE4: action_timer = 0.5

func _spawn_sentry() -> void:
	var sentry = SENTRY_SCENE.instantiate()
	get_parent().add_child(sentry)
	var spawn_pos = Vector2(randf_range(100, 540), randf_range(100, 260))
	if is_instance_valid(player_ref) and spawn_pos.distance_to(player_ref.global_position) < 100:
		spawn_pos.x += 200 # Push it away
		if spawn_pos.x > 540: spawn_pos.x -= 400
	sentry.global_position = spawn_pos

func _spawn_poison_trail() -> void:
	var poison = POISON_SCENE.instantiate()
	get_parent().add_child(poison)
	poison.global_position = global_position

func _shoot_projectile() -> void:
	if not is_instance_valid(player_ref): return
	var dir = global_position.direction_to(player_ref.global_position)
	var proj = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + (dir * 20.0)
	proj.setup(dir, true)
	proj.leaves_patch = false
	proj.is_homing = true
	proj.target_node = player_ref
	
	var p_sprite = proj.get_node("Sprite")
	p_sprite.color = Color("#FFFF00") # Yellow bullet
	p_sprite.scale = Vector2(0.5, 0.5)

func _melee_combo() -> void:
	if not is_instance_valid(player_ref): return
	var dir = global_position.direction_to(player_ref.global_position)
	
	is_dashing = true
	dash_timer = 0.3
	dash_direction = dir
	
	attack_area.rotation = dir.angle()
	attack_shape.disabled = false
	
	for body in attack_area.get_overlapping_bodies():
		if body.collision_layer & 1 and body.has_method("take_damage"):
			body.take_damage(1, dir, "physical")

func _throw_flash() -> void:
	# A quick flashbang
	if not is_instance_valid(player_ref): return
	
	# Visual flash
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Set a high z_index so it covers everything including the map
	flash.z_index = 100 
	get_tree().root.add_child(flash)
	
	var tw = create_tween()
	# Hold full white for 0.5s, then fade out over 2.5s (3s total)
	tw.tween_interval(0.5)
	tw.tween_property(flash, "modulate:a", 0.0, 2.5)
	tw.tween_callback(flash.queue_free)
	
	if player_ref.has_method("_apply_screen_shake"):
		player_ref._apply_screen_shake(4.0)

func _shoot_grapple() -> void:
	if not is_instance_valid(player_ref): return
	# Simple pull
	var dir = global_position.direction_to(player_ref.global_position)
	player_ref.velocity = -dir * 800.0 # Yank player towards boss
	player_ref.move_and_slide()

# Adaptive counters
func _on_player_power_used(power_id: StringName) -> void:
	if current_state == State.DEAD or current_state == State.IDLE: return
	if counter_cooldown > 0.0: return
	
	counter_cooldown = 3.0 # Prevents spamming counters
	
	if power_id == &"fireballs":
		# Counter fireballs by dodging
		if is_instance_valid(player_ref):
			var dir_from_player = player_ref.aim_direction
			var perp = Vector2(-dir_from_player.y, dir_from_player.x)
			is_dashing = true
			dash_timer = 0.2
			dash_direction = perp
	elif power_id == &"telekinesis":
		# Counter TK by grappling player immediately
		_shoot_grapple()
	elif power_id == &"blink":
		# Counter blink by dropping an EMP zone at boss location
		_drop_emp()

func _drop_emp() -> void:
	# Add a simple static EMP area to the scene
	var emp = Area2D.new()
	emp.collision_layer = 0
	emp.collision_mask = 1
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 60.0
	col.shape = shape
	emp.add_child(col)
	
	var vis = ColorRect.new()
	vis.modulate = Color(1,1,1,0.2)
	vis.color = Color(0, 0.5, 1.0)
	vis.position = Vector2(-60, -60)
	vis.size = Vector2(120, 120)
	emp.add_child(vis)
	
	get_parent().add_child(emp)
	emp.global_position = global_position
	
	# Small script to apply EMP
	var gd_script = GDScript.new()
	gd_script.source_code = """
extends Area2D
func _physics_process(delta: float):
	for body in get_overlapping_bodies():
		if body.has_method('apply_emp'): body.apply_emp(0.1)
	"""
	gd_script.reload()
	emp.set_script(gd_script)
	emp.set_process_internal(true)

func _on_damage_taken() -> void:
	var old_color = sprite.color
	sprite.color = Color.WHITE
	await get_tree().create_timer(0.05).timeout
	if current_state != State.DEAD:
		sprite.color = old_color

func _on_death() -> void:
	sprite.color = Color.DARK_GRAY
	
	interact_col.set_deferred("disabled", false)
	ritual_prompt.visible = true
	ritual_prompt.get_node("ProgressBar").value = 0.0
	
	if is_instance_valid(player_ref) and player_ref.has_method("_apply_screen_shake"):
		player_ref._apply_screen_shake(6.0)
