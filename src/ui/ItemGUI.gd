extends Control


# Labels that display the number of each item the player has
@onready var pick_count_label = $VBoxContainer/HFlowContainer/LockpickCount
@onready var bolt_count_label = $VBoxContainer/HFlowContainer2/BoltCount
@onready var noise_count_label = $VBoxContainer/HFlowContainer3/NoiseCount

# This GUI should only be an immediate child of the Player object
@onready var player = self.get_parent()


func _process(_delta):
	# TODO: Change this to a signal to reduce useless calls
	_update_count_labels()


# Update each count label to show the current amount the player has
func _update_count_labels():
	pick_count_label.text = "%d" % player.inventory["lockpicks"]
	bolt_count_label.text = "%d" % player.inventory["boltcutters"]
	noise_count_label.text = "%d" % player.inventory["noisemakers"]
