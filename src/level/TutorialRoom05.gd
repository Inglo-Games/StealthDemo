extends Level


func _ready():
	
	# Run parent class _ready func first
	super._ready()
	
	$Player.inventory["noisemakers"] += 1
	dialogue_window.initialize_conversation("res://assets/dialogues/tut05_01.json")
