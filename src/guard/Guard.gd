extends CharacterBody3D
class_name Guard

signal player_spotted

enum GUARD_STATE {
	STATE_PATROL,
	STATE_ALERT,
	STATE_CHASE
}

const BASE_SPEED : int = 6               # "Normal" movement speed
const CHASE_SPEED : int = 8              # Chase movement speed
const CHASE_THRESHOLD : int = 30         # Distance at which guard stops chase
const GRAV : float = 9.8

@export_node_path(Path3D) var patrol_path

var patrol_points
var patrol_index := 0
var state = GUARD_STATE.STATE_PATROL
var target


func _ready():
	# Set up detection areas
	$SightArea.connect("body_entered", _on_object_spotted)
	$CatchArea.connect("body_entered", _on_object_caught)
	
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
		target = patrol_points[patrol_index]
	else:
		print("Warning: Guard has no path to patrol!")


func _physics_process(delta):
		
	# If at target patrol point, move to next one 
	if not target is Player and position.distance_to(target) < 1:
		patrol_index = (patrol_index + 1) % len(patrol_points)
		target = patrol_points[patrol_index]
	
	match state:
		GUARD_STATE.STATE_PATROL:
			_move_toward_target(target, CHASE_SPEED, delta)
		GUARD_STATE.STATE_ALERT:
			_move_toward_target(target, BASE_SPEED, delta)
		GUARD_STATE.STATE_CHASE:
			_move_toward_target(target.get_transform().origin, CHASE_SPEED, delta)
			# Stop chasing if player is too far away
			if position.distance_to(target.get_transform().origin) > CHASE_THRESHOLD:
				state = GUARD_STATE.STATE_ALERT
				target = patrol_points[patrol_index]
		_:
			print("Guard process error: invalid GUARD_STATE")


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


func _move_toward_target(target, velocity, delta):
	# Look toward target
	look_at(target)
	
	# Calculate direction to player, ignoring vertical difference
	var dir : Vector3 = target - self.get_transform().origin
	dir.y = 0
	dir = dir.normalized() * velocity
	
	motion_velocity.x = dir.x
	motion_velocity.z = dir.z
	motion_velocity.y -= delta * GRAV
	move_and_slide()
