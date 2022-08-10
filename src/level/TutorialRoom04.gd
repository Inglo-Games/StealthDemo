extends Level



func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	# Immediately load the first dialogue
	_load_dialogue_01()
	
	# Load the first dialogue after tripping the first snare
	$RoomItems/SnareTrap01.emit_noise.connect(_load_dialogue_02)
	
	# Load the second dialogue after tripping the second snare
	$RoomItems/SnareTrap02.emit_noise.connect(_load_dialogue_03)
	
	# Load final dialogue on exit
	$RoomGeometry/LevelExitDoor.action_started.connect(_load_dialogue_04)


func _load_dialogue_01():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut04_01.json")

func _load_dialogue_02():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut04_02.json")

func _load_dialogue_03():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut04_03.json")
	$Player.inventory["boltcutters"] += 1

func _load_dialogue_04():
	dialogue_window.initialize_conversation("res://assets/dialogues/tut04_04.json")
