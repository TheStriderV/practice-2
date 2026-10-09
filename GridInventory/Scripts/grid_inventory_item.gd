class_name GridInventoryItem
extends Node2D



@export var shape_library : ShapeLibrary # Change this to itemdata?
@onready var grid_item_texture_path:= $Icon

@export_category("Inventory")
@export var inventory_resource: InventoryResource


var item_stack : ItemStack
var item_shape: ShapeData:
	get:
		if item_stack == null:
			return null
		return item_stack.item_data.shape_data
	
var item_ID: int
var item_grids := [] # Projected Item Grid 
var selected := false
var grid_anchor = null
var drag_offset: Vector2 = Vector2.ZERO
	
func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) # Drag offset can go here

func load_item(_ItemID:int) -> void:
	var Icon_path = shape_library.get_shape(_ItemID)
	grid_item_texture_path.texture = Icon_path.icon
	item_grids = Icon_path.offsets

func load_item_stack(_item_stack_id : String) -> void:
	var texture_path = inventory_resource.get_item(_item_stack_id)
	grid_item_texture_path.texture = texture_path.get_texture()
	item_grids = texture_path.data.shape_data.offsets

	
	

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


func _get_item_grid_size(scale_amount: int = 50) -> Vector2:
	if item_grids.is_empty():
		return Vector2.ZERO

	var min_pos: Vector2 = item_grids[0]
	var max_pos: Vector2 = item_grids[0]
	for grid in item_grids:
		min_pos = min_pos.min(grid)
		max_pos = max_pos.max(grid)

	return (max_pos - min_pos + Vector2.ONE) * scale_amount
