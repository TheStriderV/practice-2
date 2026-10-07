class_name GridInventory
extends GridContainer

#@export var grid_container : GridContainer
@export var slot_amount : int = 30
@export_category("Inputs")
#@export var mouse_right : InputEventAction
#@export var mouse_left : InputEventAction

@onready var slot_scene = preload("uid://dxvx2kwd2mv52")
@onready var item_scene = preload("uid://bs6djdnvwyvox")

signal grid_entered(grid)
signal grid_exited(grid)

signal item_picked_up(item)

var item_held = null

var is_hovering := false
var grid_array := []

var current_slot = null
var can_place := false
var icon_anchor : Vector2
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if get_children().size() != 0:
		for child in get_children():
			child.queue_free()
	for i in range(slot_amount):
		create_slot()
			
func _process(_delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			emit_signal("grid_entered", self)
	else:
		if is_hovering:
			is_hovering = false
			emit_signal("grid_exited",self)

func create_slot():
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)
	
func _on_slot_mouse_entered(a_Slot):
	#emit_signal("grid_entered", self)
	icon_anchor = Vector2(10000,100000)
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
func _on_slot_mouse_exited(_a_Slot):
	#emit_signal("grid_exited", self)
	clear_grid()

func check_slot_availability(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * columns
		var line_switch_check = a_Slot.slot_ID % columns + grid[0]
		
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

func set_grids(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * columns
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		# Make sure the check don't wrap around boarders
		var line_switch_check = a_Slot.slot_ID % columns + grid[0]
		if line_switch_check < 0 or line_switch_check >= columns:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			#save anchor for snapping
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
				
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)
		
func place_item():
	if not can_place or not current_slot:
		return
		
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * columns + icon_anchor.y
	item_held._snap_to(grid_array[calculated_grid_id].global_position)
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()# + item_held.drag_offset
	
	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * columns
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = item_held
	item_held = null
	clear_grid()

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	
	#add_child(item_held)
	item_picked_up.emit(item_held)

	item_held.global_position = get_global_mouse_position() 
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * columns
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null
		
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	
func rotate_item():
	item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)
