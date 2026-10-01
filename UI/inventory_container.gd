#@tool
extends Control
class_name InventoryContainer
# UI Controls

# UI Element to use, can become Grid style if needed or any other style. 
# Should this track its inventory position in the UI?: 
# No this shouldn't care where it is in the UI as long as it exists. 
# TODO: Do I need to separate UI and management logic? When is it used without the other?
# maybe to make it into a component.

@export var inventory_resource: InventoryResource

@export_category( "UI Elements")
@export var item_list: ItemList 
@export var gold_label: Label

# Variables 
var new_items: Array[ItemData] = [Items.ARMOR_BRONZE, Items.POTION, Items.POTION] # Default
var item_amount: int # Error checking 

func _ready() -> void:
	item_list.clear()
	item_list.item_clicked.connect(_on_item_clicked)

func _get_items_id():
	print(inventory_resource.get_item_id_in_inventory())

func add_all_items():
	### TODO: Change to system agnostic way to add to UI
	var list := inventory_resource.slots
	for i in list:
		if i != null:
			var item_name = i.get_id().capitalize()
			var item_value = i.get_base_value()
			var item_label : String = item_name + " : " + str(item_value) + " GP"
			
			# Testing metadata field: This seems to work better.
			item_list.add_item(item_label, i.get_texture(), true)
			item_list.set_item_metadata(item_list.get_item_count() - 1, i)
			item_list.deselect_all()

		
func list_items():
	print(inventory_resource.slots)

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
	#print("Add items func:", list_items())
	inventory_resource.add_item(item_stack)
	item_list.clear()
	add_all_items()
	pass

func remove_item(index):

	if item_list.item_count - 1 < index:
		index = 0
	var item_stack = item_list.get_item_metadata(index)
	
	inventory_resource.remove_item(item_stack)
	item_list.clear()
	add_all_items()

	return item_stack


func transfer_item(index):
	pass

# These should be combined somehow but I can't logic it :( 

func connect_signals(): # When the inventory resource gets updated, it updates the item count
	inventory_resource.item_removed.connect(get_item_amount)
	inventory_resource.item_added.connect(get_item_amount)		

func get_item_amount(slot: int):
	item_amount = slot
	return item_amount


func update_size():
	item_amount = inventory_resource.slots.size()

## Updates label to match inventory gold
func update_gold(gold):
	gold_label.text = "GOLD: " + str(gold)