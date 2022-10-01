extends Node3D
class_name Trap

# Time required to break free from trap without escape tool
@export var ESCAPE_TIME := 8.0

# Time required to break free with escape tool
@export var BREAK_TIME := 3.0

# Loudness of sound emitted when player is caught
@export var SOUND_MAGNITUDE := 20.0

# Whether player has been caught already, prevents getting caught multiple times
# by the same trap
var is_triggered := false

# Current occupant of the trap, points to Player when Player is caught
var occupant = null

@onready var timer = $Timer
@onready var anims = $AnimationPlayer

signal action_started
signal emit_noise
signal player_escaped

func _ready():
	emit_noise = Signal(self, "emit_noise")
	player_escaped = Signal(self, "player_escaped")


# Handle a character entering the trap area
func _on_body_entered(body):
	# Only catch the player and only if the trap is not already triggered
	if not is_triggered:
		is_triggered = true
		occupant = body
		body.enter_state_trapped()
		anims.play("SnareTriggered")
		body.get_node("AnimationPlayer").play("NewAnims/Snare")
		# Connect player signals to interact with trap object
		body.interact.connect(_on_player_escaping_trap)
		self.action_started.connect(body.setup_prog_bar)
		# Emit noise to alert guards
		emit_noise.emit(global_transform.origin, SOUND_MAGNITUDE)


# Called when a trapped player emits the "interact" signal
func _on_player_escaping_trap(player):
	if timer.is_stopped():
		timer.start(ESCAPE_TIME)
		action_started.emit("Escaping...", ESCAPE_TIME)
		await timer.timeout
		# After the timer finishes, free the player
		player.get_node("AnimationPlayer").play("NewAnims/Release")
		await player.get_node("AnimationPlayer").animation_finished
		player._enter_state_still()
		occupant = null
		player_escaped.emit()


# Called when a trapped player uses a "boltcutter" item to break free
func _on_player_breaking_trap(player):
	timer.start(ESCAPE_TIME)
	action_started.emit("Escaping...", ESCAPE_TIME)
	await timer.timeout
	# After the timer finishes, free player and destroy this trap
	player.get_node("AnimationPlayer").play("NewAnims/Release")
	await player.get_node("AnimationPlayer").animation_finished
	player._enter_state_still()
	PlayerInventory.remove_item("boltcutter")
	self.queue_free()
	player_escaped.emit()


# Called when player uses boltcutters *before* being caught
func clear_trap(_player):
	PlayerInventory.remove_item("boltcutter")
	self.queue_free()


# Resets the trap to empty, ready state
func reset_trap():
	is_triggered = false
	occupant = null
	timer.stop()
