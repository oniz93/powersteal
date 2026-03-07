extends BossBase

const MOVE_SPEED: float = 100.0
const PROJECTILE_SCENE = preload("res://scenes/player/powers/fireball_projectile.tscn")

@onready var sprite = $Sprite
@onready var interact_col = $InteractArea/CollisionShape2D
@onready var ritual_prompt = $RitualPrompt

var action_timer: float = 0.0
var slow_cooldown: float = 0.0
var is_sped_up: bool = false
var speed_up_timer: float = 0.0

func _ready() -> void:
	max_health = 40
	granted_power_id = &"time_freeze"
	super._ready()

func _on_phase_entered(phase: int) -> void:
	match phase:
		1:
			action_timer = 2.0
			slow_cooldown = 4.0
		2:
			sprite.color = Color("#C0C0C0")
		3:
			sprite.color = Color("#A0A0A0")
		4:
			sprite.color = Color("#808080")

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or current_state == State.IDLE:
		return
		
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	var current_speed = MOVE_SPEED
	if is_sped_up:
		speed_up_timer -= delta
		current_speed *= 2.0
		if speed_up_timer <= 0.0:
			is_sped_up = false
			sprite.color = sprite.color.lerp(Color.WHITE, 0.5) # reset blur
			
	# Move towards player
	if is_instance_valid(player_ref):
		var dir = global_position.direction_to(player_ref.global_position)
		if global_position.distance_to(player_ref.global_position) > 50.0:
			velocity = dir * current_speed
			move_and_slide()
		else:
			# Melee range, do a quick dash attack
			if action_timer <= 0.0:
				_do_melee_dash(dir)
				action_timer = 1.5

	# Global abilities
	slow_cooldown -= delta
	if slow_cooldown <= 0.0:
		_apply_global_slow()
		
	action_timer -= delta
	if action_timer <= 0.0 and current_state >= State.PHASE2:
		_shoot_slow_projectile()
		action_timer = 2.0

func _do_melee_dash(dir: Vector2) -> void:
	# Quick lunge
	var tw = create_tween()
	tw.tween_property(self, "global_position", global_position + dir * 60.0, 0.2)
	
	# Hurt player if hit
	if is_instance_valid(player_ref) and global_position.distance_to(player_ref.global_position) < 80.0:
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(1, dir, "physical")

func _apply_global_slow() -> void:
	if not is_instance_valid(player_ref): return
	
	if player_ref.has_method("apply_slow"):
		var dur = 3.0
		if current_state >= State.PHASE2: dur = 5.0
		player_ref.apply_slow(dur)
		
	# Visual cue
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.color.a = 0.3
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(flash)
	var tw = create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.5)
	tw.tween_callback(flash.queue_free)
	
	# Boss speeds up in later phases
	if current_state >= State.PHASE2:
		is_sped_up = true
		speed_up_timer = 2.0
		
	slow_cooldown = 8.0

func _shoot_slow_projectile() -> void:
	if not is_instance_valid(player_ref): return
	
	var dir = global_position.direction_to(player_ref.global_position)
	var proj = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + (dir * 20.0)
	proj.setup(dir, true)
	proj.leaves_patch = false
	
	# Modify projectile to be slow but last longer
	proj.SPEED = 100.0 # Very slow
	proj.LIFETIME = 5.0
	proj.get_node("Sprite").color = Color.WHITE

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
