extends Control


# Labels that display the number of each item the player has
@onready var pick_count_label = $VBoxContainer/HFlowContainer/LockpickCount
@onready var bolt_count_label = $VBoxContainer/HFlowContainer2/BoltCount
@onready var noise_count_label = $VBoxContainer/HFlowContainer3/NoiseCount


func _ready():
	PlayerInventory.change_items.connect(_update_count_labels)


# Update each count label to show the current amount the player has
func _update_count_labels():
	pick_count_label.text = "x%d" % PlayerInventory.inventory["lockpick"]
	bolt_count_label.text = "x%d" % PlayerInventory.inventory["boltcutter"]
	noise_count_label.text = "x%d" % PlayerInventory.inventory["noisemaker"]
