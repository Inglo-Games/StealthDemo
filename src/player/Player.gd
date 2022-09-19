extends CharacterBody3D
class_name Player

enum MOVE_STATE {
	STILL,
	SNEAKING,
	DASHING,
	HIDING,
	TRAPPED
}

# Speed of non-running movement
const BASE_SPEED := 6

# Speed of running movement
const DASH_SPEED := 9

# Player speed at which the player is considered "dashing"
const RUN_SPEED_THRESHOLD := 40.0

# Sensitivity for camera rotation
const CAM_SENSITIVITY_MOUSE := 0.005
const CAM_SENSITIVITY_KEYS := 0.02

# Min and max allowed distances for Player's camera
const CAM_ZOOM_INNER_LIMIT := 5.0
const CAM_ZOOM_OUTER_LIMIT := 20.0

# Limit for footstep_timer when it emits a noise and resets
const STEP_TIMER_LIMIT := 250

# Constant to scale player's velocity to use for "emit_noise" magnitude
const STEP_MAGNITUDE_SCALE := 0.2

# Node to hold Camera object, used for rotating camera independently of Player
@onready var camera = $CameraTarget

# Animations for the player model
@onready var anims = $AnimationPlayer

signal emit_noise
signal interact
signal pick_lock
signal place_noisemaker
signal break_trap

# Movement state
var state : int = MOVE_STATE.STILL

# "timer" to track how often a footstep noise is emitted, fills based on movement speed
var footstep_timer := 0


func _init():
	emit_noise = Signal(self, "emit_noise")
	interact = Signal(self, "interact")
	pick_lock = Signal(self, "pick_lock")
	break_trap = Signal(self, "break_trap")
	place_noisemaker = Signal(self, "place_noisemaker")


func _ready():
	# Initially hide all menus and progress bar
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
		
	# Handle showing/hiding items menu
	if event.is_action_pressed("use_item"):
		if $ItemMenu.visible:
			$ItemMenu.visible = false
		else:
			$ItemMenu.show_item_menu()
	
	# Handle camera direction via mouse motion
	if not $ItemMenu.visible:
		
		if event is InputEventMouseMotion:
			# If moving, rotate player; otherwise only rotate camera
			if velocity != Vector3.ZERO:
				self.rotation.y -= event.relative.x * CAM_SENSITIVITY_MOUSE
			else:
				camera.rotation.y -= event.relative.x * CAM_SENSITIVITY_MOUSE


func _physics_process(_delta):
	
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
		
		# Add to footstep "timer" based on current velocity and check if ready to emit noise
		_update_step_timer(dir)
		
		# Update state
		if dir.length_squared() == 0:
			_enter_state_still()
		elif dir.length_squared() <= RUN_SPEED_THRESHOLD:
			_enter_state_sneaking()
		else:
			_enter_state_dashing()
		
		# Move character
		move_and_slide()
	
	# Only do camera movements if not paused or item is not opened
	if not $ItemMenu.visible:
		
		# Camera zoom
		if Input.is_action_pressed("cam_zoom_in") or Input.is_action_pressed("cam_zoom_out"):
			_move_camera(Input.get_axis("cam_zoom_in", "cam_zoom_out"))
		
		# Camera directiom (joystick and keys)
		if Input.is_action_pressed("cam_left") or Input.is_action_pressed("cam_right"):
			# If moving, rotate player; otherwise only rotate camera
			if velocity != Vector3.ZERO:
				self.rotation.y -= Input.get_axis("cam_left", "cam_right") * CAM_SENSITIVITY_KEYS
			else:
				camera.rotation.y -= Input.get_axis("cam_left", "cam_right") * CAM_SENSITIVITY_KEYS
	
	# If moving and camera rotation is non-zero, correct player rotation
	if camera.rotation.y != 0 and \
				(Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or \
				Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		self.rotation.y += camera.rotation.y
		camera.rotation.y = 0


# Update the footstep "timer" and emit a noise when it reaches a threshold, clear it if not moving
func _update_step_timer(dir : Vector3):
	
	footstep_timer += dir.length()
	
	if footstep_timer >= STEP_TIMER_LIMIT:
		footstep_timer = 0
		var magnit = dir.length_squared() * STEP_MAGNITUDE_SCALE
		print("Emitting step noise with magnitude %d" % magnit)
		emit_noise.emit(position, magnit)
	
	# If not moving, reset footstep "timer" to 0
	if dir.length() <= 0:
		footstep_timer = 0


# Function to shift the camera toward player or away from player
func _move_camera(magnitude : float):
	var cam = $CameraTarget/Camera3D
	cam.position.y = clampf(cam.position.y + magnitude, CAM_ZOOM_INNER_LIMIT, CAM_ZOOM_OUTER_LIMIT)
	cam.position.z = -cam.position.y


# Connect the interact and lock picking signals to interactable if one enter's
# Player InteractArea
func _connect_body_interact_signal(body):
	if body is Interactable:
		interact.connect(body.interact)
		pick_lock.connect(body.pick_lock)
		body.action_started.connect(setup_prog_bar)
		print("Connected player's interact signal to object")


# Disconnect signals and cancel any ongoing actions (unlocking, open, etc)
func _disconnect_player_interact_signal(body):
	if body is Interactable:
		body.cancel_interaction()
		body.action_started.disconnect(setup_prog_bar)
		interact.disconnect(body.interact)
		pick_lock.disconnect(body.pick_lock)
		print("Disconnected player's interact signal from object")
	_clear_prog_bar()


# Transition to STILL state, if appropriate
func _enter_state_still():
	state = MOVE_STATE.STILL
	if anims.current_animation != "Idle":
		anims.play("Idle")


# Transition to SNEAKING state
func _enter_state_sneaking():
	state = MOVE_STATE.SNEAKING
	if anims.current_animation != "Walk":
		anims.play("Walk")


# Transition to DASHING state
func _enter_state_dashing():
	state = MOVE_STATE.DASHING
	if anims.current_animation != "Gallop":
		anims.play("Gallop")


# Reset action progress bar
func _clear_prog_bar():
	$ActionProgBarContainer.visible = false
	$ActionProgBarContainer/ProgressBar.value = 0.0
	$ActionProgBarContainer/Label.text = ""


# Setup debugging progress bar to show action's time to completion
func setup_prog_bar(label, time):
	$ActionProgBarContainer.visible = true
	$ActionProgBarContainer/Label.text = label
	$ActionProgBarContainer/ProgressBar.value = 0.0
	$ActionProgBarContainer/ProgressBar.max_value = time


# Make player invisible and uncollidable upon entering a HidingPlace
func hide_player():
	visible = false
	state = MOVE_STATE.HIDING
	$CollisionShape3D.disabled = true


# Make player visible/collidable when exiting a HidingPlace
func unhide_player():
	visible = true
	state = MOVE_STATE.STILL
	$CollisionShape3D.disabled = false
