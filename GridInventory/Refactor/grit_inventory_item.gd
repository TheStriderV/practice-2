class_name GritInventoryItem
extends Node2D
## This only cares about its texture and where it is. 
## TODO: Maybe layer two GridContainers on top of each other?

# @export var shape_library : ShapeLibrary # Change this to itemdata?
@onready var item_texture:= $Icon

@export_category("Inventory")

## Default testing resource - TODO: Should remove 
@export var inventory_resource: InventoryResource 

const GRID_FILL_INVENTORY_EXAMPLE = preload("uid://1fvi2rdvgpn4")

var item_stack : ItemStack

## Item Shape data: Ex: [(0,0),(0,1)]
var item_grids := [] # Projected Item Grid 

var selected := false:
	set(value):
		# 1. Do nothing if the state didn't actually change
		if value == selected: return
		selected = value
		if selected:
			held.emit(self)
			grid_anchor = null
		else:
			unheld.emit(self)

			
			
var grid_anchor = null


var item_owner : String = "None"

signal held(item)
signal unheld(item)

func _ready() -> void:
	if inventory_resource == null:
		inventory_resource = GRID_FILL_INVENTORY_EXAMPLE

func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) # Drag offset can go here

## Pulls data from own resource if none is passed in
func load_item_stack(_item_stack_id : String, _inventory_resource : InventoryResource = inventory_resource) -> void:
	var new_item_stack := _inventory_resource.get_item(_item_stack_id)
	item_texture.texture = new_item_stack.get_texture()
	item_grids = new_item_stack.data.shape_data.offsets
	item_stack = new_item_stack
	

func rotate_item():
	var rotated_offsets: Array[Vector2i] = []
	for offset in item_grids:
		# 90 degree rotation around (0,0): (x, y) -> (-y, x)
		rotated_offsets.append(Vector2i(-offset.y, offset.x))
	item_grids = rotated_offsets
	rotation_degrees += 90
	if rotation_degrees >= 360:
		rotation_degrees = 0

func _snap_to(destination:Vector2):
	var tween: Tween = get_tree().create_tween()
	if int(rotation_degrees) % 180 == 0:
		var test_vector := _get_item_grid_size()/2
		destination += test_vector
		
	else:
		var test_vector_2 := _get_item_grid_size()/2
		destination += test_vector_2
		
	tween.tween_property(self, "global_position", destination, .15).set_trans(Tween.TRANS_SINE)
	selected = false

## Returns the grid size to use in centering in _snap_to
func _get_item_grid_size(scale_amount: int = 50) -> Vector2:
	if item_grids.is_empty():
		return Vector2.ZERO

	var min_pos: Vector2 = item_grids[0]
	var max_pos: Vector2 = item_grids[0]
	for grid in item_grids:
		min_pos = min_pos.min(grid)
		max_pos = max_pos.max(grid)

	return (max_pos - min_pos + Vector2.ONE) * scale_amount
	
func get_item_stack():
	return item_stack

func set_item_owner(new_item_owner : String):
	item_owner = new_item_owner

func clear():
	queue_free()
