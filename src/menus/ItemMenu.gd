extends Control

@onready var player = get_parent()


func _ready():
	update_items()


func _process(_delta):
	# Close item menu if player presses Esc
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false


func update_items():
	# Disable buttons if player doesn't have any of the respective item
	$Panel/VBoxContainer/LockpickButton.disabled = (player.inventory["lockpicks"] <= 0)
	$Panel/VBoxContainer/NoiseButton.disabled = (player.inventory["noisemakers"] <= 0)
	$Panel/VBoxContainer/CutterButton.disabled = (player.inventory["boltcutters"] <= 0)


func _on_lockpick_button_pressed():
	player.pick_lock.emit(player)
	visible = false


func _on_noise_button_pressed():
	pass # Replace with function body.


func _on_cutter_button_pressed():
	player.break_trap.emit(player)
	visible = false
