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

# Temp label to show status like "Locked" or "Opening"
@onready var temp_label = $TempLabel


# Handle Player interaction, open or close object depending on state
func interact(_variant):
	print("Triggering interact function...")
	# Don't do anything if previous interaction is still resolving
	if not $AnimationPlayer.is_playing():
		if is_interacted():
			_close_box()
		else:
			_open_box()


# Handle opening the box if it's unlocked
func _open_box():
	
	# First check if box is locked
	if locked:
		# If player has the correct key, unlock and remove key from inventory
		if PlayerInventory.keyring.find(key_id) != -1:
			await _wait_for_timer(unlock_time, "Unlocking...")
			audio_player.stream = unlock_sound
			audio_player.play()
			locked = false
			PlayerInventory.remove_key_id(key_id)
		else:
			temp_label.show_label_temp(label_length, "Locked!")
			action_started.emit()
	
	# Only open if not locked and not already opening
	if not locked and open_timer.is_stopped():
		if open_time > 0:
			await _wait_for_timer(unlock_time, "Opening...")
		else:
			action_started.emit()
		
		if open_sound != null:
			audio_player.stream = open_sound
			audio_player.play()
		
		set_interacted(true)
		# Give player the box's contents and play opening animation
		_give_items()
		$AnimationPlayer.play(anim_name)
		await $AnimationPlayer.animation_finished
		action_finished.emit()


# Pick object's lock if possible
func pick_lock():
	# Only allow picking if break_time is positive
	if break_time >= 0:
		audio_player.stream = lockpick_sound
		audio_player.play()
		await _wait_for_timer(break_time, "Picking lock...")
		locked = false
		audio_player.stop()
		_open_box()
		PlayerInventory.remove_item("lockpick")
	else:
		temp_label.show_label_temp(label_length, "Can't pick!")


# Empty the container and add contents to Player's inventory
func _give_items():
	
	# First handle the consumable items
	for item in items_contained:
		if PlayerInventory.inventory.has(item):
			PlayerInventory.give_items(item, 1)
		
	# Then handle keys/codes
	for key in keys_contained:
		PlayerInventory.give_key_id(key)
		
	# Alert player that they have received something, key takes precendence
	if keys_contained.size() != 0:
		temp_label.show_label_temp(label_length, "Key found!")
	elif items_contained.size() != 0:
		temp_label.show_label_temp(label_length, "item found!")
	
	# Clear those lists to prevent taking duplicate items
	items_contained = []
	keys_contained = []


# Start timer for the action being performed and only return when timer finishes
func _wait_for_timer(time, label):
	open_timer.start(time)
	temp_label.show_label_temp(time, label)
	action_started.emit(label, time)
	await open_timer.timeout
	open_timer.stop()


# Handle closing the box and setting interacted var to false
func _close_box():
	
	action_started.emit("Closing...", 3)
	
	if close_sound != null:
		audio_player.stream = close_sound
		audio_player.play()
	set_interacted(false)
	$AnimationPlayer.play_backwards(anim_name)
	await $AnimationPlayer.animation_finished
	action_finished.emit()
