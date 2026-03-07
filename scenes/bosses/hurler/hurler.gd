extends BossBase

const RUN_SPEED: float = 120.0
const DASH_SPEED: float = 400.0

@onready var sprite = $Sprite
@onready var interact_col = $InteractArea/CollisionShape2D
@onready var ritual_prompt = $RitualPrompt

var objects_thrown: int = 0
var action_timer: float = 0.0

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	max_health = 30
	granted_power_id = &"telekinesis"
	super._ready()

func _on_phase_entered(phase: int) -> void:
	match phase:
		1:
			action_timer = 2.0
		2:
			sprite.color = Color("#8B008B") # Darker purple
		3:
			sprite.color = Color("#4B0082")
		4:
			sprite.color = Color("#300050")

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or current_state == State.IDLE:
		return
		
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		
		# If he hits a wall while dashing, end dash early
		if is_on_wall() or dash_timer <= 0.0:
			is_dashing = false
		return
		
	# Simple logic: try to run away from player
	if is_instance_valid(player_ref):
		var dist = global_position.distance_to(player_ref.global_position)
		if dist < 140.0:
			# Kite away
			var dir_away = player_ref.global_position.direction_to(global_position)
			velocity = dir_away * RUN_SPEED
			move_and_slide()
			
			# If we are trying to run away but hit a wall, we might be cornered
			if is_on_wall() and velocity.length() > 0:
				_try_evasive_dash()
		else:
			velocity = Vector2.ZERO
			
	action_timer -= delta
	if action_timer <= 0.0:
		_throw_something()

func _try_evasive_dash() -> void:
	# Don't dash too often
	if is_dashing: return
	
	if is_instance_valid(player_ref):
		# Dash roughly perpendicular or past the player to escape the corner
		var dir_to_player = global_position.direction_to(player_ref.global_position)
		var perpendicular = Vector2(-dir_to_player.y, dir_to_player.x)
		
		# Pick the direction that points more towards the center of the room (roughly 320, 180)
		var center_dir = global_position.direction_to(Vector2(320, 180))
		if perpendicular.dot(center_dir) < 0:
			perpendicular = -perpendicular
			
		is_dashing = true
		dash_timer = 0.25 # Quick dash
		dash_direction = (perpendicular + center_dir * 0.5).normalized()

func _throw_something() -> void:
	# Reset timer based on phase immediately so we don't grab multiple crates per frame while awaiting
	match current_state:
		State.PHASE1: action_timer = 2.0
		State.PHASE2: action_timer = 1.5
		State.PHASE3: action_timer = 1.0
		State.PHASE4: action_timer = 0.5
		_: action_timer = 2.0

	# Find a crate and throw it
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	var valid_crates = []
	for g in grabbables:
		if g is ThrowableObject and g.current_state == ThrowableObject.State.IDLE:
			valid_crates.append(g)
			
	if valid_crates.size() > 0:
		# Find the nearest crate
		var nearest_crate = valid_crates[0]
		var min_dist = global_position.distance_squared_to(nearest_crate.global_position)
		
		for i in range(1, valid_crates.size()):
			var crate = valid_crates[i]
			var dist = global_position.distance_squared_to(crate.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest_crate = crate
				
		nearest_crate.grab(self)
		
		# Give it a tiny delay to float before throwing
		await get_tree().create_timer(0.4).timeout
		if current_state != State.DEAD and is_instance_valid(nearest_crate) and is_instance_valid(player_ref):
			var throw_dir = nearest_crate.global_position.direction_to(player_ref.global_position)
			nearest_crate.throw(throw_dir)

func _on_damage_taken() -> void:
	var old_color = sprite.color
	sprite.color = Color.WHITE
	
	# React to damage by trying to escape immediately
	_try_evasive_dash()
	
	await get_tree().create_timer(0.05).timeout
	if current_state != State.DEAD:
		sprite.color = old_color

func _on_death() -> void:
	sprite.color = Color.DARK_GRAY
	
	# Drop anything he's holding
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	for g in grabbables:
		if g is ThrowableObject and g.grabber_node == self:
			g.drop()
	
	# Become interactable for ritual
	interact_col.set_deferred("disabled", false)
	ritual_prompt.visible = true
	ritual_prompt.get_node("ProgressBar").value = 0.0
	
	# Death flash
	if is_instance_valid(player_ref) and player_ref.has_method("_apply_screen_shake"):
		player_ref._apply_screen_shake(6.0)

# The boss aims where he wants to throw for the crate logic
var aim_direction: Vector2 = Vector2.DOWN
func _process(_delta: float) -> void:
	if is_instance_valid(player_ref):
		aim_direction = global_position.direction_to(player_ref.global_position)
