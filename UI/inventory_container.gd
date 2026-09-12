@tool
extends Control


@export var inventory: InventoryResource


# UI Controls
@onready var print_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/PrintButton
@onready var button_2: Button = $CenterContainer/VBoxContainer/HBoxContainer/Button2

# UI Element to use, can become Grid style if needed or any other style. 
# Should this track its inventory position in the UI?: 
# No this shouldn't care where it is in the UI as long as it exists. 
# TODO: add_item()
@onready var item_list: ItemList = $CenterContainer/VBoxContainer/ItemList

var item_index: Dictionary = {}

var new_items: Array[ItemData] = [Items.ARMOR_BRONZE, Items.POTION, Items.POTION]


func _ready() -> void:
	# Creates new Inventory resource and fills it with the items
	if inventory == null:
		print("Not null")
		inventory = InventoryResource.new(new_items)
		
	
	
	print("Null")
	item_list.clear()
	# Buttons
	print_button.pressed.connect(_get_items_id)
	button_2.pressed.connect(list_items)
	
	#Item List
	item_list.item_clicked.connect(_on_item_clicked)
	add_all_items()
	print(inventory.slots)
	
	

func _get_items_id():
	print(inventory.get_item_id_in_inventory())

func add_all_items():
	var list := inventory.slots
	for i in list:
		# Adds index to dictionary paired with itemstack object
		#item_index[item_list.add_item(i.get_id().capitalize(), i.get_texture())] = i
		
		# Testing metadata field: This seems to work better.
		item_list.add_item(i.get_id().capitalize(), i.get_texture())
		item_list.set_item_metadata(item_list.get_item_count() - 1, i)
		print("Item Metadata: ", item_list.get_item_metadata(item_list.get_item_count() - 1))
		
func list_items():
	print(inventory.slots)

func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		print("Get item: ", item_list.get_item_metadata(index).get_id())
	if mouse_button_index == 2:
		remove_item(index)
	
		
	
	
func update_position():
	pass

func add_item(item_stack: ItemStack):
	pass

func remove_item(index):
	inventory.remove_item(item_list.get_item_metadata(index))
	item_list.remove_item(index)
	print("Inventory list: ", inventory.slots) 


func transfer_item(index):
	pass
