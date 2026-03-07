extends CanvasLayer

@onready var continue_btn = $Panel/VBox/ContinueButton
@onready var settings_btn = $Panel/VBox/SettingsButton
@onready var menu_btn = $Panel/VBox/MenuButton

const SETTINGS_SCENE = preload("res://scenes/ui/settings_menu.tscn")

func _ready() -> void:
	get_tree().paused = true
	continue_btn.grab_focus()

func _input(event: InputEvent) -> void:
	# Check for "pause" action (Esc or Start button) to unpause quickly
	if event.is_action_pressed("pause"):
		_on_continue_pressed()
		get_viewport().set_input_as_handled()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_settings_pressed() -> void:
	var settings = SETTINGS_SCENE.instantiate()
	get_tree().root.add_child(settings)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/hub_menu.tscn")
