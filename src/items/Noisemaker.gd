extends StaticBody3D
class_name NoiseMaker

@export var time = 5
@export var sound_strength = 25

@onready var timer = $Timer
@onready var label = $Label3D

signal emit_noise


func _ready():
	emit_noise = Signal(self, "emit_noise")
	timer.timeout.connect(_emit_sound)
	
	# Immediately start countdown
	timer.start(time)


func _process(_delta):
	# Update time remaining on countdown timer
	label.text = "%.1f" % timer.time_left


func _emit_sound():
	emit_noise.emit(position, sound_strength)
	print("Noisemaker emitted!")
	queue_free()
