class_name GritContainer
extends GridContainer
# GritSlotBuilder
## GRIT: GRid InvenTory for short.
## Builds and manages Grid_Array and Slot_ID
## Sends signals when mouse is entered. 
## Each slot keeps track of what's in it and what color it should be


@export var slot_amount : int = 30
@export var slot_size : int = 50

## For tracking what item belongs to who
@export_enum("Npc", "Player", "None") var item_owner: String = "None"

@onready var slot_scene = preload("uid://dxvx2kwd2mv52")

var grid_array := []
var icon_anchor : Vector2 = Vector2.ZERO
var is_hovering := false
var item_held = null
var current_slot = null

var item_stored : Array[GritInventoryItem] = []

## TODO: Can use this as a way to save and load locations or quickly move items
var item_stored_location : Dictionary 

signal hovered_slot(slot)
signal grid_entered(grid)
signal grid_exited()

signal item_added(item)
signal item_removed(item)

signal debug_text(text)

func _ready() -> void:
	# Deletes Debug slots to start new
	if get_children().size() != 0:
		for child in get_children():
			if child is GridInventorySlot:
				child.queue_free()

	# Creates slots
	for i in range(slot_amount):
		create_slot(slot_size)
	#P.log("GridContainer Ready")
func _process(_delta: float) -> void:
	# Placement
	# Watch for UI errors!! if the control is overlapping then this messes with the placements.
	if get_global_rect().has_point(get_global_mouse_position()):
		#print("Mouse in grid", self.name)
		if not is_hovering:
			is_hovering = true
			grid_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			grid_exited.emit()
			
func _on_slot_mouse_entered(selected_slot):
	if Engine.is_editor_hint():
		return
	current_slot = selected_slot
	hovered_slot.emit(current_slot)
	icon_anchor = Vector2(0,0)
	if item_held:
		check_slot_availability(current_slot, item_held)
		set_grids.call_deferred(current_slot, item_held)

## Slot Creation
func create_slot(_size:int = 50):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot) #
	add_child(new_slot) # TODO: Add as child to GridContainer
	new_slot.custom_minimum_size = Vector2(_size, _size)
	
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)
### End Slot Creation

func update_item_held(new_item_held):
	item_held = new_item_held

func _on_slot_mouse_exited(_selected_slot):
	if Engine.is_editor_hint():
		return
	#grid_exited.emit()
	clear_grid()

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

## Helper for check slot availablity 
## Index in grid_array for slot_id + offset, or -1 if out of bounds or wrapping a row edge.
func get_offset_index(slot_id: int, item_grid) -> int:
	# Checks columns first; only applies to items that extend horizontally
	var column : int = slot_id % columns + item_grid[0] # Example: SlotID = 9, 9 % 5 = 4; 4 is what remains; same for 14 % 5
	if column < 0 or column >= columns: # Checks if out of Column Bounds
		return -1

	var index : int = slot_id + item_grid[0] + item_grid[1] * columns # Ex. 19 + 0 + 1 * 5 = 24 > grid_array.size = 20
	# Checks the last line, really only appies to vertical spread items
	if index < 0 or index >= grid_array.size():
		return -1

	return index

func check_slot_availability(slot: GridInventorySlot, item: Node) -> bool:
	if not item: return -1
	for item_grid in item.item_grids: # Get item_grid array
		# Checks if item_grid is in bounds of current grid given the selected slot.
		var index := get_offset_index(slot.slot_ID, item_grid)
		if index == -1:
			return false
		var target = grid_array[index]
		if target.state == target.States.TAKEN:
			return false
	
	return true

func set_grids(slot: GridInventorySlot, item: Node) -> void:
	for item_grid in item.item_grids:
		var index := get_offset_index(slot.slot_ID, item_grid)
		if index == -1:
			continue # Out of bounds, Check next slot
		var target = grid_array[index]
		if check_slot_availability(slot, item):
			target.set_color(target.States.FREE)
			icon_anchor.x = min(icon_anchor.x, item_grid[1]) # To be used for snapping in place_item(); 
			icon_anchor.y = min(icon_anchor.y, item_grid[0]) #  Should always = (0,0) since starting item grid should always be (0,0)
		else:
			target.set_color(target.States.TAKEN)


### Item Placement
func place_item(item : GritInventoryItem, slot : GridInventorySlot = current_slot):
	
	if item_owner != "None":
		if item.item_owner != item_owner:
			print("Not the right owner")
			return
		
	if not check_slot_availability(slot, item):
		return
	
	
	var grid_id = slot.slot_ID + icon_anchor.x * columns + icon_anchor.y
	
	item._snap_to(grid_array[grid_id].global_position)	
	item.grid_anchor = slot
	
	item.reparent(self)
	item_held = null
	
	set_slots_state(item, GridInventorySlot.States.TAKEN)
	clear_grid()
	
	item_stored.append(item)
	item_added.emit(item)
	
	
	store_item_location(item, slot.slot_ID)
	return true

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	var slot_item_stored : GritInventoryItem = current_slot.item_stored	
	set_slots_state(slot_item_stored, GridInventorySlot.States.FREE)
	slot_item_stored.selected = true	
	item_removed.emit(slot_item_stored)
	_on_slot_mouse_entered(current_slot)
	
	item_removed.emit(slot_item_stored)
	item_stored.erase(slot_item_stored)
	item_stored_location.erase(current_slot.slot_ID)
	return true

func remove_item(item: GritInventoryItem):
	
	if not item:
		return

	set_slots_state(item, GridInventorySlot.States.FREE)
	item_stored.erase(item)
func delete_item(item: GritInventoryItem):
	if not item: return
	remove_item(item)
	item.queue_free()


func move_item_to_free_slot(item: GritInventoryItem):
	var moved : bool
	for slot in grid_array:		
		if place_item(item, slot):
			moved = true
			break
		else:
			moved = false
			continue
	if not moved:
		return null

func set_slots_state(item: Node, state: GridInventorySlot.States) -> void:
	for offset in item.item_grids:
		var index = item.grid_anchor.slot_ID + offset[0] + offset[1] * columns
		
		var target = grid_array[index]
		target.state = state
		match state:
			GridInventorySlot.States.TAKEN:
				target.state = state
				target.item_stored = item
			GridInventorySlot.States.FREE:
				target.state = state
				target.item_stored = null
			_:
				pass  # other states leave item_stored untouched

## Utilities
func if_in_grid():
	return get_global_rect().has_point(get_global_mouse_position())


## update_slots_state
## TODO: Auto update slot states by scanning items stored
## TODO: 


func store_item_location(item: GritInventoryItem, slot_anchor_id: int):
	item_stored_location[slot_anchor_id] = item
	debug_text.emit(item_stored_location)
	


		
