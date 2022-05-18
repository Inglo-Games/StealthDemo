extends Node3D

var dialogue_window = preload("res://src/dialog/DialogueWindow.tscn")
var noisemaker = preload("res://src/items/Noisemaker.tscn")


func _ready():
	# Create an initial dialogue window
	var d = dialogue_window.instantiate()
	add_child(d)
	d.initialize_conversation("res://assets/dialogues/tutorial_00.json")
	d.dialogue_ended.connect(resume_from_dialogue)
	
	# Connect player's noise signal to guards
	for guard in $Guards.get_children():
		if guard is Guard:
			$Player.emit_noise.connect(guard.on_hear_noise)
	
	# DEBUG: Add a noisemaker to scene
	place_noisemaker(Vector3(0, 0, -30), 15)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var pause_menu = load("res://src/menus/PauseMenu.tscn").instantiate()
		add_child(pause_menu)
		get_tree().paused = true


# Create a new NoiseMaker object and place it in the specified position
func place_noisemaker(pos:Vector3, magnitude:int):
	var item = noisemaker.instantiate()
	add_child(item)
	item.position = pos
	
	# Connect new noisemaker to all guards
	for guard in $Guards.get_children():
		if guard is Guard:
			item.emit_noise.connect(guard.on_hear_noise)


func resume_from_dialogue():
	pass
