extends Node3D
class_name Level

# Preload widely used scenes
var dialogue_window_scene = preload("res://src/dialog/DialogueWindow.tscn")
var inventory_scene = preload("res://src/menus/InventoryMenu.tscn")
var noisemaker_scene = preload("res://src/items/Noisemaker.tscn")
var pause_scene = preload("res://src/menus/PauseMenu.tscn")

# Window to show NPC dialogues
var dialogue_window = null

# Record players inital position and rotation
var player_start_pos : Transform3D 


func _ready():
	
	print("Entered Level _ready function")
	
	# Lock mouse motion
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set up dialogue window
	dialogue_window = dialogue_window_scene.instantiate()
	add_child(dialogue_window)
	
	# Connect player's noise signal to guards and player_caught signal to this
	for guard in $Guards.get_children():
		if guard is Guard:
			$Player.emit_noise.connect(guard.on_hear_noise)
			guard.player_caught.connect(_on_player_caught)
	
	# Connect place_noisemaker signal to level
	$Player.place_noisemaker.connect(place_noisemaker)
	
	# Record player's start pos and rot for _on_player_reset func
	player_start_pos = $Player.get_global_transform()


func _input(event):
	# Handle pause menu
	if event.is_action_pressed("ui_cancel"):
		var pause_menu = pause_scene.instantiate()
		add_child(pause_menu)
		get_tree().paused = true
	
	# Handle inventory menu
	elif event.is_action_pressed("open_inventory"):
		var inv_menu = inventory_scene.instantiate()
		add_child(inv_menu)
		get_tree().paused = true


# Create a new NoiseMaker object and place it in the specified position
func place_noisemaker(pos:Vector3, magnitude:int):
	var item = noisemaker_scene.instantiate()
	item.position = pos
	item.sound_strength = magnitude
	add_child(item)

	# Connect new noisemaker to all guards
	for guard in $Guards.get_children():
		if guard is Guard:
			item.emit_noise.connect(guard.on_hear_noise)


# Triggered when a guard catches the player
func _on_player_caught():
	get_tree().change_scene_to(load("res://src/menus/MainMenu.tscn"))


# Resets player to starting posision, used in tutorial levels
func _on_player_reset():
	$Player.set_global_transform(player_start_pos)
	for guard in $Guards.get_children():
		guard.reset_guard()
