extends CharacterBody3D
class_name Guard

signal player_spotted

enum GUARD_STATE {
	STATE_PATROL,
	STATE_ALERT,
	STATE_CHASE
}

const BASE_SPEED : int = 6
const CHASE_SPEED : int = 9
const GRAV : float = 9.8

var state = GUARD_STATE.STATE_PATROL
var target

func _ready():
	# Set up detection areas
	$SightArea.connect("body_entered", _on_object_spotted)
	$CatchArea.connect("body_entered", _on_object_caught)

func _physics_process(delta):
	# TODO: Add patrol logic
	
	if state == GUARD_STATE.STATE_CHASE:
		# Look toward player
		look_at(target.get_transform().origin)
		
		# Calculate direction to player, ignoring vertical difference
		var dir : Vector3 = target.get_transform().origin - self.get_transform().origin
		dir.y = 0
		dir = dir.normalized() * CHASE_SPEED
		
		motion_velocity.x = dir.x
		motion_velocity.z = dir.z
		motion_velocity.y -= delta * GRAV
		move_and_slide()

# Function triggered when any object enters the "SightArea" Area3D
func _on_object_spotted(body):
	if body is Player:
		print("Spotted player!")
		state = GUARD_STATE.STATE_CHASE
		target = body

# Function triggered when any object enters the "CatchArea" Area3D
func _on_object_caught(body):
	if body is Player:
		print("Caught player!")
		get_tree().quit()
