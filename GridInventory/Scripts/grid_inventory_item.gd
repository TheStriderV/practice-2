extends Node2D

@export var shape_library : ShapeLibrary # Change this to itemdata?

@onready var IconRect_path = $Icon

var item_ID: int
var item_grids := [] # Projected Item Grid 
var selected = false
var grid_anchor = null
var drag_offset: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) # Drag offset can go here

func load_item(a_ItemID:int) -> void:
	var Icon_path = shape_library.get_shape(a_ItemID)
	IconRect_path.texture = Icon_path.icon
	item_grids = Icon_path.offsets

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
	var tween = get_tree().create_tween()
	if int(rotation_degrees) % 180 == 0:
		destination += IconRect_path.size/2
	else:
		var temp_xy_switch = Vector2(IconRect_path.size.y, IconRect_path.size.x)
		destination += temp_xy_switch/2
	tween.tween_property(self, "global_position", destination, .15).set_trans(Tween.TRANS_SINE)
	selected = false
