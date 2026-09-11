@tool
class_name ItemStackUi
extends Panel

@onready var item_texture: TextureRect = $ItemTexture

### Needs to work with new items or created items to update the texture on the sprite

@export var item_stack: ItemStack:
	set(value):
		# print("Setting...")
		
		item_stack = value
		
		if value:
			if not value.changed.is_connected(_on_item_stack_changed):
				value.changed.connect(_on_item_stack_changed)
			
		# if value != null:
		# 	print("Item Stack is not null")
		# 	
		if value != null and value.data != null:
			# print("Item Stack and Item Data are not null")
			
			if not value.data.changed.is_connected(_on_item_data_changed):
				value.data.changed.connect(_on_item_data_changed)

			if value.data.texture != null: # works
				# print("Item Data has a texture:", value.data.texture)
				#print("UISTACK:", item_texture)
				update_texture()
				#item_texture.texture = value.data.texture

			else:
				value.data.changed.connect(_on_item_data_changed)
				value.changed.connect(_on_item_stack_changed)

		else:
			# print("Changing to Default Banana")
			item_texture.texture =  load("res://Art/items/Banana.png")

func _ready():
	update_texture()

func _on_item_data_changed():	
	# print("My ItemData just changed!")
	item_texture.texture =  item_stack.data.texture

func _on_item_stack_changed():
	if item_stack.data != null:
		item_texture.texture =  item_stack.data.texture
		if not item_stack.data.changed.is_connected(_on_item_data_changed):
			item_stack.data.changed.connect(_on_item_data_changed)
	# print("My ItemStack just changed!")

func update_texture():
	if not is_node_ready():
		return	
	item_texture.texture = item_stack.data.texture
