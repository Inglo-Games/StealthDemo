extends Interactable
class_name HidingPlace

# Tracks if this HidingPlace currently has Player inside it
var is_occupied := false


func _ready():
	# Audio tracks for opening and closing
	open_sound = load("res://assets/sfx/wardrobe_open.wav")
	close_sound = preload("res://assets/sfx/wardrobe_close.wav")


# Override Interactable interact, handles Player interaction
func interact(player):
	print("Triggering wardrobe interact function...")
	if not $AnimationPlayer.is_playing():
		if is_occupied:
			_exit_hiding_spot(player)
		else:
			_enter_hiding_spot(player)


# Handle Player entering the HidingPlace
func _enter_hiding_spot(player):
	open_timer.start(open_time * 2.0)
	action_started.emit(open_time * 2.0)
	# Set player state to trapped so enemies can still detect them but player
	# can't move away and lock themselves in a wardrobe
	player.state = player.MOVE_STATE.TRAPPED
	await _open_spot()
	player.hide_player()
	is_occupied = true
	await _close_spot()

# Handle Player leavign the HidingPlace
func _exit_hiding_spot(player):
	open_timer.start(open_time * 2.0)
	action_started.emit(open_time * 2.0)
	await _open_spot()
	player.unhide_player()
	is_occupied = false
	await _close_spot()


# Play door-opening animation and set interacted instance var 
func _open_spot():
	audio_player.stream = open_sound
	audio_player.play()
	set_interacted(true)
	$AnimationPlayer.play("OpenAction")
	await $AnimationPlayer.animation_finished

# Play door closing and set interacted instance var
func _close_spot():
	audio_player.stream = close_sound
	audio_player.play()
	$AnimationPlayer.play_backwards("OpenAction")
	await $AnimationPlayer.animation_finished
	set_interacted(false)
