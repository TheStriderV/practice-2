## Creates Grid Inventory, should expect a item handler in Parent root
class_name GridInventoryContainer
extends GridContainer

@export var item_handler : ItemHandler

@export var slot_amount : int = 30
@export var slot_size : int = 50
	#set(value):
	#	if slot_size != value:
	#		_update_slot_size(value)
	#		slot_size = value

@onready var slot_scene = preload("uid://dxvx2kwd2mv52")

@export var _inventory_example : Inventory

@onready var item_scene := preload("uid://bs6djdnvwyvox")

signal grid_entered(grid)
signal grid_exited(grid)

signal item_picked_up(item)
signal item_placed()

var is_hovering := false
var grid_array := []

var current_slot = null
var can_place := false
var icon_anchor : Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO

var scaled_amount: Vector2

var items_stored# : Array[]
var taken_slots = 0

func _ready() -> void:
	#print(4 % 3)
	#print("inventory", _inventory_example)
	if item_handler == null: # Find and attach handler
		item_handler = %ItemHandler		
		assert(item_handler != null, "Connect a item handler!")
		#print("No ItemHandler found!")
	
	if get_children().size() != 0:
		for child in get_children():
			if child is GridInventorySlot:			
				child.queue_free()
	for i in range(slot_amount):
		create_slot(slot_size)
			
func _process(_delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			grid_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			grid_exited.emit(self)

###  TODO: DEBUGGING ONLY : REMOVE



func check_all_slots():
	for slot in grid_array:
		print("Slot ID:", slot.slot_ID)
		print("Slot Stored:", slot.item_stored)


func create_slot(_size:int = 50):
	var new_slot = slot_scene.instantiate()
	
	new_slot.slot_ID = grid_array.size()

	grid_array.push_back(new_slot)
	add_child(new_slot)
	new_slot.custom_minimum_size = Vector2(_size, _size) 
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)
	#print("Slot size:", new_slot.size)
	#scaled_amount = new_slot.scaled_amount
	
#func _update_slot_size(_size):
#	for i in slots:
#		i.custom_minimum_size = Vector2(_size, _size)
		
func _on_slot_mouse_entered(selected_slot):
	if Engine.is_editor_hint():
		return
	#emit_signal("grid_entered", self)
	icon_anchor = Vector2(0,0)
	current_slot = selected_slot
	if item_handler.item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
func _on_slot_mouse_exited(_a_Slot):
	if Engine.is_editor_hint():
		return
	clear_grid()

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)	

func set_grids(_grid_inventory_slot : GridInventorySlot):
	for grid in item_handler.item_held.item_grids: # Ex: (0,0),(0,1)
		var grid_to_check = _grid_inventory_slot.slot_ID + grid[0] + (grid[1] * columns)		
		# Check if inside grid
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
			
		var line_switch_check = _grid_inventory_slot.slot_ID % columns + grid[0]
		# Make sure the check don't wrap around boarders
		if line_switch_check < 0 or line_switch_check >= columns:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			# Save anchor for snapping
			if grid[1] < icon_anchor.x:
				icon_anchor.x = grid[1]
				
			if grid[0] < icon_anchor.y:
				icon_anchor.y = grid[0]

		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func check_slot_availability(hovered_slot, _item_held = null):	
	
	for grid in item_handler.item_held.item_grids: # Checks the item grid against inv grid - offset grid
		var grid_to_check = hovered_slot.slot_ID + grid[0] + (grid[1] * columns)		
		#print("slot_ID: ", hovered_slot.slot_ID, " grid(x,y): (", grid[0]," , ", grid[1], ") columns: ", columns, " result: ", grid_to_check)
		var line_switch_check = hovered_slot.slot_ID % columns + grid[0] # Ex:  6 % 5 + (0,0) = 
		
		if line_switch_check < 0 or line_switch_check >= columns:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
			
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return

	can_place = true
	return can_place

# func check_slot_availability_all(inventory: Inventory)-> Dictionary:
# 	var can_place_item : bool = true
# 	var slot_array_check := {}
# 	for item in inventory.list:
# 		for slots in grid_array:
# 			if slots.item_stored:
# 				#print("Slot ID:", slots.slot_ID)				
# 				#print("Item stored: ", slots.item_stored)
# 				can_place_item = false
# 				slot_array_check[slots.slot_ID] = can_place_item
# 				#print("Can place: ", can_place_item)
# 			else:
# 				can_place_item = true
# 				slot_array_check[slots.slot_ID] = can_place_item
# 		return slot_array_check 

func check_slot_availability_simple() -> Dictionary:
	var slot_array_check := {}
	for slot in grid_array:
		slot_array_check[slot.slot_ID] = slot.item_stored == null
	return slot_array_check
	
func check_slot_availability_all(inventory: Inventory) -> Dictionary:
	var results := {}
	for item in inventory.list:
		var free_slots := {}
		for slot in grid_array:
			free_slots[slot.slot_ID] = slot.item_stored == null
		results[item] = free_slots
	return results
	
func place_all_items(_inventory: Inventory, _test_item = null):
	if taken_slots >= grid_array.size():
		print("Not enough slots!")
		return
	for item in _inventory.list:
		print("Placing item: ", item.get_id())
		var new_item = create_item(item.get_id()) #need to maybe do this later
		print("GRID ARRAY SIZE:", grid_array.size())
		for slot in grid_array:			
			var can_be_placed : bool = true
			print("START OF SLOT:", slot.slot_ID)
			
				
				
			var is_slot_taken = slot.is_item_stored()
			if is_slot_taken: # If taken, check next slot
				print("Slot is taken")
				continue
			else:				
				for grid in new_item.item_grids: # Check item grid shape if other slots are take
					
					print("Checking grid: ", grid)
					var grid_to_check = slot.slot_ID + grid[0] + (grid[1] * columns)
					var line_switch_check = slot.slot_ID % columns + grid[0]
					var calculated_grid_id = slot.slot_ID + (icon_anchor.x * columns) + icon_anchor.y
					if grid[1] < icon_anchor.x:
						icon_anchor.x = grid[1]

					if grid[0] < icon_anchor.y:
						icon_anchor.y = grid[0]
					
					if calculated_grid_id > grid_array.size()-1:
						push_error("Out of bounds")
						can_be_placed = false
						print("Calculated grid ID: ", calculated_grid_id)
						break
					if line_switch_check < 0 or line_switch_check >= columns:
						print("Line switch check: ", line_switch_check, " >= ", columns)
						can_be_placed = false
						break
					if grid_to_check < 0 or grid_to_check >= grid_array.size():
						can_be_placed = false
						print("Grid to check: ", grid_to_check)
						break
					
			#print("Grid anchor: ", new_item.grid_anchor)
			if can_be_placed == false:
				
				print("Cannot be placed, deleting: " , item.get_id())
				new_item.queue_free()
				#print("ANCHOR:", new_item.grid_anchor)
				can_be_placed = true
				continue # Can't be placed so go to next slot
			print("Snapping to: ", grid_array[slot.slot_ID].global_position )
			new_item._snap_to(grid_array[slot.slot_ID].global_position)
			
			for grid in new_item.item_grids:
				var grid_to_check = slot.slot_ID + grid[0] + (grid[1] * columns)
				print("SECOND GRID TO CHECK: ", grid_to_check)
				grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
				grid_array[grid_to_check].item_stored = new_item
				new_item.grid_anchor = slot
				taken_slots += 1
				print("THIS IS MARKED TAKEN: ", grid_array[grid_to_check].item_stored)
				print("turning slots to taken")
			
			print("Item Placed!")
			print("END OF SLOT:", slot.slot_ID)
			print("Grid anchor: ", new_item.grid_anchor)
			break
		print("Hello?")
		print("Grid anchor: ", new_item.grid_anchor)
		if new_item.grid_anchor == null:
			print("Item not placed!")
			new_item.queue_free()
		
		


func create_item(item):
	var new_item = item_scene.instantiate()
	add_child(new_item)	
	new_item.load_item_stack(item)
	return new_item
	
func place_item(_item_held, _current_slot = null):
	if not can_place or not current_slot:
		return

	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * columns + icon_anchor.y
	if calculated_grid_id > grid_array.size()-1:
		push_error("Out of bounds")
		return	
	_item_held._snap_to(grid_array[calculated_grid_id].global_position)
	#_item_held.global_position = get_global_mouse_position()# + item_held.drag_offset	
	_item_held.grid_anchor = current_slot
	
	mark_slots_taken(_item_held)		

	clear_grid()
	item_placed.emit()
	taken_slots += 1
	return true
	
func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	var item_held : Node = current_slot.item_stored
	item_held.selected = true
	item_held.reparent(item_handler.get_parent())	

	item_picked_up.emit(item_held)

	item_handler.item_held.global_position = get_global_mouse_position() 
	
	mark_slots_free(item_held)
	taken_slots -= 1
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	
func mark_slots_taken(_item_held) -> void:
	for grid in _item_held.item_grids: # Turn slots to held
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * columns
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = _item_held

func mark_slots_free(_item_held) -> void:
	print(_item_held)
	for grid in _item_held.item_grids: # Free Slots
		var grid_to_check = _item_held.grid_anchor.slot_ID + grid[0] + grid[1] * columns
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null	
		
func rotate_item(_item_held):
	_item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)

func check_if_grid_in_grid():
	return get_global_rect().has_point(get_global_mouse_position())



func clear():
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
