class_name Inventory
extends Node


@export_category("Inventory Resource")
@export var inventory_resource: InventoryResource

signal inventory_empty

var list : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if inventory_resource:
		get_inventory_list()
	
	inventory_resource.item_removed.connect(get_inventory_list)

	
func get_inventory():
	print("Inventory items:", inventory_resource.get_item_id_in_inventory())
	return inventory_resource.get_item_id_in_inventory()

func get_gold() -> int:
	return inventory_resource.get_gold()

func get_inventory_list(_item_data = null) -> Array:
	print("remove2")
	if list.size() != 0:
		list.clear()
	for item in inventory_resource.item_stack_list:
		list.append(item)
	print("List: ",list)
	if list.size() == 0:
		inventory_empty.emit()
	return list
	
func get_inventory_size():
	return list.size()
	
