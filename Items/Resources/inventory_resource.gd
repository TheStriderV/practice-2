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

@export var slots: Array[ItemStack] = []

@export var capacity: int = 24


func _init(items: Array[ItemData] = []) -> void:
	if items.size() <= 0:
		#print("InventoryResource: Items array is empty")
		return
	
	for i in items:
		create_item_stack(i)
		
	print("Slots size:", slots.size())

	
func get_item_id_in_inventory() -> Array:
	var list := []
	for i in slots:
		list.append(i.get_id())
	return list

func create_item_stack(item_data, item_amount: int = 1) -> void:
	#print(item_id)
	var item_stack : ItemStack = ItemStack.new(item_data, item_amount)
	slots.append(item_stack)

func add_item(item_stack:ItemStack) -> void:
	slots.append(item_stack)
	item_added.emit(slots.size())
	
func remove_item(item_stack:ItemStack) -> void:	
	slots.erase(item_stack)
	item_removed.emit(slots.size())

func add_gold(amount: int) -> void:
	gold += amount

func remove_gold(amount: int) -> void:
	gold -= amount

## Returns gold amount
func get_gold() -> int: return gold