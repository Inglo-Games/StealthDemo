extends ItemBox
class_name Desk


func _ready():
	
	# Load item-specific sound resources
	open_sound = load("res://assets/sfx/desk_open.wav")
	close_sound = load("res://assets/sfx/desk_close.wav")
