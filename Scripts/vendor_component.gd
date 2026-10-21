class_name VendorComponent
extends Control

@export var inventory_container : GridInventoryContainer

@export var buy_button : Button
@export var sell_button : Button

## Label for updating the gold amount
@export var buy_label : Label
@export var sell_label : Label

@onready var player_grid_inventory_container: GridInventoryContainer = %PlayerGridInventoryContainer
@onready var npc_grid_inventory_container: GridInventoryContainer = %NPCGridInventoryContainer

signal item_sold(item)



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
	buy_button.pressed.connect(_on_vendor_button_pressed.bind("Player"))
	# Transfer from Player to NPC
	sell_button.pressed.connect(_on_vendor_button_pressed.bind("Npc"))
	
	
	buy_button.pressed.connect(update_worth)
	sell_button.pressed.connect(update_worth)
	
	inventory_container.item_picked_up.connect(update_worth)
	inventory_container.item_placed.connect(update_worth)

## For both buy and sell buttons, just changes the owner, either "Player" , "Npc", or "None"
func _on_vendor_button_pressed(new_owner:String):
	var item_list = inventory_container.items_stored.duplicate() # Duplicate or else it doesn't loop as it modifies the list during the loop
	for item in item_list:
		var value = item.item_stack.get_base_value()

		if item.item_owner == new_owner: # Skips items that are not meant to be transferred 
			continue
		
		if new_owner == "Npc":
			if value > npc_grid_inventory_container.inventory.get_gold():
				P.log("Not enough gold")
				return
			P.p(new_owner)
			var available_slot = npc_grid_inventory_container.check_next_available_slot(item)
			
			if available_slot != null:
			
				item.set_item_owner(new_owner)
				inventory_container.remove_item_from_inventory(item)
				player_grid_inventory_container.remove_item_from_inventory(item)
				npc_grid_inventory_container.place_item(item, available_slot)
				
				npc_grid_inventory_container.inventory.remove_gold(value)
				player_grid_inventory_container.inventory.add_gold(value)
				
				item_sold.emit(item)

		if new_owner == "Player":
			if value > player_grid_inventory_container.inventory.get_gold():
				P.log("Not enough gold")
				return
			var available_slot = player_grid_inventory_container.check_next_available_slot(item)
			if available_slot != null:
				
				item.set_item_owner(new_owner)
				inventory_container.remove_item_from_inventory(item)
				npc_grid_inventory_container.remove_item_from_inventory(item)
				player_grid_inventory_container.place_item(item, available_slot)
				
				player_grid_inventory_container.inventory.remove_gold(value)
				npc_grid_inventory_container.inventory.add_gold(value)
				item_sold.emit(item)

func update_worth():
	sell_label.text = str(inventory_container.get_container_worth("Player"))
	buy_label.text = str(inventory_container.get_container_worth("Npc"))
		
	
	
