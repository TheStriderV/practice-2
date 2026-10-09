@tool
class_name ItemData
extends Resource

signal created

@export var id: String

#@export var display_name: String

@export var texture: Texture2D:
	set(value):
		texture = value
		# print("Item_D: Texture changed")
		changed.emit()

@export var max_stack: int = 1:
	set(value):
		max_stack = value
		# print("Item_D: Max Stack changed")
		changed.emit()

@export var base_value: int

@export var shape_data: ShapeData

func _init(p_id:String = "" ,p_texture: Texture2D = null, p_max_stack: int = 1,p_base_value: int = 0):
	id = p_id
	texture = p_texture
	max_stack = p_max_stack
	base_value = p_base_value
	created.emit()
	

func get_texture():
	return texture
