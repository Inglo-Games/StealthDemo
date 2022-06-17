extends Control

@onready var player = get_parent()


func _ready():
	_update_items()


func _input(event):
	# Close item menu if player presses Esc
	if event.is_action_pressed("ui_cancel"):
		hide_item_menu()


func show_item_menu():
	_update_items()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true


func hide_item_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false


func _update_items():
	# Disable buttons if player doesn't have any of the respective item
	$Panel/VBoxContainer/LockpickButton.disabled = (player.inventory["lockpicks"] <= 0)
	$Panel/VBoxContainer/NoiseButton.disabled = (player.inventory["noisemakers"] <= 0)
	$Panel/VBoxContainer/CutterButton.disabled = (player.inventory["boltcutters"] <= 0)


func _on_lockpick_button_pressed():
	player.pick_lock.emit(player)
	hide_item_menu()


func _on_noise_button_pressed():
	hide_item_menu()


func _on_cutter_button_pressed():
	player.break_trap.emit(player)
	hide_item_menu()
