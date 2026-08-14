extends BossBase

const KNIFE_SCENE = preload("res://scenes/player/powers/fireball_projectile.tscn") # Hack: reuse fireball as knife, will color it green

@onready var sprite = $Sprite
@onready var interact_col = $InteractArea/CollisionShape2D
@onready var ritual_prompt = $RitualPrompt
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D

var phase_timer: float = 0.0

# Blink logic
var waypoints: Array[Vector2] = []
var current_waypoint_index: int = 0
var telegraph_timer: float = 0.0
var blink_cooldown: float = 0.0
var is_telegraphing: bool = false
var next_position: Vector2 = Vector2.ZERO

# Phase 4 Set-Path variables
var current_path: Array[int] = []
var path_index: int = 0
var is_in_chain: bool = false

func _ready() -> void:
	max_health = 35
	granted_power_id = &"blink"
	
	# Define arena waypoints (centered in 2560x1440)
	waypoints = [
		Vector2(840, 400), # 0: Top left
		Vector2(1280, 400), # 1: Top center
		Vector2(1720, 400), # 2: Top right
		Vector2(840, 1040), # 3: Bottom left
		Vector2(1280, 1040), # 4: Bottom center
		Vector2(1720, 1040), # 5: Bottom right
		Vector2(1280, 720), # 6: Center
	]
	
	attack_shape.disabled = true
	super._ready()

func _on_phase_entered(phase: int) -> void:
	match phase:
		1:
			blink_cooldown = 1.5
		2:
			sprite.color = Color("#22cc22")
			blink_cooldown = 1.0
		3:
			sprite.color = Color("#11aa11")
			blink_cooldown = 0.8
		4:
			sprite.color = Color("#008800")
			blink_cooldown = 1.5 # Cooldown is between CHAINS, not individual blinks

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or current_state == State.IDLE:
		return
		
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	if is_telegraphing:
		telegraph_timer -= delta
		if telegraph_timer <= 0.0:
			_execute_blink()
		return
		
	blink_cooldown -= delta
	if blink_cooldown <= 0.0:
		_start_next_move()

func _start_next_move() -> void:
	if not is_instance_valid(player_ref): return
	
	match current_state:
		State.PHASE1:
			# Predictable 3-position rotation (0 -> 1 -> 6 -> 0...)
			var p1_cycle = [0, 1, 6]
			current_waypoint_index = (current_waypoint_index + 1) % p1_cycle.size()
			_start_telegraph(waypoints[p1_cycle[current_waypoint_index]], 0.5)
			
		State.PHASE2:
			# Random waypoint, faster
			var next_wp = randi() % waypoints.size()
			_start_telegraph(waypoints[next_wp], 0.5)
			
		State.PHASE3:
			# Try to blink exactly behind the player
			var dir_from_player = player_ref.aim_direction * -1
			var backstab_pos = player_ref.global_position + (dir_from_player * 80.0)
			
			# Clamp to room bounds (2560x1440)
			backstab_pos.x = clamp(backstab_pos.x, 100, 2460)
			backstab_pos.y = clamp(backstab_pos.y, 100, 1340)
			
			_start_telegraph(backstab_pos, 0.3)
			
		State.PHASE4:
			# Chain logic
			if not is_in_chain:
				# Start a new chain
				is_in_chain = true
				path_index = 0
				# Pick a path pattern
				if randf() > 0.5:
					current_path = [0, 1, 2, 5, 4, 3] # Around the room
				else:
					current_path = [3, 6, 2, 6, 0, 6, 5] # Star pattern
					
			# Execute next step in chain
			_start_telegraph(waypoints[current_path[path_index]], 0.2)

func _start_telegraph(pos: Vector2, duration: float) -> void:
	is_telegraphing = true
	telegraph_timer = duration
	next_position = pos
	
	# Spawn visual telegraph
	var indicator = ColorRect.new()
	indicator.color = Color("#39FF14")
	indicator.color.a = 0.5
	indicator.size = Vector2(24, 24)
	indicator.position = pos - Vector2(12, 12)
	get_parent().add_child(indicator)
	
	var tw = create_tween()
	tw.tween_property(indicator, "scale", Vector2.ZERO, duration)
	tw.tween_callback(indicator.queue_free)
	
	# If Phase 4, briefly draw a line to the next waypoint
	if current_state == State.PHASE4 and path_index + 1 < current_path.size():
		pass # Implement line drawing later if needed

func _execute_blink() -> void:
	is_telegraphing = false
	
	# Set up next cooldown immediately before any await
	if current_state == State.PHASE4 and is_in_chain:
		path_index += 1
		if path_index >= current_path.size():
			is_in_chain = false
			blink_cooldown = 1.5 # Rest after chain
		else:
			blink_cooldown = 0.1 # Very fast chain
	else:
		match current_state:
			State.PHASE1: blink_cooldown = 1.5
			State.PHASE2: blink_cooldown = 1.0
			State.PHASE3: blink_cooldown = 0.6
			_: blink_cooldown = 1.0
	
	# Ghost at start
	_spawn_ghost(global_position)
	
	# Move
	global_position = next_position
	
	if is_instance_valid(player_ref):
		var dir_to_player = global_position.direction_to(player_ref.global_position)
		
		# Melee attack
		attack_area.rotation = dir_to_player.angle()
		attack_shape.disabled = false
		
		for body in attack_area.get_overlapping_bodies():
			if body.collision_layer & 1 and body.has_method("take_damage"):
				body.take_damage(1, dir_to_player, "physical")
				
		# Phase 2 adds ranged attack
		if current_state == State.PHASE2 or current_state == State.PHASE4:
			var knife = KNIFE_SCENE.instantiate()
			get_parent().add_child(knife)
			knife.global_position = global_position + (dir_to_player * 15.0)
			knife.setup(dir_to_player, true)
			knife.get_node("Sprite").color = Color("#39FF14") # Make it green
			
	# Disable attack hitbox quickly
	await get_tree().create_timer(0.1).timeout
	if current_state != State.DEAD:
		attack_shape.disabled = true

func _spawn_ghost(pos: Vector2) -> void:
	var ghost = ColorRect.new()
	ghost.color = sprite.color
	ghost.color.a = 0.5
	ghost.size = Vector2(24, 24)
	ghost.position = pos - Vector2(12, 12)
	get_tree().root.add_child(ghost)
	var tw = create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tw.tween_callback(ghost.queue_free)

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
