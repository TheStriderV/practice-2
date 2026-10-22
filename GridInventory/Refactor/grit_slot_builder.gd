class_name GritSlotBuilder
extends GridContainer
# GritSlotBuilder
## GRIT: GRid InvenTory for short.
## Builds and manages Grid_Array and Slot_ID
## Sends signals when mouse is entered. 
## Each slot keeps track of what's in it and what color it should be

@export var slot_amount : int = 30
@export var slot_size : int = 50

@onready var slot_scene = preload("uid://dxvx2kwd2mv52")


var grid_array := []

signal hovered_slot(slot)
signal grid_entered(grid)

func _ready() -> void:
	# Deletes Debug slots to start new
	if get_children().size() != 0:
		for child in get_children():
			if child is GridInventorySlot:
				child.queue_free()

	# Creates slots
	for i in range(slot_amount):
		create_slot(slot_size)

## Slot Creation
func create_slot(_size:int = 50):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot) #
	add_child(new_slot) # TODO: Add as child to GridContainer
	new_slot.custom_minimum_size = Vector2(_size, _size)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(selected_slot):
	if Engine.is_editor_hint():
		return
	P.log("Mouse entered slot: " + str(selected_slot.slot_ID))
	hovered_slot.emit(selected_slot)
	grid_entered.emit(self)
	
	
	
	# #emit_signal("grid_entered", self)
	# icon_anchor = Vector2(0,0)
	# current_slot = selected_slot
	# hovered_slot.emit(current_slot)
	# if item_handler.item_held:
	# 	check_slot_availability(current_slot, item_handler.item_held)
	# 	set_grids.call_deferred(current_slot, item_handler.item_held)
	# 	pass

func _on_slot_mouse_exited(selected_slot):
	if Engine.is_editor_hint():
		return
	clear_grid()

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)
		
