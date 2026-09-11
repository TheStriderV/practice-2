class_name Inventory
extends Node


@export var inventory: InventoryResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Inventory items:", inventory.get_items_in_inventory())


