extends Control
class_name PauseMenu


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Panel/VBoxContainer/VolSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))


# Tell the main game to resume and remove this scene
func _on_resume_button_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.queue_free()


# Apply audio changes to master bus
func _on_vol_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


# Quit the game
func _on_quit_button_pressed():
	get_tree().quit()
