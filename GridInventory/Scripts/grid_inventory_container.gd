## Creates Grid Inventory, should expect a item handler in Parent root
class_name GridInventoryContainer
extends GridContainer

@export var item_handler : ItemHandler

@export var slot_amount : int = 30
@export var slot_size : int = 50

@onready var slot_scene = preload("uid://dxvx2kwd2mv52")

@export var inventory : Inventory

@onready var item_scene := preload("uid://bs6djdnvwyvox")

signal grid_entered(grid)
signal grid_exited(grid)

signal item_picked_up(item)
signal item_placed()

signal hovered_slot(slot)

var is_hovering := false
var grid_array := []

var current_slot = null

var icon_anchor : Vector2 = Vector2.ZERO

## For uncentering to cursor; unused currently
var drag_offset: Vector2 = Vector2.ZERO 

## Unused: for scaling whole inventory; right now it's a set amount
var scaled_amount: Vector2

var items_stored# : Array[]
var taken_slots = 0

func _ready() -> void:
	# Find and attach handler
	if item_handler == null: 
		item_handler = %ItemHandler
		assert(item_handler != null, "Connect or add a item handler!")
	
	if has_node("Inventory"):
		if get_child(0) is Inventory:
			inventory = get_child(0)
			P.p(inventory.list)
	else:
		print_rich("test")
		pass
	
	# Deletes Debug slots to start new
	if get_children().size() != 0:
		for child in get_children():
			if child is GridInventorySlot:
				child.queue_free()
				
	# Creates slots
	for i in range(slot_amount):
		create_slot(slot_size)
		
	await get_tree().process_frame
	# Creates items, if any
	#if inventory:
		#place_all_items(inventory.list, true)
	
	# Test creating an item and placing at slot 0
	var new_item_potion = create_item("potion")
	place_item(new_item_potion, grid_array[0])
	
func _process(_delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			grid_entered.emit(self)
			
	else:
		if is_hovering:
			is_hovering = false
			grid_exited.emit(self)


func _on_slot_mouse_entered(selected_slot):
	if Engine.is_editor_hint():
		return
	#emit_signal("grid_entered", self)
	icon_anchor = Vector2(0,0)
	current_slot = selected_slot
	hovered_slot.emit(current_slot)
	if item_handler.item_held:
		check_slot_availability(current_slot, item_handler.item_held)
		set_grids.call_deferred(current_slot, item_handler.item_held)
		pass

func _on_slot_mouse_exited(selected_slot):
	if Engine.is_editor_hint():
		return
	clear_grid()
	
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

## Creates a new item and returns it
func create_item(item) -> GridInventoryItem:
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item_stack(item)
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
	for offset in item.item_grids:
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
		else:
			target.set_color(target.States.TAKEN)


func place_item(item: Node, slot: GridInventorySlot): # TODO: Switch vars after refactor
	if not check_slot_availability(slot, item):
		return 
	var grid_id = slot.slot_ID + icon_anchor.x * columns + icon_anchor.y #
	if grid_id > grid_array.size()-1:
		push_error("Out of bounds")
		return
	
	
	item._snap_to(grid_array[grid_id].global_position)
	item.grid_anchor = slot

	set_slots_state(item, GridInventorySlot.States.TAKEN)
	clear_grid()
	
	item_placed.emit()
	


	return true

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	var item_held : Node = current_slot.item_stored
	item_held.selected = true
	item_held.reparent(item_handler.get_parent())

	item_picked_up.emit(item_held)

	item_handler.item_held.global_position = get_global_mouse_position()

	set_slots_state( item_held, GridInventorySlot.States.FREE)

	
	check_slot_availability(current_slot, item_handler.item_held)
	set_grids.call_deferred(current_slot, item_handler.item_held)
	


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
func place_all_items(_inventory: Array, random : bool = false):
	var inv_list : Array = _inventory
	if random:
		inv_list.shuffle() 
	for item in inv_list:
		var new_item = create_item(item.get_id())
		
		for slot in grid_array:
			
			#print("Slot: ", slot.slot_ID)
			var placed_item = place_item(new_item, slot)
			if placed_item == null:
				continue
			print(placed_item)
			break
		
		if new_item.grid_anchor == null:
			new_item.queue_free()

func clear():
	taken_slots = 0
	pass

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
