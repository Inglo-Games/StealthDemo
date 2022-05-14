extends Interactable

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
			_display_message("Locked!")
	
	# Only open if not locked and not already opening
	if not locked and open_timer.is_stopped():
		if open_time > 0:
			await _wait_for_timer(unlock_time, "Opening...")
		
		print("Opening safe!")
		set_interacted(true)
		$AnimationPlayer.play("DoorAction002")


func _wait_for_timer(time, label):
	open_timer.start(time)
	emit_signal("action_started", label, time)
	await open_timer.timeout


func _close_box():
	set_interacted(false)
	$AnimationPlayer.play_backwards("DoorAction002")


# TODO: convert to UI message
func _display_message(label):
	print(label)
