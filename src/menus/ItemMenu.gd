extends Control


const DIST_ITEM_PLACEMENT := Vector3(0, 0, 10)
const NOISEMAKER_VOLUME := 50.0

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
	$PickButton.disabled = (PlayerInventory.inventory["lockpick"] <= 0)
	$NoiseButton.disabled = (PlayerInventory.inventory["noisemaker"] <= 0)
	$CutterButton.disabled = (PlayerInventory.inventory["boltcutter"] <= 0)


func _on_lockpick_button_pressed():
	player.pick_lock.emit()
	hide_item_menu()


func _on_noise_button_pressed():
	# Determine location of new noisemaker, a constant distance in front of
	# player's current location, rotated to match player's current direction
	var pos : Vector3 = player.global_transform.origin + \
				DIST_ITEM_PLACEMENT * player.rotation
	player.place_noisemaker.emit(pos, NOISEMAKER_VOLUME)
	PlayerInventory.remove_item("noisemaker")
	hide_item_menu()


func _on_cutter_button_pressed():
	player.break_trap.emit(player)
	hide_item_menu()
