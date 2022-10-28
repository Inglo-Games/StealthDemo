extends StaticBody3D
class_name NoiseMaker

@export var time = 5
@export var sound_strength = 25

@onready var timer = $Timer
@onready var label = $Label3D

signal emit_noise


func _ready():
	emit_noise = Signal(self, "emit_noise")
	timer.timeout.connect(_on_noisemaker_explode)
	
	# Immediately start countdown
	timer.start(time)


func _process(_delta):
	# Update time remaining on countdown timer
	label.text = "%.1f" % timer.time_left


# Define behavior when the noisemaker object explodes
func _on_noisemaker_explode():
	# Emit a noise to alert guards
	emit_noise.emit(position, sound_strength)
	
	# Emit smoke particles, stop spark particles, make noisemaker invisible
	$SmokeParticles.emitting = true
	$SparkParticles.emitting = false
	$MeshInstance3D.visible = false
	$Label3D.visible = false
	
	# Wait for smoke to finish then remove
	await get_tree().create_timer(8.0).timeout
	queue_free()
