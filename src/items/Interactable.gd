extends Node3D
class_name Interactable

@export var locked := false
@export var open_time := 1.0

signal action_started

var interacted := false
var open_timer := Timer.new()

func _init():
	add_child(open_timer)
	action_started = Signal(self, "action_started")

# Empty "virtual" function to be overridden by inherited 
func interact():
	pass

func is_interacted():
	return interacted

func set_interacted(val:bool):
	interacted = val

# Cancel any ongoing interaction like unlocking or lockpicking
func cancel_interaction():
	print("Cancelling interaction...")
	if not open_timer.is_stopped():
		open_timer.stop()
