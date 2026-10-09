@tool
## Creates Grid Inventory, should expect a item handler in Parent root
class_name GridInventoryContainer
extends GridContainer

@export var item_handler : ItemHandler

@export var slot_amount : int = 30
@export var slot_size : int = 50:
	set(value):
		if slot_size != value:
			_update_slot_size(value)
			slot_size = value

@onready var slot_scene = preload("uid://dxvx2kwd2mv52")

signal grid_entered(grid)
signal grid_exited(grid)

signal item_picked_up(item)
signal item_placed()

var is_hovering := false
var grid_array := []
var item_
var current_slot = null
var can_place := false
var icon_anchor : Vector2
var drag_offset: Vector2 = Vector2.ZERO

var scaled_amount: Vector2

var slots := []

func _ready() -> void:
	if item_handler == null: # Find and attach handler
		item_handler = %ItemHandler		
		assert(item_handler != null, "Connect a item handler!")
		#print("No ItemHandler found!")
	
	if get_children().size() != 0:
		for child in get_children():
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

func create_slot(_size:int = 50):
	var new_slot = slot_scene.instantiate()
	
	new_slot.slot_ID = grid_array.size()
	slots.append(new_slot)
	grid_array.push_back(new_slot)
	add_child(new_slot)
	new_slot.custom_minimum_size = Vector2(_size, _size)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)
	#print("Slot size:", new_slot.size)
	#scaled_amount = new_slot.scaled_amount
	
func _update_slot_size(_size):
	for i in slots:
		i.custom_minimum_size = Vector2(_size, _size)
		
func _on_slot_mouse_entered(selected_slot):
	if Engine.is_editor_hint():
		return
	#emit_signal("grid_entered", self)
	icon_anchor = Vector2(1,1)
	current_slot = selected_slot
	if item_handler.item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
func _on_slot_mouse_exited(_a_Slot):
	if Engine.is_editor_hint():
		return
	#emit_signal("grid_exited", self)
	clear_grid()

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

func set_grids(_Slot):
	for grid in item_handler.item_held.item_grids:
		var grid_to_check = _Slot.slot_ID + grid[0] + grid[1] * columns
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		# Make sure the check don't wrap around boarders
		var line_switch_check = _Slot.slot_ID % columns + grid[0]
		if line_switch_check < 0 or line_switch_check >= columns:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			#save anchor for snapping
			if grid[1] < icon_anchor.x:
				icon_anchor.x = grid[1]
				

			if grid[0] < icon_anchor.y:

				icon_anchor.y = grid[0]
				
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func check_slot_availability(hovered_slot, _item_held = null):	
	for grid in item_handler.item_held.item_grids: # Checks the item grid against inv grid
		var grid_to_check = hovered_slot.slot_ID + grid[0] + grid[1] * columns
		var line_switch_check = hovered_slot.slot_ID % columns + grid[0]
		
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
			
func place_item(_item_held):
	if not can_place or not current_slot:
		return

	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * columns + icon_anchor.y
	if calculated_grid_id > grid_array.size()-1:
		push_error("Out of bounds")
		return	
	_item_held._snap_to(grid_array[calculated_grid_id].global_position)
	_item_held.global_position = get_global_mouse_position()# + item_held.drag_offset	
	_item_held.grid_anchor = current_slot
	for grid in _item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * columns
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = _item_held
		

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
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * columns
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null
		
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	
func rotate_item(_item_held):
	_item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)

func check_if_grid_in_grid():
	return get_global_rect().has_point(get_global_mouse_position())

func clear():
	pass

func set_item_metadata(idx: int, value: Variant):	
	pass

func get_item_metadata(index):
	pass
func selected():
	
	pass

func deselect():
	pass

func remove_item(itemstack):
	pass
