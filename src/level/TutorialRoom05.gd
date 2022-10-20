extends Level


func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	# Guards should reset player instead of game over
	for guard in $Guards.get_children():
		guard.player_caught.disconnect(_on_player_caught)
		guard.player_caught.connect(_on_player_reset)
		guard.player_caught.connect(_load_dialogue_03)
	
	# Start a very brief timer to allow guardds time to start moving before
	# pausing the scene for dialogues
	var temp_timer = Timer.new()
	add_child(temp_timer)
	temp_timer.start(0.1)
	await temp_timer.timeout
	temp_timer.queue_free()
	
	# Immediately load first dialogue and give player 3 Noisemakers
	PlayerInventory.give_items("noisemaker", 3)
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_01.json")
	
	# Load final when player reaches exit
	$NavigationRegion3D/LevelExitDoor.action_started.connect(_load_dialogue_02)


func _load_dialogue_02():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_02.json")


func _load_dialogue_03():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_03.json")
	PlayerInventory.give_items("noisemaker", 1)
