extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_items()


func _input(event):
	# Close item menu if player presses Esc
	if event.is_action_pressed("ui_cancel"):
		hide_menu()


# Show the inventory menu and pause the game
func show_inv_menu():
	_update_items()
	visible = true


# Hide this menu and unpause the game
func hide_menu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false


# Update the lists of items and keys from PlayerInventory
func _update_items():
	
	# Update items from PlayerInventory
	$Panel/GridContainer/RVBox/PickLabel.text = "Lockpicks: %d" % PlayerInventory.inventory["lockpick"]
	$Panel/GridContainer/RVBox/CutterLabel.text = "Boltcutters: %d" % PlayerInventory.inventory["boltcutter"]
	$Panel/GridContainer/RVBox/NoiseLabel.text = "Noisemakers: %d" % PlayerInventory.inventory["noisemaker"]
	
	# Clear existing list of keys
	var keys_box = $Panel/GridContainer/LVBox/KeysBox
	for label in keys_box.get_children():
		label.visible = false
		label.queue_free()
	
	# Either display "[None]" or populate key list
	if PlayerInventory.keyring.is_empty():
		$Panel/GridContainer/LVBox/KeyNoneLabel.visible = true
	else:
		$Panel/GridContainer/LVBox/KeyNoneLabel.visible = false
		for key_name in PlayerInventory.keyring:
			var new_label = Label.new()
			new_label.text = key_name
			new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			keys_box.add_child(new_label)
