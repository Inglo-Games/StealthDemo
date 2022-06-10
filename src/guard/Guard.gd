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

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var ray_params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

@export var patrol_points := [Vector3.ZERO]

var patrol_index := 0
var phys_space : PhysicsDirectSpaceState3D
var state := GUARD_STATE.PATROL
var target_player : Player


func _ready():
	# Set up detection areas
	$SightArea.connect("body_entered", _on_object_spotted)
	$CatchArea.connect("body_entered", _on_object_caught)
	
	# Set initial target point
	if patrol_points:
		nav_agent.set_target_location(patrol_points[0])
		look_at(nav_agent.get_target_location())
	else:
		print("Warning: Guard has no path to patrol!")


func _physics_process(_delta):
	
	phys_space = get_world_3d().direct_space_state
	
	match state:
		GUARD_STATE.PATROL, GUARD_STATE.ALERT:
			# Set speed based on state
			var cur_speed = (BASE_SPEED if state == GUARD_STATE.PATROL else CHASE_SPEED)
			_move_toward_target(cur_speed)
		
		GUARD_STATE.SEARCHING:
			# TODO: Implement searching func
			pass
		
		GUARD_STATE.CHASE:
			# Recalculate path to player using NavigationAgent
			nav_agent.set_target_location(target_player.global_transform.origin)
			_move_toward_target(CHASE_SPEED)
			# Stop chasing if player is too far away
			if nav_agent.distance_to_target() > CHASE_THRESHOLD:
				_enter_state_alert()
				nav_agent.set_target_location(patrol_points[patrol_index])
		
		_:
			print("Guard process error: invalid GUARD_STATE")


func _move_toward_target(speed : float):
	if nav_agent.is_target_reachable():
		var next_pos : Vector3 = nav_agent.get_next_location()
		var new_vec : Vector3 = global_transform.origin.direction_to(next_pos).normalized() * speed
		nav_agent.set_velocity(new_vec)


# Function moves guard using vector to target point using NavigationServer
func _on_nav_velocity_computed(safe_velocity : Vector3):
	velocity = safe_velocity
	move_and_slide()


# Function called when guard reaches current navigation target point
func _on_nav_target_reached():
	match state:
		# If guard is patrolling, set target to next point in patrol path
		GUARD_STATE.PATROL, GUARD_STATE.ALERT:
			if patrol_points.size() > 1:
				patrol_index = (patrol_index + 1) % len(patrol_points)
				nav_agent.set_target_location(patrol_points[patrol_index])
				look_at(nav_agent.get_target_location())
		_:
			print("Reached navigation target in unsupported state!")


# Function triggered when any object enters the "SightArea" Area3D
func _on_object_spotted(body):
	# If Player is spotted...
	if body is Player and body.state != body.MOVE_STATE.HIDING:
		# Ensure the guard can actually see the player with a raycast
		if _check_raycast_hits_target(body):
			# Guard starts to chase!
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
	if body is Player and _check_raycast_hits_target(body):
		print("Caught player!")
		get_tree().change_scene_to(load("res://src/menus/MainMenu.tscn"))


# Check if the raycast actually hits the body it's targeting, useful to check 
# sightlines from guard to target object
func _check_raycast_hits_target(body):
	# Set the locations for the start and end of the ray
	ray_params.from = self.global_transform.origin
	ray_params.to = body.global_transform.origin
	# Intersect the ray and check if the collision object matches the target
	var res = phys_space.intersect_ray(ray_params)
	return res["collider"] == body


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
