extends Control

# Return to main menu when BACK button is pressed
func _on_back_button_pressed():
	get_tree().change_scene_to(load("res://src/menus/MainMenu.tscn"))