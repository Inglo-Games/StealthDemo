extends Level

# Keep track of which dialogues have been triggered
var dialogues_triggered := [ false, false, false ]

@onready var guard = $Guards/Guard

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	# Guard should reset player instead of game over
	guard.player_caught.disconnect(_on_player_caught)
	guard.player_caught.connect(_on_player_reset)
	
	# Start a very brief timer to allow guardds time to start moving before
	# pausing the scene for dialogues
	var temp_timer = Timer.new()
	add_child(temp_timer)
	temp_timer.start(0.1)
	await temp_timer.timeout
	temp_timer.queue_free()
	
	# Start initial dialogue
	_load_dialogue_01()
	
	# Load second and third dialogues after being caught
	guard.player_caught.connect(_load_dialogue_03)
	guard.player_caught.connect(_load_dialogue_02)
	
	# Load final dialogue when player reaches exit
	$NavigationRegion3D/LevelExitDoor.action_started.connect(_load_dialogue_04)


# Functions to load tutorial dialogues
func _load_dialogue_01():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut02_01.json")
	dialogues_triggered[0] = true

func _load_dialogue_02():
	if not dialogues_triggered[1]:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut02_02.json")
		dialogues_triggered[1] = true

func _load_dialogue_03():
	if not dialogues_triggered[2] and dialogues_triggered[1]:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut02_03.json")
		dialogues_triggered[2] = true

func _load_dialogue_04():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut02_04.json")
