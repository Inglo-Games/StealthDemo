extends CharacterBody3D
class_name Player

enum MOVE_STATE {
	STILL,
	SNEAKING,
	DASHING,
	HIDING
}

const BASE_SPEED := 6
const DASH_SPEED := 9
const JUMP_SPEED := 7
const CAM_ROT_SPEED := 2.50

@onready var camera = $CameraTarget

signal interact

var state : int = MOVE_STATE.STILL
var keyring := ["safe01_test_key"]


func _init():
	interact = Signal(self, "interact")


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
		print("Emitting interact signal...")
		interact.emit(self)


func _physics_process(delta):
	
	# Determine horizontal movement direction and scale down to max of 1
	var dir = Vector3.ZERO
	
	# Handle camera rotations
	var rot_dir = Input.get_action_strength("cam_rot_ccw") - Input.get_action_strength("cam_rot_cw")
	if rot_dir != 0:
		var rot_delta = rot_dir * delta * CAM_ROT_SPEED
		# If moving, rotate player; otherwise only rotate camera
		if velocity != Vector3.ZERO:
			self.rotation.y += rot_delta
		else:
			camera.rotation.y += rot_delta
	
	# If moving and camera rotation is non-zero, correct player rotation
	if camera.rotation.y != 0 and \
				(Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or \
				Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		self.rotation.y += camera.rotation.y
		camera.rotation.y = 0
	
	# Determine movement direction
	dir += transform.basis.x.normalized() * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	dir += transform.basis.z.normalized() * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"))
	if dir.length_squared() > 1:
		dir = dir.normalized()
	
	# Scale movement based on sprinting
	dir *= DASH_SPEED if Input.is_action_pressed("sprint") else BASE_SPEED
	velocity.x = dir.x
	velocity.z = dir.z
	
	# Move character
	move_and_slide()


func _connect_body_interact_signal(body):
	if body is Interactable:
		interact.connect(body.interact)
		body.action_started.connect(setup_prog_bar)
		print("Connected player's interact signal to object")


func _disconnect_player_interact_signal(body):
	# Disconnect signals and cancel any ongoing actions (unlocking, open, etc)
	if body is Interactable:
		body.cancel_interaction()
		body.action_started.disconnect(setup_prog_bar)
		interact.disconnect(body.interact)
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


# Remove a given key ID from player keyring, if it exists
func remove_key_id(id):
	var index = keyring.find(id)
	if index != -1:
		keyring.remove_at(index)


func hide_player():
	visible = false
	state = MOVE_STATE.HIDING


func unhide_player():
	visible = true
	state = MOVE_STATE.STILL
