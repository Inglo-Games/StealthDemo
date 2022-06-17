extends Control
class_name PauseMenu



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Tell the main game to resume and remove this scene
func _on_resume_button_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.queue_free()


# Quit the game
func _on_quit_button_pressed():
	get_tree().quit()
