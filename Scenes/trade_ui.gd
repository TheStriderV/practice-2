class_name TradeUI
extends Control

@export_category( "Transfer Area")
@export var transfer_area: Area2D

@export_category( "UI Containers")
@export var npc_inventory_container: InventoryContainer
@export var player_inventory_container: InventoryContainer


# Buttons
@export_category( "Buttons")
@export var button_1: Button
@export var button_2: Button
@export var button_3: Button

@onready var player: CharacterBody2D = $"../Player" # Dependency : Change to export?

@onready var player_inventory: Inventory = player.get_node("Inventory") # TODO: Add a player script for onready inventory node

var npc_inventory: Inventory

var item_index
func _ready() -> void:		
	# Button Connections
	# Sell Button 
	button_2.pressed.connect(_vendor_item.bind(npc_inventory_container, player_inventory_container))
	# Buy Button
	button_3.pressed.connect(_vendor_item.bind(player_inventory_container, npc_inventory_container))
	# Signal Connection
	npc_inventory_container.item_list.item_selected.connect(_item_index)
	player_inventory_container.item_list.item_selected.connect(_item_index)
	# Area Connection
	transfer_area.body_entered.connect(_on_area_2d_body_entered)
	# Update Player UI Inventory
	update_player_ui_inventory()


func _item_index(index:int) -> void:
	item_index = index

## For a Buy + Sell Feature 
func _vendor_item(buyer, seller, gold_transfer:bool = true): # Use false for transferring of items in chests
	print("Vendoring Item")
	if gold_transfer:
		var item_stack_cost = seller.get_item_stack(item_index).get_base_value()
		if buyer.inventory_resource.get_gold() < item_stack_cost:
			print("Not enough gold to buy item")
			return 
	if item_index != null:
		print("Item Index: ", item_index)
		
		if seller.item_amount > 0:
			var item_stack = seller.remove_item(item_index)	# Returns the item stack			
			print("Item Stack Cost: ", item_stack.get_base_value())			
			buyer.add_item(item_stack)
			if gold_transfer:
				print("Transfering Gold")
				seller.inventory_resource.add_gold(item_stack.get_base_value())
				buyer.inventory_resource.remove_gold(item_stack.get_base_value())
				
				seller.update_gold()
				buyer.update_gold()						
		else:
			print("No Items in Seller Inventory")
			return
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Change to group?
		return
	if body.has_node("Inventory"):
		npc_inventory = body.inventory # Set variable to update gold value
		
		# Set sell control node to same resource as NPC
		npc_inventory_container.inventory_resource = body.inventory.inventory_resource
		# Update gold from player inventory node to player container node
		_update_inventory_ui(npc_inventory_container)
		
func update_player_ui_inventory() -> void: # This is super confusing; need to simplify
	if player: # Change to group?
		player_inventory_container.inventory_resource = player_inventory.inventory_resource
		_update_inventory_ui(player_inventory_container)

func _update_inventory_ui(container: InventoryContainer) -> void:
	container.update_gold()
	container.add_all_items()
	container.update_size()
	container.connect_signals()
	
func update_gold(target):
	pass
