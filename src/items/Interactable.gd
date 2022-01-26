extends Node3D
class_name Interactable

var interacted := false

# Empty "virtual" function to be overridden by inherited 
func interact():
	pass

func is_interacted():
	return interacted

func set_interacted(val:bool):
	interacted = val
