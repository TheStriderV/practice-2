## Used for Grid Inventory Container Slots
class_name ShapeData
extends Resource

## Used for the ShapeLibrary
@export var id: int

## Grid data offsets
@export var offsets: Array[Vector2i] = []

## Default Icon - Used for debugging only
@export var debug_icon: Texture2D

## Hide the debug icon when the game is running
@export var clear_icon_on_load: bool = false

var icon: Texture2D:
	get:
		if clear_icon_on_load and not Engine.is_editor_hint():
			return null
		return debug_icon
		
@export var rotated: bool = false: 
	set(value):
		rotated = value
		if value:
			rotate_offsets_90()

func rotate_offsets_90() -> void:
	var rotated_offsets: Array[Vector2i] = []
	for offset in offsets:
		# 90 degree rotation around (0,0): (x, y) -> (-y, x)
		rotated_offsets.append(Vector2i(-offset.y, offset.x))
	offsets = rotated_offsets

func clear_icon()-> void:
	icon = null
