extends Level


func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	# Immediately load first dialogue and give player a Noisemaker item
	$Player.inventory["noisemakers"] += 1
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_01.json")
	
	# Load final when player reaches exit
	$NavigationRegion3D/LevelExitDoor.action_started.connect(_load_dialogue_02)


func _load_dialogue_02():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_02.json")
