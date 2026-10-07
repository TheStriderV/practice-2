class_name ShapeLibrary
extends Resource

@export var shapes: Array[ShapeData] = []

func get_shape(id: int) -> ShapeData:
	for shape in shapes:
		if shape.id == id:
			return shape
	return null
