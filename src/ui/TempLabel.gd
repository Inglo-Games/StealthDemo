extends Node3D

@onready var label = $Label3D
@onready var timer = $Timer


func _ready():
	label.visible = false
	timer.timeout.connect(_clear_temp_label)


# Show the temp label for an object for the given time with given message text
func show_label_temp(time:int, text:String):
	timer.start(time)
	label.text = text
	label.visible = true


# Make label invisible
func _clear_temp_label():
	label.visible = false
