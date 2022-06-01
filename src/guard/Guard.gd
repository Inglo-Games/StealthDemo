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
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var patrol_points
var patrol_index := 0
var state := GUARD_STATE.PATROL
var target_player : Player


func _ready():
	# Set up detection areas
	$SightArea.connect("body_entered", _on_object_spotted)
	$CatchArea.connect("body_entered", _on_object_caught)
	
	# Set initial target point
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
		nav_agent.set_target_location(patrol_points[0])
	else:
		print("Warning: Guard has no path to patrol!")


func _physics_process(_delta):
	
	match state:
		GUARD_STATE.PATROL, GUARD_STATE.ALERT:
			# Set speed based on state
			var current_speed = BASE_SPEED if state == GUARD_STATE.PATROL else CHASE_SPEED
			# Move toward next point if not already there
			if position.distance_squared_to(nav_agent.get_target_location()) >= 1:
				_move_toward_target(current_speed)
			# If close to target and patrol_points isn't just one point, 
			# change to next point in patrol_points
			elif patrol_points.size() > 1:
				patrol_index = (patrol_index + 1) % len(patrol_points)
				nav_agent.set_target_location(patrol_points[patrol_index])
		
		GUARD_STATE.SEARCHING:
			# TODO: Implement searching func
			pass
		
		GUARD_STATE.CHASE:
			# Recalculate path to player using NavigationAgent
			nav_agent.set_target_location(target_player.global_transform.origin)
			_move_toward_target(CHASE_SPEED)
			# Stop chasing if player is too far away
			if position.distance_to(nav_agent.get_target_location()) > CHASE_THRESHOLD:
				_enter_state_alert()
				nav_agent.set_target_location(patrol_points[patrol_index])
		
		_:
			print("Guard process error: invalid GUARD_STATE")


func _move_toward_target(speed : float):
	var next_pos : Vector3 = nav_agent.get_next_location()
	var curr_pos : Vector3 = global_transform.origin
	var new_vec : Vector3 = (next_pos - curr_pos).normalized() * speed
	nav_agent.set_velocity(new_vec)


# Function moves guard using vector to target point using NavigationServer
func _on_nav_velocity_computed(safe_velocity : Vector3):
	velocity = safe_velocity
	move_and_slide()


# Function triggered when any object enters the "SightArea" Area3D
func _on_object_spotted(body):
	# If Player is spotted, enter chase state
	if body is Player and body.state != body.MOVE_STATE.HIDING:
		state = GUARD_STATE.CHASE
		target_player = body
		$TempLabel.show_label_temp(3, "!")
	# Else if interactable object is spotted and it's been interacted with,
	# become suspicious
	elif body is Interactable:
		if body.is_interacted():
			_enter_state_alert()

# Function triggered when any object enters the "CatchArea" Area3D
func _on_object_caught(body):
	if body is Player:
		print("Caught player!")
		get_tree().change_scene_to(load("res://src/menus/MainMenu.tscn"))


func on_hear_noise(noise_origin, noise_magnitude):
	# Check distance to noise against magnitude
	if self.position.distance_to(noise_origin) <= noise_magnitude:
		print("This guard heard a noise!")
		_enter_state_alert()


func _enter_state_alert():
	print("Entering alert state...")
	$TempLabel.show_label_temp(3, "?")
	state = GUARD_STATE.ALERT
	$AlertCooldown.start(COOLDOWN_TIME)


# Callback function for AlertCooldown timer finished
func _on_AlertCooldown_timeout():
	if state == GUARD_STATE.ALERT:
		print("Entering patrol state...")
		state = GUARD_STATE.PATROL

