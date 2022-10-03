extends Interactable
class_name Lamp


# Called when the node enters the scene tree for the first time.
func _ready():
	# Lamps aren't locked or have complicated mechanisms
	self.unlock_time = 0
	self.open_time = 0


# Turn the lamp off or on, opposite of current state
func interact(player):
	
	var curr = not is_interacted()
	$OmniLight3D.visible = curr
	set_interacted(curr)
