extends Interactable
class_name LevelExit

const LABEL_TIME = 3.0
const LOCKED_LABEL = "Locked!"

@export var goto_scene : PackedScene = preload("res://src/menus/MainMenu.tscn")
@export var interact_anim : String = ""

@onready var exit_prompt = $ExitPromptPanel
@onready var temp_label = $TempLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Function triggers when the player presses the "interact" button near this item
func interact(player):
	# See if player has key if it's locked
	if locked:
		if player.keyring.find(key_id) != -1:
			locked = false
		# else, locked and player does not have a key
		else:
			temp_label.show_label_temp(LABEL_TIME, LOCKED_LABEL)
	
	if not locked:
		action_started.emit()
		# Show a prompt to confirm the player wants to exit
		exit_prompt.show_prompt(self)


# Triggered by "Yes" button on exit prompt
func transition_level():
	#anim_player.play(interact_anim)
	#await anim_player.animation_finished
	get_tree().change_scene_to(goto_scene)
