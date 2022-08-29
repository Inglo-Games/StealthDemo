extends Level


func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	# Start a very brief timer to allow guardds time to start moving before
	# pausing the scene for dialogues
	var temp_timer = Timer.new()
	add_child(temp_timer)
	temp_timer.start(0.1)
	await temp_timer.timeout
	temp_timer.queue_free()
	
	# Immediately load first dialogue and give player a Noisemaker item
	$Player.inventory["noisemakers"] += 1
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_01.json")
	
	# Load final when player reaches exit
	$NavigationRegion3D/LevelExitDoor.action_started.connect(_load_dialogue_02)


func _load_dialogue_02():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_02.json")
