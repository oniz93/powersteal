extends Node
## SettingsManager - Handles saving/loading settings and input remapping

const SETTINGS_PATH = "user://settings.json"

var is_fullscreen: bool = false
var is_vsync: bool = true
var window_scale: float = 1.0 # Default 1x (1280x720)

# Stores the overridden events for actions. Format:
# { "action_name": { "type": "key", "value": KEY_SPACE } }
var custom_keybinds: Dictionary = {}

const REMAPPABLE_ACTIONS = [
	"move_up", "move_down", "move_left", "move_right",
	"dash", "melee", "power1", "power2", "interact"
]

func _ready() -> void:
	load_settings()
	apply_settings()

func save_settings() -> void:
	var data = {
		"fullscreen": is_fullscreen,
		"vsync": is_vsync,
		"window_scale": window_scale,
		"keybinds": custom_keybinds
	}
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
		
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var err = json.parse(file.get_line())
		if err == OK:
			var data = json.data
			is_fullscreen = data.get("fullscreen", false)
			is_vsync = data.get("vsync", true)
			window_scale = data.get("window_scale", 4)
			custom_keybinds = data.get("keybinds", {})

func apply_settings() -> void:
	var window = get_window()
	
	# Apply Video Settings
	if is_fullscreen:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		# Calculate window size based on our 1280x720 internal resolution
		var new_size = Vector2i(1280 * window_scale, 720 * window_scale)
		window.size = new_size
		
		# Center window
		var screen_size = DisplayServer.screen_get_size()
		window.position = (screen_size / 2) - (new_size / 2)
		
	if is_vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
	# Apply Keybinds
	for action in custom_keybinds:
		if action in REMAPPABLE_ACTIONS:
			var bind_data = custom_keybinds[action]
			var event = _dict_to_event(bind_data)
			if event:
				# Remove old key/mouse events but keep Joypad/JoyAxis events so controller keeps working
				var existing_events = InputMap.action_get_events(action)
				for e in existing_events:
					if e is InputEventKey or e is InputEventMouseButton:
						InputMap.action_erase_event(action, e)
						
				InputMap.action_add_event(action, event)

func update_keybind(action: String, event: InputEvent) -> void:
	if not action in REMAPPABLE_ACTIONS: return
	
	# Only allow keyboard and mouse for custom rebinds right now
	if not (event is InputEventKey or event is InputEventMouseButton):
		return
		
	custom_keybinds[action] = _event_to_dict(event)
	
	# Update live map
	var existing_events = InputMap.action_get_events(action)
	for e in existing_events:
		if e is InputEventKey or e is InputEventMouseButton:
			InputMap.action_erase_event(action, e)
			
	InputMap.action_add_event(action, event)
	save_settings()

func _event_to_dict(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return { "type": "key", "value": event.physical_keycode }
	elif event is InputEventMouseButton:
		return { "type": "mouse", "value": event.button_index }
	return {}

func _dict_to_event(data: Dictionary) -> InputEvent:
	if not data.has("type") or not data.has("value"): return null
	
	if data["type"] == "key":
		var e = InputEventKey.new()
		e.physical_keycode = data["value"]
		return e
	elif data["type"] == "mouse":
		var e = InputEventMouseButton.new()
		e.button_index = data["value"]
		return e
	return null

func get_event_string(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for e in events:
		if e is InputEventKey:
			return OS.get_keycode_string(e.physical_keycode)
		elif e is InputEventMouseButton:
			match e.button_index:
				MOUSE_BUTTON_LEFT: return "Left Mouse"
				MOUSE_BUTTON_RIGHT: return "Right Mouse"
				MOUSE_BUTTON_MIDDLE: return "Middle Mouse"
				MOUSE_BUTTON_XBUTTON1: return "Mouse 4"
				MOUSE_BUTTON_XBUTTON2: return "Mouse 5"
				_: return "Mouse " + str(e.button_index)
	return "Unbound"
