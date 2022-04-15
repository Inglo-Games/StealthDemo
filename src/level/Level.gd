extends Node3D

var dialogue_window = preload("res://src/dialog/DialogueWindow.tscn")


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


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var pause_menu = load("res://src/menus/PauseMenu.tscn").instantiate()
		add_child(pause_menu)
		get_tree().paused = true


func resume_from_dialogue():
	pass
