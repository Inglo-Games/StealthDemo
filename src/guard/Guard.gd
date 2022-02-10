extends CharacterBody3D
class_name Guard

signal player_spotted

enum GUARD_STATE {
	PATROL,
	ALERT,
	SEARCHING,
	CHASE
}

const BASE_SPEED : int = 6               # "Normal" movement speed
const CHASE_SPEED : int = 8              # Chase movement speed
const CHASE_THRESHOLD : int = 30         # Distance at which guard stops chase
const COOLDOWN_TIME : int = 20           # Seconds until Guard loses "alert" state

@export_node_path(Path3D) var patrol_path

var patrol_points
var patrol_index := 0
var state := GUARD_STATE.PATROL
var target


func _ready():
	# Set up detection areas
	$SightArea.connect("body_entered", _on_object_spotted)
	$CatchArea.connect("body_entered", _on_object_caught)
	
	# Set initial target point
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
		target = patrol_points[patrol_index]
	else:
		print("Warning: Guard has no path to patrol!")


func _physics_process(_delta):
	
	match state:
		GUARD_STATE.PATROL, GUARD_STATE.ALERT:
			# Set speed based on state
			var current_speed = BASE_SPEED if state == GUARD_STATE.PATROL else CHASE_SPEED
			# Move toward next point if not already there
			if position.distance_squared_to(target) >= 1:
				_move_toward_target(target, current_speed)
			# If close to target and patrol_points isn't just one point, 
			# change to next point in patrol_points
			elif patrol_points.size() > 1:
				patrol_index = (patrol_index + 1) % len(patrol_points)
				target = patrol_points[patrol_index]
		GUARD_STATE.SEARCHING:
			# TODO: Implement searching func
			pass
		GUARD_STATE.CHASE:
			_move_toward_target(target.get_transform().origin, CHASE_SPEED)
			# Stop chasing if player is too far away
			if position.distance_to(target.get_transform().origin) > CHASE_THRESHOLD:
				_enter_state_alert()
				target = patrol_points[patrol_index]
		_:
			print("Guard process error: invalid GUARD_STATE")


# Function triggered when any object enters the "SightArea" Area3D
func _on_object_spotted(body):
	# If Player is spotted, enter chase state
	if body is Player:
		state = GUARD_STATE.CHASE
		target = body
	# Else if interactable object is spotted and it's been interacted with,
	# become suspicious
	elif body is Interactable:
		if body.is_interacted():
			_enter_state_alert()

# Function triggered when any object enters the "CatchArea" Area3D
func _on_object_caught(body):
	if body is Player:
		print("Caught player!")
		get_tree().quit()


func _move_toward_target(target, velocity):
	# Look toward target
	look_at(target)
	
	# Calculate direction to target, ignoring vertical difference
	var dir : Vector3 = target - self.get_transform().origin
	dir.y = 0
	dir = dir.normalized() * velocity
	
	motion_velocity.x = dir.x
	motion_velocity.z = dir.z
	move_and_slide()


func _enter_state_alert():
	print("Entering alert state...")
	state = GUARD_STATE.ALERT
	$AlertCooldown.start(COOLDOWN_TIME)

# Callback function for AlertCooldown timer finished
func _on_AlertCooldown_timeout():
	if state == GUARD_STATE.ALERT:
		print("Entering patrol state...")
		state = GUARD_STATE.PATROL
