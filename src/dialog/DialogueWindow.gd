extends Control
class_name DialogueWindow

signal dialogue_ended

@onready var dialogue = $Dialogue
@onready var portrait = $Portrait
@onready var namelabel = $Nameplate/NameLabel

var curr_convo := []
var dialogue_count := 0
var dialogue_size := 0


func _ready():
	# Start invisible, only turn on when a dialogue file is loaded
	self.visible = false
	dialogue_ended = Signal(self, "dialogue_ended")


func _process(_delta):
	# Advance a line when player presses UI accept key/button
	if Input.is_action_just_pressed("ui_accept"):
		load_next_line()


# Loads a conversation from a given filepath
func initialize_conversation(path):
	
	#var f = File.new()
	var parser = JSON.new()
	
	# Pause game during dialogue
	get_tree().paused = true
	
	if FileAccess.file_exists(path):
		# Attempt to parse JSON contents of file
		var f = FileAccess.open(path, FileAccess.READ)
		var rval := parser.parse(f.get_as_text())
		if rval == OK:
			# Get file contents as a dictionary
			curr_convo = parser.get_data().get("lines")
			dialogue_size = curr_convo.size()
			load_next_line()
			self.visible = true
		else:
			print("Error parsing conversion file.\nMessage: %s" % parser.get_error_message())
			clear_dialogue_window()
	else:
		print("Error: File at given path does not exist!\nPath: %s" % path)
		clear_dialogue_window()


# Replaces the current dialogue, name, and portrait with the next one in the
# loaded conversation
func load_next_line():
	
	# If there are no more lines, just clear out the window
	if dialogue_count == dialogue_size:
		clear_dialogue_window()
	else:
		# Set the dialogue text and speaker's name
		var curr_line = curr_convo[dialogue_count]
		namelabel.text = curr_line.get("name")
		dialogue.text = curr_line.get("text")
		
		# Try to load the portrait file
		var portrait_path = curr_line.get("pic")
		portrait.texture = load(portrait_path)
#		if FileAccess.file_exists(portrait_path):
#			portrait.texture = load(portrait_path)
#		else:
			# If portrait path doesn't exist, default to Godot icon
#			print("Error: Image at given path does not exist!\nPath: %s" % portrait_path)
#			portrait.texture = load("res://icon.png")
		
		dialogue_count += 1


# Alert parent node that the dialogue has ended and clear the window from the
# player's view, reset vars
func clear_dialogue_window():
	get_tree().paused = false
	dialogue_ended.emit()
	self.visible = false
	
	curr_convo = []
	dialogue_count = 0
	dialogue_size = 0
