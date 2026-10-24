class_name GritItemMover
extends Node
# ## Debug
# func _unhandled_input(event: InputEvent) -> void:
# 	if event.is_action_pressed("debug_1"):
# 		print("Debug 1 Pressed")
# 		move_items(vendor_grit,player_grit)
# 		
# 	if event.is_action_pressed("debug_2"):
# 		print("Debug 2 Pressed")

signal item_moved(item:GritInventoryItem)

## Move items between grit containers
func move_items(source:GritContainer, destination:GritContainer):
	var item_list := source.item_stored.duplicate()
	for item in item_list:
		if item.item_owner == destination.item_owner:
			source.set_slots_state(item, GridInventorySlot.States.FREE) # or else it doesnt update 		
			destination.move_item_to_free_slot(item)
			source.remove_item(item)
			
	
			
