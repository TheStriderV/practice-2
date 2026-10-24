## Inventory data
class_name Inventory
extends Node


@export_category("Inventory Resource")
@export var inventory_resource: InventoryResource
@export var randomize_inventory : bool = false
@export var max_items : int = 3

## For creating inventory resources
const InventoryResource = preload("uid://du1aioahuboc8")

signal inventory_empty

## List of Array of ItemStack
var list : Array[ItemStack]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randomize_inventory:
		create_random_inventory_resource(max_items)	
	
	if inventory_resource:
		get_inventory_list()
	
	inventory_resource.item_removed.connect(get_inventory_list)
	#inventory_resource.gold_changed.connect(get_inventory_list)
	
## Returns list of inventory items by ID
func get_inventory():
	#print("Inventory items:", inventory_resource.get_item_id_in_inventory())
	return inventory_resource.get_item_id_in_inventory()

func get_gold() -> int:
	return inventory_resource.get_gold()

func get_inventory_list(_item_data = null) -> Array:
	if list.size() != 0:
		list.clear()
	for item in inventory_resource.item_stack_list:
		list.append(item)
	if list.size() == 0:
		inventory_empty.emit()
	return list

func get_inventory_size():
	return list.size()
	
func get_item_grid_offsets(index: int):
	print("List:", list)
	print("Getting object: ", list[index].get_id())
	return list[index].shape_data.offsets

func create_random_inventory_resource(_max_items):
	var random_amount = randi_range(1,_max_items)
	var random_inventory = InventoryResource.new()
	var item_list : Array = Items.get_all_items()
	item_list.shuffle()
	print("Random Amount:", random_amount)
	for i in random_amount:
		random_inventory.create_item_stack(item_list[i])
		
	inventory_resource = random_inventory
	inventory_resource.gold = 200

func add_item(item_stack:ItemStack) -> void: inventory_resource.add_item(item_stack)

func remove_item(item_stack:ItemStack) -> void: inventory_resource.remove_item(item_stack)

func add_gold(amount: int) -> void: inventory_resource.add_gold(amount)

func remove_gold(amount: int) -> void: inventory_resource.remove_gold(amount)

func get_gold_amount() -> int: return inventory_resource.get_gold()
