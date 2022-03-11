extends Node3D

var dialogue_window = preload("res://src/dialog/DialogueWindow.tscn")


func _ready():
	# Create an initial dialogue window
	var d = dialogue_window.instantiate()
	add_child(d)
	d.initialize_conversation("res://assets/dialogues/tutorial_00.json")
	d.dialogue_ended.connect(resume_from_dialogue)

func resume_from_dialogue():
	pass