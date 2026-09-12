@tool
class_name ItemStack
extends Resource

#const ItemData:ItemData = preload("res://Items/Resources/item_data.gd")

@export var data: ItemData:
	set(value):
		#print("Data changed" if value.id != null else "null")
		data = value
		# print(value)
		changed.emit()

@export var quantity: int = 1:
	set(value):
		quantity = value
		changed.emit()
		# print("Quantity changed to " + str(quantity))
		
@export var instance_data: Dictionary = {}  # durability, sockets, etc.

func _init(p_data: ItemData = null, p_quantity: int = 1):
	data = p_data
	quantity = p_quantity
	

func increase_quantity(p_amount: int):
	if quantity + p_amount > data.max_stack:
		quantity += p_amount
	else:
		print_debug("Stack Overflow")
	
func get_id():
	return data.id

func get_texture():

	if data:
		#print("Data available")
		return data.texture
	else:
		return null
	
