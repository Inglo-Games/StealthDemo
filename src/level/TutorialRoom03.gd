extends Level

# Keep track of which dialogues have been triggered
var dialogues_triggered := [ false, false, false ]

@onready var guard = $Guards/GuardBot


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
	
	# Immediately load the first dialogue
	_load_dialogue_01()
	
	# Load second when guard spots interacted desk
	guard.interacted_item_spotted.connect(_load_dialogue_02)
	
	# Load final when player reaches exit
	$NavigationRegion3D/LevelExitDoor.action_started.connect(_load_dialogue_03)


# Functions to load tutorial dialogues
func _load_dialogue_01():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut03_01.json")
	dialogues_triggered[0] = true

func _load_dialogue_02():
	if not dialogues_triggered[1]:
		dialogue_window.initialize_conversation("res://assets/dialogues/tut03_02.json")
		dialogues_triggered[1] = true

func _load_dialogue_03():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut03_03.json")
