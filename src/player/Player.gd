extends CharacterBody3D
class_name Player

enum MOVE_STATE {
	STATE_STILL,
	STATE_SNEAK,
	STATE_DASH
}

const BASE_SPEED := 6
const DASH_SPEED := 9
const JUMP_SPEED := 7
const GRAV := 9.8

const CAM_ROT_SPEED := 2.50

signal interact_a
signal interact_b
var state : int = MOVE_STATE.STATE_STILL


func _init():
	interact_a = Signal(self, "interact_a")
	interact_b = Signal(self, "interact_b")

func _ready():
	_clear_prog_bar()

func _process(delta):
	
	# Update progress bar if it's visible
	if $ActionProgBarContainer.visible:
		$ActionProgBarContainer/ProgressBar.value += delta
		if $ActionProgBarContainer/ProgressBar.value >= $ActionProgBarContainer/ProgressBar.max_value:
			_clear_prog_bar()
	
	# Handle player interacting with objects
	if Input.is_action_just_pressed("interact_a"):
		interact_a.emit()
		print("Emitted interact_a signal")
	
	if Input.is_action_just_pressed("interact_b"):
		interact_b.emit()
		print("Emitted interact_b signal")
	
	# Handle camera rotations
	var rot_dir = Input.get_action_strength("cam_rot_ccw") - Input.get_action_strength("cam_rot_cw")
	$CameraTarget.rotation.y += rot_dir * delta * CAM_ROT_SPEED

func _physics_process(delta):
	
	# Determine horizontal movement direction and scale down to max of 1
	var dir = Vector3.ZERO
	dir += get_transform().basis.x.normalized() * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	dir += get_transform().basis.z.normalized() * (Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
	if dir.length_squared() > 1:
		dir = dir.normalized()
	
	# Scale movement based on sprinting
	dir *= DASH_SPEED if Input.is_action_pressed("sprint") else BASE_SPEED
	motion_velocity.x = dir.x
	motion_velocity.z = dir.z
	
	# Apply gravity
	motion_velocity.y -= delta * GRAV
	
	# Move character
	move_and_slide()

func _connect_body_interact_signal(body):
	if body is Interactable:
		interact_a.connect(body.interact)
		interact_b.connect(body.interact)
		body.action_started.connect(setup_prog_bar)
		print("Connected player's interact signal to object")

func _disconnect_player_interact_signal(body):
	# Disconnect signals and cancel any ongoing actions (unlocking, open, etc)
	if body is Interactable:
		body.cancel_interaction()
		body.action_started.disconnect(setup_prog_bar)
		interact_a.disconnect(body.interact)
		interact_b.disconnect(body.interact)
		print("Disconnected player's interact signal from object")
	_clear_prog_bar()

# Reset action progress bar
func _clear_prog_bar():
	$ActionProgBarContainer.visible = false
	$ActionProgBarContainer/ProgressBar.value = 0.0
	$ActionProgBarContainer/Label.text = ""

func setup_prog_bar(label, time):
	$ActionProgBarContainer.visible = true
	$ActionProgBarContainer/Label.text = label
	$ActionProgBarContainer/ProgressBar.value = 0.0
	$ActionProgBarContainer/ProgressBar.max_value = time
