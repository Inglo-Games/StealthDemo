extends Node3D

var dialogue_window = preload("res://src/dialog/DialogueWindow.tscn")
var noisemaker = preload("res://src/items/Noisemaker.tscn")


func _ready():
	# Connect player's noise signal to guards
	for guard in $Guards.get_children():
		if guard is Guard:
			$Player.emit_noise.connect(guard.on_hear_noise)


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var pause_menu = load("res://src/menus/PauseMenu.tscn").instantiate()
		add_child(pause_menu)
		get_tree().paused = true


# Create a new NoiseMaker object and place it in the specified position
func place_noisemaker(pos:Vector3, magnitude:int):
	var item = noisemaker.instantiate()
	item.position = pos
	item.sound_strength = magnitude
	add_child(item)

	# Connect new noisemaker to all guards
	for guard in $Guards.get_children():
		if guard is Guard:
			item.emit_noise.connect(guard.on_hear_noise)


func resume_from_dialogue():
	pass
