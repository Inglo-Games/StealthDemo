extends Node

# Audio files to play
var audio_menu = preload("res://assets/bgm/StepLight.mp3")
var audio_norm = preload("res://assets/bgm/StepLight.mp3")
var audio_sus = preload("res://assets/bgm/StepLight_sus.mp3")
var audio_alert = preload("res://assets/bgm/StepLight_alert.mp3")

var audio_player = AudioStreamPlayer.new()

# Keep track of the number of guards that are suspicious and alerted
var guards_sus := 0
var guards_alert := 0


func _ready():
	
	# Set up the audio stream player and add it to scene tree
	audio_player.stream = audio_menu
	audio_player.bus = "BGM"
	audio_player.autoplay = true
	add_child(audio_player)
	
	# Force player to continue when game is otherwise paused
	process_mode = Node.PROCESS_MODE_ALWAYS


# Change audio stream without changing the playback position
func change_music_to(stream):
	var current_pos = audio_player.get_playback_position()
	audio_player.stream = stream
	audio_player.play(current_pos)


# Increment the suspicious guard counter and adjust music if appropriate
func add_guard_sus():
	guards_sus += 1
	if guards_alert == 0 and audio_player.stream != audio_sus:
		change_music_to(audio_sus)


# Increment the alerted guard counter and adjust music if appropriate
func add_guard_alert():
	guards_alert += 1
	if audio_player.stream != audio_alert:
		change_music_to(audio_alert)


# Decrement suspicious guard counter and return to normal music if appropriate
func sub_guard_sus():
	guards_sus -= 1
	if guards_sus == 0 and guards_alert == 0:
		change_music_to(audio_norm)


# Decrement alerted guard counter and change music if appropriate
func sub_guard_alert():
	guards_alert -= 1
	if guards_alert == 0:
		if guards_sus == 0:
			change_music_to(audio_norm)
		else:
			change_music_to(audio_sus)


# Reset counters and return to normal music
func reset_counts():
	guards_sus = 0
	guards_alert = 0
	change_music_to(audio_norm)
	
