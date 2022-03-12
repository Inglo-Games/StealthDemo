extends Control
class_name PauseMenu


# Tell the main game to resume and remove this scene
func _on_resume_button_pressed():
	get_tree().paused = false
	self.queue_free()


# Quit the game
func _on_quit_button_pressed():
	get_tree().quit()
