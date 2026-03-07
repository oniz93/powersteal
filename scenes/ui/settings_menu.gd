extends CanvasLayer

@onready var fullscreen_btn = $Panel/TabContainer/Graphics/VBox/FullscreenCheck
@onready var vsync_btn = $Panel/TabContainer/Graphics/VBox/VSyncCheck
@onready var resolution_btn = $Panel/TabContainer/Graphics/VBox/ResolutionHBox/ResolutionOption

@onready var controls_vbox = $Panel/TabContainer/Controls/Scroll/VBox
@onready var waiting_label = $WaitingOverlay

var waiting_for_action: String = ""

func _ready() -> void:
	_init_graphics_tab()
	_init_controls_tab()
	waiting_label.visible = false

func _init_graphics_tab() -> void:
	fullscreen_btn.button_pressed = SettingsManager.is_fullscreen
	vsync_btn.button_pressed = SettingsManager.is_vsync
	
	# Set current resolution index (scale - 1)
	resolution_btn.selected = SettingsManager.window_scale - 1
	
	fullscreen_btn.toggled.connect(_on_fullscreen_toggled)
	vsync_btn.toggled.connect(_on_vsync_toggled)
	resolution_btn.item_selected.connect(_on_resolution_selected)

func _on_resolution_selected(index: int) -> void:
	SettingsManager.window_scale = index + 1
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _on_fullscreen_toggled(pressed: bool) -> void:
	SettingsManager.is_fullscreen = pressed
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _on_vsync_toggled(pressed: bool) -> void:
	SettingsManager.is_vsync = pressed
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _init_controls_tab() -> void:
	for action in SettingsManager.REMAPPABLE_ACTIONS:
		var hbox = HBoxContainer.new()
		
		var lbl = Label.new()
		lbl.text = action.capitalize()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)
		
		var btn = Button.new()
		btn.text = SettingsManager.get_event_string(action)
		btn.custom_minimum_size = Vector2(100, 0)
		btn.pressed.connect(_on_rebind_pressed.bind(action, btn))
		hbox.add_child(btn)
		
		controls_vbox.add_child(hbox)

func _on_rebind_pressed(action: String, btn: Button) -> void:
	waiting_for_action = action
	waiting_label.visible = true
	
	# Store the button reference temporarily so we can update its text later
	set_meta("rebind_btn", btn)

func _input(event: InputEvent) -> void:
	if waiting_for_action != "":
		if event is InputEventKey and not event.pressed:
			return # Wait for press, not release
		if event is InputEventMouseButton and not event.pressed:
			return
			
		if event is InputEventKey or event is InputEventMouseButton:
			# Apply the new bind
			SettingsManager.update_keybind(waiting_for_action, event)
			
			# Update the button text
			var btn = get_meta("rebind_btn") as Button
			if btn:
				btn.text = SettingsManager.get_event_string(waiting_for_action)
			
			# Stop waiting
			waiting_for_action = ""
			waiting_label.visible = false
			get_viewport().set_input_as_handled()

func _on_close_button_pressed() -> void:
	queue_free()
