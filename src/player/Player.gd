extends CharacterBody3D

enum MOVE_STATE {
	STATE_STILL,
	STATE_SNEAK,
	STATE_DASH
}

const BASE_SPEED : int = 6
const DASH_SPEED : int = 9
const JUMP_SPEED : int = 7
const GRAV : float = 9.8

var state : int = MOVE_STATE.STATE_STILL

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	
	# Determine horizontal movement direction and scale down to max of 1
	var dir = Vector3()
	dir.x = Input.get_action_strength("move_e") - Input.get_action_strength("move_w")
	dir.z = Input.get_action_strength("move_s") - Input.get_action_strength("move_n")
	dir = dir.normalized()
	
	# Scale movement based on sprinting
	dir *= DASH_SPEED if Input.is_action_pressed("sprint") else BASE_SPEED
	motion_velocity.x = dir.x
	motion_velocity.z = dir.z

	# Apply gravity
	motion_velocity.y -= delta * GRAV

	# Move character
	move_and_slide()
	
	# Jumping code
	if is_on_floor() and Input.is_action_pressed("jump"):
		motion_velocity.y = JUMP_SPEED
