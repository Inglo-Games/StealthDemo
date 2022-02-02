extends Interactable

func interact():
	print("Triggering interact function...")
	# Don't do anything if previous interaction is still resolving
	if not $AnimationPlayer.is_playing():
		if is_interacted():
			_close_box()
		else:
			_open_box()

func unlock():
	locked = false

func _open_box():
	# Only open if not locked and not already opening
	if not locked and open_timer.is_stopped():
		if open_time > 0:
			print("Starting open timer...")
			open_timer.start(open_time)
			await open_timer.timeout
		
		print("Opening safe!")
		set_interacted(true)
		$AnimationPlayer.play("DoorAction002")

func _close_box():
	set_interacted(false)
	$AnimationPlayer.play_backwards("DoorAction002")

