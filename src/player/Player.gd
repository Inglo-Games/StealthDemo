extends CharacterBody3D
class_name Player

enum MOVE_STATE {
	STILL,
	SNEAKING,
	DASHING,
	HIDING,
	TRAPPED
}

const BASE_SPEED := 6
const DASH_SPEED := 9
const JUMP_SPEED := 7
const CAM_SENSITIVITY := 0.005
const CAM_ZOOM_INNER_LIMIT := 5.0
const CAM_ZOOM_OUTER_LIMIT := 20.0
const NOISE_MAGNITUDE := 25

@onready var camera = $CameraTarget

signal emit_noise
signal interact
signal pick_lock
signal place_noisemaker
signal break_trap

var state : int = MOVE_STATE.STILL
var inventory : Dictionary = {
	"lockpicks": 0,
	"noisemakers": 0,
	"boltcutters": 0
}
var keyring := []


func _init():
	emit_noise = Signal(self, "emit_noise")
	interact = Signal(self, "interact")
	pick_lock = Signal(self, "pick_lock")
	break_trap = Signal(self, "break_trap")
	place_noisemaker = Signal(self, "place_noisemaker")


func _ready():
	_clear_prog_bar()
	$ItemMenu.visible = false


func _process(delta):
	
	# Update progress bar if it's visible
	if $ActionProgBarContainer.visible:
		$ActionProgBarContainer/ProgressBar.value += delta
		if $ActionProgBarContainer/ProgressBar.value >= $ActionProgBarContainer/ProgressBar.max_value:
			_clear_prog_bar()


func _input(event):
	
	# Handle player interacting with objects
	if event.is_action_pressed("interact_a"):
		print("Emitting interact signal...")
		interact.emit(self)
	
	# Handle emitting noise
	if event.is_action_pressed("make_noise"):
		print("Emitting noise signal...")
		emit_noise.emit(position, NOISE_MAGNITUDE)
		
	# Handle showing items menu
	if event.is_action_pressed("use_item"):
		$ItemMenu.show_item_menu()
	
	# Only do camera movements if not paused or item is not opened
	if not $ItemMenu.visible:
		if event is InputEventMouseButton:
			# Mouse scroll wheel zooms camera in and out
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_move_camera(true)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_move_camera(false)
		elif event is InputEventMouseMotion:
			# Mouse motion rotates camera
			# If moving, rotate player; otherwise only rotate camera
			if velocity != Vector3.ZERO:
				self.rotation.y -= event.relative.x * CAM_SENSITIVITY
			else:
				camera.rotation.y -= event.relative.x * CAM_SENSITIVITY
	
	# If moving and camera rotation is non-zero, correct player rotation
	if camera.rotation.y != 0 and \
				(Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or \
				Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		self.rotation.y += camera.rotation.y
		camera.rotation.y = 0


func _physics_process(delta):
	
	# Determine horizontal movement direction and scale down to max of 1
	var dir = Vector3.ZERO
	
	# Only move if player is allowed to
	if state != MOVE_STATE.TRAPPED and state != MOVE_STATE.HIDING:
		# Determine movement direction
		dir += transform.basis.x.normalized() * Input.get_axis("move_right", "move_left")
		dir += transform.basis.z.normalized() * Input.get_axis("move_back", "move_forward")
		if dir.length_squared() > 1:
			dir = dir.normalized()
	
		# Scale movement based on sprinting
		dir *= DASH_SPEED if Input.is_action_pressed("sprint") else BASE_SPEED
		velocity.x = dir.x
		velocity.z = dir.z
	
		# Move character
		move_and_slide()


# Function to shift the camera toward player or away from player
func _move_camera(move_in : bool):
	var cam = $CameraTarget/Camera3D
	
	if move_in and cam.position.y > CAM_ZOOM_INNER_LIMIT:
		cam.position.y -= 1.0
	elif not move_in and cam.position.y < CAM_ZOOM_OUTER_LIMIT:
		cam.position.y += 1.0
		
	cam.position.z = -cam.position.y


func _connect_body_interact_signal(body):
	if body is Interactable:
		interact.connect(body.interact)
		pick_lock.connect(body.pick_lock)
		body.action_started.connect(setup_prog_bar)
		print("Connected player's interact signal to object")


func _disconnect_player_interact_signal(body):
	# Disconnect signals and cancel any ongoing actions (unlocking, open, etc)
	if body is Interactable:
		body.cancel_interaction()
		body.action_started.disconnect(setup_prog_bar)
		interact.disconnect(body.interact)
		pick_lock.disconnect(body.pick_lock)
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


# Add a given key ID to the player keyring, avoiding duplicates
func give_key_id(id):
	if not keyring.has(id):
		keyring.push_back(id)


func hide_player():
	visible = false
	state = MOVE_STATE.HIDING
	$CollisionShape3D.disabled = true


func unhide_player():
	visible = true
	state = MOVE_STATE.STILL
	$CollisionShape3D.disabled = false
