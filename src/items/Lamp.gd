extends Interactable
class_name Lamp


const on_sound = preload("res://assets/sfx/lamp_on.wav")
const off_sound = preload("res://assets/sfx/lamp_off.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Lamps aren't locked or have complicated mechanisms
	self.unlock_time = 0
	self.open_time = 0


# Turn the lamp off or on, opposite of current state
func interact(player):
	
	if is_interacted():
		$AudioStreamPlayer3D.stream = off_sound
	else:
		$AudioStreamPlayer3D.stream = on_sound
	
	var curr = not is_interacted()
	$OmniLight3D.visible = curr
	$AudioStreamPlayer3D.play()
	set_interacted(curr)
