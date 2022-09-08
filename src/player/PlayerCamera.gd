extends Node3D

# Max distance from camera a wall can be to have pixel dithering enabled
const FADE_MAX_DISTANCE = 15.0

@onready var cam = get_node("Camera3D")

# Raycast to detect collisions with walls
@onready var ray = get_node("RayCast")

# Objects last collided with the RayCasts
var obj = null


func _physics_process(_delta):
	
	# Make sure the raycasts originate from the camera and point to either side
	# of the player model
	ray.position = cam.position
	ray.target_position = (cam.position * -1)
	
	_check_collision()


# Check if a raycast is colliding with an object and, if so, whether it's the
# same object that was recorded in lobj/robj
func _check_collision():
	
	if ray.is_colliding():
		if ray.get_collider() != obj:
			# Disable dithering on previous object and enable it on the new one
			_disable_pixel_dithering()
			obj = ray.get_collider()
			_enable_pixel_dither()
	else:
		_disable_pixel_dithering()


# Enable pixel dithering on the material for the given object
func _enable_pixel_dither():
	
	# Get parent because raycast hits the StaticBody3D shape, but we want to
	# modify the material of its parent MeshInstance3D
	var mat = obj.get_parent().mesh.surface_get_material(0)
	mat.distance_fade_mode = BaseMaterial3D.DistanceFadeMode.DISTANCE_FADE_PIXEL_DITHER
	mat.distance_fade_max_distance = FADE_MAX_DISTANCE


# Disable pixel dithering on object if it exists
func _disable_pixel_dithering():
	
	if obj != null:
		obj.get_parent().mesh.surface_get_material(0).distance_fade_mode = \
					BaseMaterial3D.DistanceFadeMode.DISTANCE_FADE_DISABLED
	
	obj = null