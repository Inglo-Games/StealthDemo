extends CharacterBody3D
class_name Guard

signal player_spotted
signal player_caught
signal interacted_item_spotted

enum GUARD_STATE {
	STATION,
	PATROL,
	ALERT,
	SEARCH,
	INVESTIGATE,
	CHASE
}

const BASE_SPEED := 6               # "Normal" movement speed
const CHASE_SPEED := 8              # Chase movement speed
const CHASE_THRESHOLD := 30         # Distance at which guard stops chase
const COOLDOWN_TIME := 20           # Seconds until Guard loses "alert" state
const STATION_DIST_THRESHOLD := 5   # Distance a guard can be from "station" position

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var ray_params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

# Cooldown timer for when Guard loses sight of player
@onready var search_cooldown : Timer = $SearchCooldown

# List of points defining Guard's patrol path
@export var patrol_points := [Vector3.ZERO]

# Point to look to if guard is stationary
@export var focus_point := Vector3.ZERO

# Search counter tracks how many directions the guard will look to before
# returning to PATROL mode
var search_counter := 0

# Record starting position for level resets
@onready var start_pos : Transform3D = get_global_transform()

# Track which point in the patrol path the Guard is going to next
var patrol_index := 0

# Physics Space used for checking raycast collisions
var phys_space : PhysicsDirectSpaceState3D

var state := GUARD_STATE.PATROL
var target_player : Player
var target_investigate


func _ready():
	
	# Set up signals
	player_spotted = Signal(self, "player_spotted")
	player_caught = Signal(self, "player_caught")
	interacted_item_spotted = Signal(self, "item_spotted")
	
	# Set up detection areas
	$SightArea.connect("body_entered", _on_object_spotted)
	$CatchArea.connect("body_entered", _on_object_caught)
	
	# Set initial target point
	if patrol_points:
		
		# If only one point, set to stationary mode
		if patrol_points.size() == 1:
			state = GUARD_STATE.STATION
			look_at(focus_point)
		# Otherwise set to patrol mode and start moving toward first point
		else:
			state = GUARD_STATE.PATROL
			nav_agent.set_target_location(patrol_points[0])
			look_at(patrol_points[0])
	else:
		print("Warning: Guard has no path to patrol!")


func _physics_process(_delta):
	
	phys_space = get_world_3d().direct_space_state
	
	match state:
		GUARD_STATE.PATROL, GUARD_STATE.ALERT:
			# Set speed based on state
			var cur_speed = (BASE_SPEED if state == GUARD_STATE.PATROL else CHASE_SPEED)
			_move_toward_target(cur_speed)
		
		GUARD_STATE.STATION:
			# If not at station, reuturn there
			if global_transform.origin.distance_to(patrol_points[0]) >= STATION_DIST_THRESHOLD:
				nav_agent.set_target_location(patrol_points[0])
				_move_toward_target(BASE_SPEED)
			# Otherwise sit still and face the focus_point
			look_at(focus_point)
		
		GUARD_STATE.INVESTIGATE:
			_move_toward_target(BASE_SPEED)
		
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


# Move the Guard towards a target point at given speed, using NavigationAgent
# function to perform the actual motion
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
				look_at(patrol_points[patrol_index])
		
		# If guard is investigating an item or a noise, check it out.
		GUARD_STATE.INVESTIGATE:
			print("Reached investigation target...")
			if target_investigate is Interactable:
				_investigate_item(target_investigate)
			# Noise sources are stored as a Vector3 point
			elif target_investigate is Vector3:
				# Search the area for anything else suspicious
				_enter_state_search()
		
		_:
			print("Reached navigation target in unsupported state!")


# Function triggered when any object enters the "SightArea" Area3D
func _on_object_spotted(body):
	# If Player is spotted...
	if body is Player and body.state != body.MOVE_STATE.HIDING:
		# Ensure the guard can actually see the player with a raycast
		if _check_raycast_hits_target(body):
			# Guard starts to chase!
			look_at(body.global_transform.origin)
			state = GUARD_STATE.CHASE
			target_player = body
			$TempLabel.show_label_temp(3, "!")
			player_spotted.emit()
	# Else if interactable object is spotted and it's been interacted with,
	# become suspicious and move to investigate it
	elif body is Interactable:
		if body.is_interacted():
			_enter_state_investigate(body)
			interacted_item_spotted.emit()
			nav_agent.set_target_location(body.global_transform.origin)


# Function triggered when any object enters the "CatchArea" Area3D
func _on_object_caught(body):
	if body is Player and _check_raycast_hits_target(body) and body.state != body.MOVE_STATE.HIDING:
		print("Guard caught the player!")
		player_caught.emit()


# Check if the raycast actually hits the body it's targeting, useful to check 
# sightlines from guard to target object
func _check_raycast_hits_target(body):
	# Set the locations for the start and end of the ray
	ray_params.from = self.global_transform.origin
	ray_params.to = body.global_transform.origin
	# Intersect the ray and check if the collision object matches the target
	var res = phys_space.intersect_ray(ray_params)
	if res.size() != 0:
		return res["collider"] == body


# Triggered when Guard receives noise signal (noisemaker, player footsteps, etc)
func on_hear_noise(noise_origin, noise_magnitude):
	# Check distance to noise against magnitude
	if self.position.distance_to(noise_origin) <= noise_magnitude:
		print("This guard heard a noise, investigating...")
		_enter_state_investigate(noise_origin)
		nav_agent.set_target_location(noise_origin)


# Guard checks item to see if player is hiding in it and resets it's interacted
# status
func _investigate_item(target):
	if target is HidingPlace and target.is_occupied:
		# Guard found a hiding player!
		# TODO: Pull player from HidingPlace
		get_tree().change_scene_to(load("res://src/menus/MainMenu.tscn"))
	elif target is Interactable:
		# Reset it then search the area
		target.interact(self)
		_enter_state_search()


# Guard enters PATROL or STATION mode and returns if not there already
func _enter_state_patrol():
	if patrol_points.size() > 1:
		state = GUARD_STATE.PATROL
		nav_agent.set_target_location(patrol_points[patrol_index])
		look_at(patrol_points[patrol_index])
	else:
		state = GUARD_STATE.STATION


# Guard enters ALERT state, moves more quickly until cooldown timer expires
func _enter_state_alert():
	print("Entering alert state...")
	$TempLabel.show_label_temp(3, "!")
	state = GUARD_STATE.ALERT
	$AlertCooldown.start(COOLDOWN_TIME)


# Guard enters INVESTIGATE state, moves toward noise or suspicious item "target"
func _enter_state_investigate(target):
	print("Entering investigate state...")
	$TempLabel.show_label_temp(3, "?")
	state = GUARD_STATE.INVESTIGATE
	target_investigate = target
	if target is Vector3:
		look_at(target)
	else:
		look_at(target.global_transform.origin)


# Guard enters SEARCH state, looks around area and then returns to PATROL if
# nothing is found
func _enter_state_search():
	
	state = GUARD_STATE.SEARCH
	search_counter = 4
	
	# Break out if search counter runs out or Guard changes state (e.g., it
	# sees the player or another suspicious item)
	while search_counter > 0 and state == GUARD_STATE.SEARCH:
		search_counter -= 1
		self.rotation.y += 90
		search_cooldown.start(2)
		await search_cooldown.timeout
	
	# Go back to patrolling when finished
	_enter_state_patrol()


# Callback function for AlertCooldown timer finished
func _on_AlertCooldown_timeout():
	if state == GUARD_STATE.ALERT:
		print("Entering patrol state...")
		state = GUARD_STATE.PATROL


# Reset position and state to initial conditions
func reset_guard():
	
	# Reset instance params
	patrol_index = 0
	search_counter = 0
	target_player = null
	target_investigate = null
	
	# Reset position, rotation, and state
	set_global_transform(start_pos)
	_enter_state_patrol()
