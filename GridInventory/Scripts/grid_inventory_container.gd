## Creates Grid Inventory, should expect a item handler in Parent root
class_name GridInventoryContainer
extends GridContainer

## Grid Inventory Container Class
##
## Takes a inventory resource and stores or creates items in the grid

@export var item_handler : ItemHandler

@export var slot_amount : int = 30 # GritSlotBuilder
@export var slot_size : int = 50 # GritSlotBuilder

## For tracking what item belongs to who
@export_enum("Npc", "Player", "None") var item_owner: String

@onready var slot_scene = preload("uid://dxvx2kwd2mv52") # GritSlotBuilder

@export var inventory : InventoryResource:
	set(value):
		if value == inventory:
			return # Do nothing if it's the exact same resource
		
		inventory = value
		inventory_resource_changed.emit()
		
@export var load_inventory : bool = false

@onready var item_scene := preload("uid://bs6djdnvwyvox")

signal grid_entered(grid) # GritSlotChecker
signal grid_exited(grid)  # GritSlotChecker

signal item_currently_held(item)
signal item_picked_up()
signal item_placed()

signal hovered_slot(slot) # GritSlotBuilder

signal inventory_resource_changed()

var is_hovering := false # GritSlotChecker
var grid_array := [] # GritSlotBuilder

var current_slot = null # GritSlotBuilder

var icon_anchor : Vector2 = Vector2.ZERO # GritSlotBuilder

## For uncentering to cursor; unused currently
var drag_offset: Vector2 = Vector2.ZERO 

## Unused: for scaling whole inventory; right now it's a set amount
var scaled_amount: Vector2

var items_stored : Array[GridInventoryItem]
var taken_slots = 0

func _ready() -> void:
	# Find and attach handler
	if item_handler == null: 
		item_handler = %ItemHandler
		#assert(item_handler != null, "Connect or add a item handler!")
	
	# Deletes Debug slots to start new
	if get_children().size() != 0:
		for child in get_children():
			if child is GridInventorySlot:
				child.queue_free()
	
	# Creates slots
	for i in range(slot_amount):
		create_slot(slot_size)

	if inventory == null:
		P.log("No inventory")
		inventory = InventoryResource.new()
		
	if load_inventory == false:
		P.log("Not loading inventory")
		return

	await get_tree().process_frame
	# Creates items, if any
	if inventory:
		var new_item_list = inventory.item_stack_list.duplicate()
		place_all_items(new_item_list)
	
	# Test creating an item and placing at slot 0
	#var new_item_potion = create_item("potion")
	#place_item(new_item_potion, grid_array[0])

## This is purely for checking what grid is the mouse in
## can this be combined with slot signal?
func _process(_delta: float) -> void: # GritGridChecker
	# Placement
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			grid_entered.emit(self)

	else:
		if is_hovering:
			is_hovering = false
			grid_exited.emit(self)

func _on_slot_mouse_entered(selected_slot): # GritSlotBuilder
	if Engine.is_editor_hint():
		return
	#emit_signal("grid_entered", self)
	icon_anchor = Vector2(10000,10000)
	print("Icon anchor 1:", icon_anchor)
	current_slot = selected_slot
	hovered_slot.emit(current_slot)
	if item_handler.item_held:
		check_slot_availability(current_slot, item_handler.item_held)
		set_grids.call_deferred(current_slot, item_handler.item_held)
		pass

func _on_slot_mouse_exited(selected_slot): # GritSlotBuilder
	if Engine.is_editor_hint():
		return
	clear_grid()

## Slot Creation
func create_slot(_size:int = 50):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	add_child(new_slot)
	new_slot.custom_minimum_size = Vector2(_size, _size)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)
		
func check_if_grid_in_grid():
	return get_global_rect().has_point(get_global_mouse_position())

## Creates a new item and returns it # 
## Currently GridInventoryItem creates the item from it's own Resource reference that stores all the items available (so far..)
func create_item(item) -> GridInventoryItem:
	var new_item = item_scene.instantiate() as GridInventoryItem
	add_child(new_item)
	new_item.load_item_stack(item, inventory)	
	return new_item

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

func set_grids(slot: GridInventorySlot, item: Node) -> void:
	for offset in item.item_grids:
		var index := get_offset_index(slot.slot_ID, offset)
		if index == -1:
			continue
		var target = grid_array[index]
		if check_slot_availability(slot, item):
			target.set_color(target.States.FREE)
			icon_anchor.x = min(icon_anchor.x, offset[1])
			icon_anchor.y = min(icon_anchor.y, offset[0])
			print("Icon anchor 2:", icon_anchor)
		else:
			target.set_color(target.States.TAKEN)


func place_item(item : GridInventoryItem, slot : GridInventorySlot): # TODO: Switch vars after refactor
	if not check_slot_availability(slot, item):
		return
	print("Icon anchor 3:", icon_anchor)
	var grid_id = slot.slot_ID + icon_anchor.x * columns + icon_anchor.y #
	if grid_id > grid_array.size()-1:
		push_error("Out of bounds")
		return
		
	if item_owner != "None":
		if item.item_owner != item_owner:
			print("Not the right owner")
			return	
	
	item._snap_to(grid_array[grid_id].global_position)
	item.grid_anchor = slot

	set_slots_state(item, GridInventorySlot.States.TAKEN)
	clear_grid()	
	
	inventory.add_item(item.item_stack)
	
	items_stored.append(item)
	item_placed.emit()
	item.reparent(self)
	return true

func place_item_check(item : GridInventoryItem, slot : GridInventorySlot):
	if not check_slot_availability(slot, item):
		return

	var grid_id = slot.slot_ID + icon_anchor.x * columns + icon_anchor.y #
	if grid_id > grid_array.size()-1:
		push_error("Out of bounds")
		return
	
	return true

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	var item_held : GridInventoryItem = current_slot.item_stored
	item_held.selected = true
	item_held.reparent(item_handler.get_parent())


	item_currently_held.emit(item_held)
	item_handler.item_held.global_position = get_global_mouse_position()

	set_slots_state(item_held, GridInventorySlot.States.FREE)
	check_slot_availability(current_slot, item_handler.item_held)
	set_grids.call_deferred(current_slot, item_handler.item_held)
	
	inventory.remove_item(item_held.item_stack)
	
	items_stored.erase(item_held)
	item_picked_up.emit()



func set_slots_state(item: Node, state: GridInventorySlot.States) -> void:
	for offset in item.item_grids:
		var index = item.grid_anchor.slot_ID + offset[0] + offset[1] * columns
		
		if index > grid_array.size():
			pass
			
		
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

## Creates and places items from inventory, random = true to randomize placement
func place_all_items(_inventory: Array = inventory.item_stack_list, random : bool = false):
	
	var inv_list : Array = _inventory
	#P.p(inv_list)
	if random:
		inv_list.shuffle() 
	for item in inv_list.size():
		#P.p(inv_list)
		#P.p(inv_list.size())
		var new_item = create_item(inv_list[item].get_id())
		new_item.item_owner = item_owner
		for slot in grid_array:
			
			#print("Slot: ", slot.slot_ID)
			var placed_item = place_item(new_item, slot)
			if placed_item == null:
				continue
			#print(placed_item)
			break
		
		
		if new_item.grid_anchor == null:
			new_item.queue_free()

## Checks if there is a slot available to place the item
func check_next_available_slot(item):
	var placed_item
	for slot in grid_array:
		placed_item = place_item_check(item, slot)

		if placed_item == null:			
			print("Taken")
			continue
		
		else:
			return slot
				
		# return
	
	if placed_item == null:
		print("No more slots available")
		return 
		

func remove_item_from_inventory(item):
	set_slots_state(item, GridInventorySlot.States.FREE)
	inventory.remove_item(item.item_stack)
	items_stored.erase(item)

func clear():
	taken_slots = 0
	pass





## 
func get_container_worth(_item_owner):
	var container_worth : int = 0
	for items in items_stored:
		if items.item_owner == _item_owner:
			container_worth += items.item_stack.get_base_value()
			#P.p(container_worth)
	return container_worth

func add_item_to_inventory(item):	
	pass

func set_item_metadata(_idx: int, _value: Variant):
	pass

func get_item_metadata(_index):
	pass

func selected():
	pass

func deselect():
	pass

func remove_item(_itemstack):
	pass
