extends Node

# Audio file to play
var audio_stream = preload("res://assets/bgm/StepLight.mp3")

var audio_player = AudioStreamPlayer.new()


func _ready():
	
	# Set up the audio stream player and add it to scene tree
	audio_player.stream = audio_stream
	audio_player.autoplay = true
	add_child(audio_player)
	
	# Force player to continue when game is otherwise paused
	process_mode = Node.PROCESS_MODE_ALWAYS
