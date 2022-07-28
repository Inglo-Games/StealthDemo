extends Node3D
class_name Interactable

@export var locked := false
@export var open_time := 1.0
@export var unlock_time := 1.0
@export var break_time := 1.0
@export var key_id := ""

signal action_started
signal action_finished

var interacted := false
var open_timer := Timer.new()

func _init():
	add_child(open_timer)
	action_started = Signal(self, "action_started")

# Empty "virtual" function to be overridden by inheritor
func interact(variant):
	pass

func pick_lock(variant):
	pass

func is_interacted():
	return interacted

func set_interacted(val:bool):
	interacted = val

# Cancel any ongoing interaction like unlocking or lockpicking
func cancel_interaction():
	if not open_timer.is_stopped():
		print("Cancelling interaction...")
		open_timer.stop()
