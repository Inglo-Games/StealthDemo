extends Interactable
class_name ItemBox

# List of items in this container
@export var items_contained := [""]
# List of keys/codes in this container
@export var keys_contained := [""]

# Name of animation in AnimationPlayer
const anim_name := "OpenAction"
# Length of time (in secs) the temp label is visible
const label_length := 3.0

@onready var temp_label = $TempLabel


func interact(player):
	print("Triggering interact function...")
	# Don't do anything if previous interaction is still resolving
	if not $AnimationPlayer.is_playing():
		if is_interacted():
			_close_box()
		else:
			_open_box(player)


func _open_box(player):
	# First check if box is locked
	if locked:
		if player.keyring.find(key_id) != -1:
			await _wait_for_timer(unlock_time, "Unlocking...")
			locked = false
			player.remove_key_id(key_id)
		else:
			temp_label.show_label_temp(label_length, "Locked!")
	
	# Only open if not locked and not already opening
	if not locked and open_timer.is_stopped():
		if open_time > 0:
			await _wait_for_timer(unlock_time, "Opening...")
		
		set_interacted(true)
		_give_items(player)
		$AnimationPlayer.play(anim_name)


func pick_lock(player):
	await _wait_for_timer(break_time, "Picking lock...")
	locked = false
	_open_box(player)
	player.inventory["lockpicks"] -= 1


# Empty the container and add contents to Player's inventory
func _give_items(player):
	
	# First handle the consumable items
	for item in items_contained:
		if player.inventory.has(item):
			player.inventory[item] += 1
		
	# Then handle keys/codes
	for key in keys_contained:
		player.give_key_id(key)
		
	# Alert player that they have received something, key takes precendence
	if keys_contained.size() != 0:
		temp_label.show_label_temp(label_length, "Key found!")
	elif items_contained.size() != 0:
		temp_label.show_label_temp(label_length, "item found!")
	
	# Clear those lists to prevent taking duplicate items
	items_contained = []
	keys_contained = []


func _wait_for_timer(time, label):
	open_timer.start(time)
	temp_label.show_label_temp(time, label)
	emit_signal("action_started", label, time)
	await open_timer.timeout
	open_timer.stop()


func _close_box():
	set_interacted(false)
	$AnimationPlayer.play_backwards(anim_name)
