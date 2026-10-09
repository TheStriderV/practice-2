@tool
class_name InventoryResource
extends Resource

signal item_added(slot: int) #stack: ItemStack  
signal item_removed(slot: int)
signal slot_changed(slot: int)

## Gold: Should this be a class?
@export_category("Gold")
@export var gold: int = 0:
	set(value):
		gold = max(0, value)

@export var item_stack_list: Array[ItemStack] = []

@export var capacity: int = 24


func _init(items: Array[ItemData] = []) -> void:
	if items.size() <= 0:
		#print("InventoryResource: Items array is empty")
		return
	
	for i in items:
		create_item_stack(i)
		
	print("Slots size:", item_stack_list.size())

	
func get_item_id_in_inventory() -> Array:
	var list := []
	for item_data in item_stack_list:
		list.append(item_data.get_id())
	return list

func create_item_stack(item_data, item_amount: int = 1) -> void:
	#print(item_id)
	var item_stack : ItemStack = ItemStack.new(item_data, item_amount)
	item_stack_list.append(item_stack)

func add_item(item_stack:ItemStack) -> void:
	item_stack_list.append(item_stack)
	item_added.emit(item_stack_list.size())
	
func remove_item(item_stack:ItemStack) -> void:	
	item_stack_list.erase(item_stack)
	item_removed.emit(item_stack_list.size())

func add_gold(amount: int) -> void:
	gold += amount

func remove_gold(amount: int) -> void:
	gold -= amount

## Returns gold amount
func get_gold() -> int: return gold

func get_item(id: String) -> ItemStack:
	for item_stack in item_stack_list:
		
		if item_stack.get_id() == id:
			
			return item_stack
	return null
