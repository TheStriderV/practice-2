class_name Inventory
extends Node


@export_category("Inventory Resource")
@export var inventory_resource: InventoryResource



# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	
# 	print("Inventory items:", inventory.get_item_id_in_inventory())
	
func get_inventory():
	print("Inventory items:", inventory_resource.get_item_id_in_inventory())
	return inventory_resource.get_item_id_in_inventory()

func get_gold() -> int:
	return inventory_resource.get_gold()




