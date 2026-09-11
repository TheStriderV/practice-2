class_name InventoryResource
extends Resource

signal item_added(stack: ItemStack, slot: int)
signal item_removed(stack: ItemStack, slot: int)
signal slot_changed(slot: int)

@export var slots: Array[ItemStack] = []
@export var capacity: int = 24

func get_items_in_inventory():
	var list := []
	for i in slots:
		list.append(i.get_id())
		
		return list

func create_item_stack(item_id: int, item_amount: int = 1):
	pass
