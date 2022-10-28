extends Control


var texture_bar
var timer


func _ready():
	
	texture_bar = $TextureProgressBar
	timer = $Timer
	
	visible = false


func _physics_process(delta):
	if not timer.paused:
		texture_bar.value += delta


# Setup the progress bar, show it, and set the timer
func setup_prog_bar(time: float):
	texture_bar.value = 0
	texture_bar.max_value = time
	visible = true
	timer.start(time)


# Hide the progress bar
func clear_prog_bar():
	visible = false


# Executes when timer hits 0 seconds
func _on_timer_timeout():
	clear_prog_bar()
