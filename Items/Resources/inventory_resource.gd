@tool
class_name InventoryResource
extends Resource

signal item_added(slot: int) #stack: ItemStack  
signal item_removed(slot: int)
signal slot_changed(slot: int)

@export var slots: Array[ItemStack] = []

@export var capacity: int = 24


func _init(items: Array[ItemData] = []):
	if items.size() <= 0:
		#print("InventoryResource: Items array is empty")
		return
	
	for i in items:
		create_item_stack(i)
		
	print("Slots size:", slots.size())



func _ready() -> void:
	#print("Slots size:", slots.size())
	pass
	
func get_item_id_in_inventory():
	var list := []
	for i in slots:
		list.append(i.get_id())
	return list

func create_item_stack(item_data, item_amount: int = 1):
	#print(item_id)
	var item_stack = ItemStack.new(item_data, item_amount)

	slots.append(item_stack)

func add_item(item_stack:ItemStack):
	slots.append(item_stack)
	item_added.emit(slots.size())
	
func remove_item(item_stack:ItemStack):
	
	slots.erase(item_stack)
	item_removed.emit(slots.size())
