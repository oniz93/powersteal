extends CharacterBody2D
class_name ThrowableObject
## A physics object that can be grabbed and thrown using Telekinesis

const THROWN_SPEED: float = 400.0
const DAMAGE: int = 2

enum State { IDLE, GRABBED, THROWN }
var current_state: State = State.IDLE

var throw_direction: Vector2 = Vector2.ZERO
var grabber_node: Node2D = null
var thrower_node: Node2D = null
var hold_offset: float = 30.0 # Distance from grabber

@onready var collision_shape = $CollisionShape2D
@onready var hitbox = $Hitbox
@onready var sprite = $Sprite

func _ready() -> void:
	add_to_group("grabbable")
	hitbox.monitoring = false # Only monitor for hits when thrown
	hitbox.monitorable = false

func _physics_process(delta: float) -> void:
	if PowerManager.has_method("is_time_frozen") and PowerManager.get("is_time_frozen"):
		return
		
	match current_state:
		State.IDLE:
			# Simple friction if sliding
			velocity = velocity.move_toward(Vector2.ZERO, 800.0 * delta)
			move_and_slide()
			
		State.GRABBED:
			if is_instance_valid(grabber_node):
				# Smoothly interpolate position to hover in front of the grabber
				var target_pos = grabber_node.global_position + (grabber_node.aim_direction * hold_offset)
				global_position = global_position.lerp(target_pos, 15.0 * delta)
			else:
				# Drop if grabber disappears
				drop()
				
		State.THROWN:
			var collision = move_and_collide(throw_direction * THROWN_SPEED * delta)
			if collision:
				_on_impact(collision.get_collider())

func grab(by_node: Node2D) -> void:
	current_state = State.GRABBED
	grabber_node = by_node
	
	# Disable physics collisions while held so it doesn't block the player
	collision_layer = 0
	collision_mask = 0
	sprite.color = Color("#9B30FF") # Purple tint while grabbed
	
	# Small visual pop
	var tw = create_tween()
	tw.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(sprite, "scale", Vector2.ONE, 0.1)

func throw(direction: Vector2) -> void:
	current_state = State.THROWN
	thrower_node = grabber_node
	throw_direction = direction.normalized()
	grabber_node = null
	
	# Re-enable collision with walls (layer 4) and enable hurtbox for enemies
	collision_layer = 0
	collision_mask = 4 
	
	hitbox.monitoring = true
	
	sprite.color = Color("#ffffff") # Flash white on throw
	var tw = create_tween()
	tw.tween_property(sprite, "color", Color("#9B30FF"), 0.2)

func drop() -> void:
	current_state = State.IDLE
	grabber_node = null
	
	# Restore normal collision
	collision_layer = 16 # interactables or whatever we use for crates
	collision_mask = 1 | 2 | 4 | 16
	sprite.color = Color(0.6, 0.4, 0.2) # Normal wood color
	hitbox.monitoring = false

func _on_impact(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE, throw_direction, "physical")
	
	_destroy()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if current_state != State.THROWN:
		return
		
	# Ignore the person who threw it
	if is_instance_valid(thrower_node) and body == thrower_node:
		return
		
	_on_impact(body)

func _destroy() -> void:
	# Add particle effect here later
	queue_free()

func take_damage(_amount: int, _dir: Vector2 = Vector2.ZERO, _type: String = "physical") -> void:
	# Break if hit by melee or fireball
	if current_state == State.IDLE:
		_destroy()
