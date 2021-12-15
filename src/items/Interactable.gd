extends Node3D
class_name Interactable

var interacted := false
var interact_area := Area3D.new()

func _ready():
	interact_area.body_entered.connect(_connect_player_interact_signal)
	interact_area.body_exited.connect(_disconnect_player_interact_signal)

func _connect_player_interact_signal(body):
	if body is Player:
		body.interact.connect(_interact)
		print("Connected player's interact signal to object")

func _disconnect_player_interact_signal(body):
	if body is Player:
		body.interact.disconnect(_interact)
		print("Disconnected player's interact signal from object")

# Empty "virtual" function to be overridden by inherited 
func _interact():
	pass

func is_interacted():
	return interacted

func set_interacted(val:bool):
	interacted = val
