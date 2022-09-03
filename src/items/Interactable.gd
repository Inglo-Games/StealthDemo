extends Node3D
class_name Interactable

@export var locked := false
@export var open_time := 1.0
@export var unlock_time := 1.0
@export var break_time := 1.0
@export var key_id := ""

signal action_started
signal action_finished

# Track if this object is in its default state, will make Guards suspicious
var interacted := false

# Timer to track time to open and if an interaction is ongoing
var open_timer := Timer.new()


func _init():
	add_child(open_timer)
	action_started = Signal(self, "action_started")


# Empty "virtual" functions to be overridden by inheritor

# Perform Player interaction with object
func interact(_variant):
	pass

# Unlock object without a key, usually takes longer
func pick_lock():
	pass


# Getter/setters for interacted instance var
func is_interacted():
	return interacted

func set_interacted(val:bool):
	interacted = val


# Triggered when Player moves out of interaction range, cancel any ongoing 
# interaction like unlocking or lockpicking
func cancel_interaction():
	if not open_timer.is_stopped():
		print("Cancelling interaction...")
		open_timer.stop()
