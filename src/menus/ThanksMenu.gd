extends Control


# Make sure player's mouse is usable here
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Open the itch.io page for this game when the button is pressed
func _on_itch_button_pressed():
	OS.shell_open("https://inglo-games.itch.io/den-of-thieves-demo")


# Return to main menu when button is pressed
func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/menus/MainMenu.tscn")
