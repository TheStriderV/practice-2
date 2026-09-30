@tool
extends Control


@export var inventory: InventoryResource


# UI Controls

# UI Element to use, can become Grid style if needed or any other style. 
# Should this track its inventory position in the UI?: 
# No this shouldn't care where it is in the UI as long as it exists. 
# TODO: add_item()
@onready var item_list: ItemList = $CenterContainer/VBoxContainer/ItemList

var item_index: Dictionary = {}

var new_items: Array[ItemData] = [Items.ARMOR_BRONZE, Items.POTION, Items.POTION]

var item_amount: int

func _ready() -> void:
	
	# # Creates new Inventory resource and fills it with the items
	# if inventory == null:
	# 	print("Not null")
	# 	inventory = InventoryResource.new(new_items)
	# 	
	# 
	
	#print("Null")
	item_list.clear()
	# Buttons

	#Item List
	item_list.item_clicked.connect(_on_item_clicked)
	#item_list.item_selected.connect(_test_func)
	#add_all_items()
	#print(inventory.slots)
	
	
func get_item_amount(slot: int):
	#print("SLOTS LEFT!!!! ", slot)
	item_amount = slot
	return item_amount


func _get_items_id():
	print(inventory.get_item_id_in_inventory())

func add_all_items():
	### TODO: Change to system agnostic way to add to UI
	var list := inventory.slots
	for i in list:
		# Adds index to dictionary paired with itemstack object
		#item_index[item_list.add_item(i.get_id().capitalize(), i.get_texture())] = i
		
		# Testing metadata field: This seems to work better.
		item_list.add_item(i.get_id().capitalize(), i.get_texture(), true)
		item_list.set_item_metadata(item_list.get_item_count() - 1, i)
		item_list.deselect_all()
		
	#item_list.item_selected.connect(_test_func)
		#print("Item Metadata: ", item_list.get_item_metadata(item_list.get_item_count() - 1))
		
func list_items():
	print(inventory.slots)

func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		print("Get item: ", item_list.get_item_metadata(index).get_id())
		#print("Index: ", index)
	if mouse_button_index == 2:
		remove_item(index)
	
func _return_last_item_index(index: int, at_position: Vector2, mouse_button_index: int):
	return item_list.get_item_metadata(index)
	
	
func update_position():
	pass

func add_item(item_stack: ItemStack):
	inventory.add_item(item_stack)
	item_list.clear()
	add_all_items()
	pass

func remove_item(index):
	var item_stack = item_list.get_item_metadata(index)
	inventory.remove_item(item_list.get_item_metadata(index))
	item_list.clear()
	add_all_items()
	return item_stack


func transfer_item(index):
	pass

func connect_signals():
	inventory.item_removed.connect(get_item_amount)

func update_size():
	item_amount = inventory.slots.size()