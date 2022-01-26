extends Interactable

func interact():
	print("Triggering interact function...")
	# Don't do anything if previous interaction is still resolving
	if not $AnimationPlayer.is_playing():
		if is_interacted():
			close()
		else:
			open()

func open():
	$AnimationPlayer.play("DoorAction002")
	set_interacted(true)

func close():
	$AnimationPlayer.play_backwards("DoorAction002")
	set_interacted(false)
