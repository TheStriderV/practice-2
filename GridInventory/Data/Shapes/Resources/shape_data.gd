class_name ShapeData
extends Resource

@export var id: int
@export var offsets: Array[Vector2i] = []
@export var icon: Texture2D

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
