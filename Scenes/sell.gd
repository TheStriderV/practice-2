extends Control


@onready var inventory_container: Control = $VBoxContainer/InventoryContainer
@onready var player_item_list: ItemList = $VBoxContainer/PlayerInventoryContainer/CenterContainer/VBoxContainer/ItemList
@onready var npc_item_list: ItemList = $VBoxContainer/InventoryContainer/CenterContainer/VBoxContainer/ItemList


@onready var player_inventory_container: Control = $VBoxContainer/PlayerInventoryContainer
@onready var player_gold_text: Label = $VBoxContainer/PlayerGold

@onready var button_1: Button = $VBoxContainer/HBoxContainer/Button1
@onready var button_2: Button = $VBoxContainer/HBoxContainer/Button2
@onready var button_3: Button = $VBoxContainer/HBoxContainer/Button3


# TODO: Move to player data global; testing only 
@export var player_gold : int = 100

var item_index

func _ready() -> void:
	# Label Test
	player_gold_text.text = "Player Gold = " + str(player_gold)
	# Buy Button
	button_3.pressed.connect(_buy_item)
	
	player_item_list.item_selected.connect(_item_index)
	npc_item_list.item_selected.connect(_item_index)
	
func _buy_item(): 
	# Maybe update this to target and source so can be used for both buy and sell.
	
	if item_index != null:
		if inventory_container.item_amount > 0:
			var item_stack = inventory_container.remove_item(item_index)
			#print_debug("Buying... Item Stack: ", item_stack.get_id())
			player_inventory_container.add_item(item_stack)
		else:
			return

func _item_index(index:int):
	item_index = index

	
	
	
