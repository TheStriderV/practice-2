class_name Inventory
extends Node


@export var inventory: InventoryResource

# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	
# 	print("Inventory items:", inventory.get_item_id_in_inventory())
	
func get_inventory():
	print("Inventory items:", inventory.get_item_id_in_inventory())
	return inventory.get_item_id_in_inventory()


