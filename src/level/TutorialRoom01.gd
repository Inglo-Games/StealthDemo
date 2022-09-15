extends Level

# Keep track of which dialogues have been triggered
var dialogues_triggered := [ false, false, false, false, false ]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	# Immediately load the first dialogue
	_load_dialogue_01()
	
	# Load second dialogue when player tries to open a locked safe w/o key
	$RoomItems/safe.action_started.connect(_load_dialogue_02)
	
	# Load third dialogue when player gets a lockpick from the dresser
	$RoomItems/Dresser.action_finished.connect(_load_dialogue_03)
	
	# Load fourth dialogue when player gets safe key from the desk
	$RoomItems/Desk.action_finished.connect(_load_dialogue_04)
	
	# Load final dialogue when player opens safe
	$RoomItems/safe.action_finished.connect(_load_dialogue_05)


# Functions to load tutorial dialogues
func _load_dialogue_01():
	if not dialogues_triggered[0]:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut01_01.json")
		dialogues_triggered[0] = true

func _load_dialogue_02():
	if not dialogues_triggered[1] and $RoomItems/safe.locked and $Player.keyring.find("Tutorial Safe Combo") == -1:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut01_02.json")
		dialogues_triggered[1] = true

func _load_dialogue_03():
	if not dialogues_triggered[2]:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut01_03.json")
		dialogues_triggered[2] = true

func _load_dialogue_04():
	if not dialogues_triggered[3] and not $RoomItems/Desk.locked:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut01_04.json")
		dialogues_triggered[3] = true

func _load_dialogue_05():
	if not dialogues_triggered[4]:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut01_05.json")
		dialogues_triggered[4] = true
