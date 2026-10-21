extends Control

@export var inventory_container : GridInventoryContainer

@export var buy_button : Button
@export var sell_button : Button

@export var buy_label : Label

@export var sell_label : Label

@onready var customer_grid_inventory_container: GridInventoryContainer = %CustomerGridInventoryContainer
@onready var player_grid_inventory_container: GridInventoryContainer = %PlayerGridInventoryContainer

var buy_display_amount : int = 0:
	set(value):
		buy_display_amount = value
		if buy_display_amount < 0:
			buy_display_amount = 0
			
var sell_display_amount: int = 0:
	set(value):
		sell_display_amount = value
		if sell_display_amount < 0:
			sell_display_amount = 0

func _ready() -> void:
	buy_label.text = "0"
	sell_label.text = "0"
	
	# Transfer from NPC to Player
	buy_button.pressed.connect(_on_button_pressed.bind("Player"))
	# Transfer from Player to NPC
	sell_button.pressed.connect(_on_button_pressed.bind("Npc"))
	
	
	buy_button.pressed.connect(update_worth)
	sell_button.pressed.connect(update_worth)
	
	inventory_container.item_picked_up.connect(update_worth)
	inventory_container.item_placed.connect(update_worth)


func _on_button_pressed(new_owner:String):
	var item_list = inventory_container.items_stored
	print("Item list size: ", item_list.size())
	for item in item_list:
		P.p(inventory_container.items_stored)
		if item.item_owner == new_owner:
			print("1")
			continue
		
		if new_owner == "Npc":
			P.p(new_owner)
			var available_slot = customer_grid_inventory_container.check_next_available_slot(item)
			
			if available_slot != null:
				print("PLACING")
				item.set_item_owner(new_owner)
				inventory_container.remove_item_from_inventory(item)
				customer_grid_inventory_container.place_item(item, available_slot)

		if new_owner == "Player":
			var available_slot = player_grid_inventory_container.check_next_available_slot(item)
			if available_slot != null:
				print("PLACING")
				item.set_item_owner(new_owner)
				inventory_container.remove_item_from_inventory(item)
				player_grid_inventory_container.place_item(item, available_slot)

func update_worth():
	sell_label.text = str(inventory_container.get_container_worth("Player"))
	buy_label.text = str(inventory_container.get_container_worth("Npc"))
		
	
	
