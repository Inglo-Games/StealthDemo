extends PanelContainer

var level_exit_object : LevelExit


func _ready():
	# Start invisible
	self.visible = false


# Pause the game and make this prompt visible
func show_prompt(levelexit):
	get_tree().paused = true
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Save a reference to the LevelExit object so we can call back later
	level_exit_object = levelexit


# Triggered by player pressing "YES"
func _on_confirm_button_pressed():
	self.visible = false
	get_tree().paused = false
	level_exit_object.transition_level()


# Triggered by player pressing "NO", clear modal and resume game
func _on_cancel_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	get_tree().paused = false
