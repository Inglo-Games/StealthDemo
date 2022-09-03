extends Node

# This singleton class handles the player's inventory so that it persists
# across scenes

signal change_items

# Inventory of player
var inventory : Dictionary = {
	"lockpick": 0,
	"noisemaker": 0,
	"boltcutter": 0
}

# Keys Player is holding onto
var keyring := []


func _ready():
	change_items = Signal(self, "change_items")


# Remove a given key ID from player keyring, if it exists
func remove_key_id(id : String):
	var index = keyring.find(id)
	if index != -1:
		keyring.remove_at(index)


# Add a given key ID to the player keyring, avoiding duplicates
func give_key_id(id : String):
	if not keyring.has(id):
		keyring.push_back(id)


# Add number of given items to player's inventory
func give_items(item : String, num : int):
	inventory[item] += num
	change_items.emit()


# Remove one item from player's inventory
func remove_item(item : String):
	inventory[item] -= 1
	change_items.emit()
