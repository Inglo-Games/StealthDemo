extends Interactable
class_name HidingPlace

var is_occupied = false

func interact(player):
	print("Triggering wardrobe interact function...")
	if not $AnimationPlayer.is_playing():
		if is_occupied:
			_exit_hiding_spot(player)
		else:
			_enter_hiding_spot(player)

func _enter_hiding_spot(player):
	open_timer.start(open_time * 2.0)
	emit_signal("action_started", "Hiding...", open_time * 2.0)
	await _open_spot()
	player.hide_player()
	await _close_spot()

func _exit_hiding_spot(player):
	open_timer.start(open_time * 2.0)
	emit_signal("action_started", "Exiting...", open_time * 2.0)
	await _open_spot()
	player.unhide_player()
	await _close_spot()

func _open_spot():
	set_interacted(true)
	$AnimationPlayer.play("RDoorAction")
	$AnimationPlayer.play("LDoorAction")
	await $AnimationPlayer.animation_finished

func _close_spot():
	$AnimationPlayer.play_backwards("RDoorAction")
	$AnimationPlayer.play_backwards("LDoorAction")
	await $AnimationPlayer.animation_finished
	set_interacted(false)
