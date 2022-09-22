extends ItemBox
class_name Dresser


func _ready():
	
	# Load item-specific sound resources
	open_sound = load("res://assets/sfx/dresser_open.wav")
	close_sound = load("res://assets/sfx/dresser_close.wav")
