extends Node3D
class_name Trap

# Time required to break free from trap without escape tool
@export var ESCAPE_TIME := 15.0
# Time required to break free with escape tool
@export var BREAK_TIME := 5.0
# Loudness of sound emitted when player is caught
@export var SOUND_MAGNITUDE := 20.0

var is_triggered := false
var occupant = null

@onready var timer = $Timer

signal action_started
signal emit_noise

func _ready():
	emit_noise = Signal(self, "emit_noise")


# Handle a character entering the trap area
func _on_body_entered(body):
	# Only catch the player and only if the trap is not already triggered
	if not is_triggered and body is Player:
		is_triggered = true
		occupant = body
		body.state = Player.MOVE_STATE.TRAPPED
		# Connect player signals to interact with trap object
		body.interact.connect(_on_player_escaping_trap)
		body.break_trap.connect(_on_player_breaking_trap)
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
		player.state = Player.MOVE_STATE.STILL
		occupant = null


# Called when a trapped player uses a "boltcutter" item to break free
func _on_player_breaking_trap(player):
	if timer.is_stopped():
		timer.start(BREAK_TIME)
		action_started.emit("Breaking free...", BREAK_TIME)
		await timer.timeout
		# After the timer finishes, free player and destroy this trap
		player.state = Player.MOVE_STATE.STILL
		player.inventory["boltcutters"] -= 1
		self.queue_free()


# Resets the trap to empty, ready state
func reset_trap():
	is_triggered = false
	occupant = null
	timer.stop()
