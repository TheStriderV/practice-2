extends Node

# Grit Item checker
# Checks if slot is occupied
# Gets item grid off set and checks if it can fit



var grit_inventory_item: GritInventoryItem

var columns: int = 10
var grid_array := []

## Index in grid_array for slot_id + offset, or -1 if out of bounds or wrapping a row edge.
func get_offset_index(slot_id: int, offset) -> int:
	var column : int = slot_id % columns + offset[0]
	if column < 0 or column >= columns: # line_switch_check
		return -1

	var index : int = slot_id + offset[0] + offset[1] * columns # grid_to_check

	if index < 0 or index >= grid_array.size():
		return -1

	return index

func check_slot_availability(slot: GridInventorySlot, item: Node) -> bool:
	for offset in item.item_grids: # Get item_grid array
		var index := get_offset_index(slot.slot_ID, offset)
		if index == -1:
			return false
		var target = grid_array[index]
		if target.state == target.States.TAKEN:
			return false
	return true
