extends Node3D
class_name Level

# Preload widely used scenes
var dialogue_window_scene = preload("res://src/dialog/DialogueWindow.tscn")
var noisemaker_scene = preload("res://src/items/Noisemaker.tscn")
var pause_scene = preload("res://src/menus/PauseMenu.tscn")

var dialogue_window = null


func _ready():
	
	print("Entered Level _ready function")
	
	# Lock mouse motion
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set up dialogue window
	dialogue_window = dialogue_window_scene.instantiate()
	add_child(dialogue_window)
	
	# Connect player's noise signal to guards
	for guard in $Guards.get_children():
		if guard is Guard:
			$Player.emit_noise.connect(guard.on_hear_noise)
	
	# Connect place_noisemaker signal to level
	$Player.place_noisemaker.connect(place_noisemaker)


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var pause_menu = pause_scene.instantiate()
		add_child(pause_menu)
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


func resume_from_dialogue():
	pass
