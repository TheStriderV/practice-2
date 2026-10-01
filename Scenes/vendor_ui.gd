class_name VendorUi
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

@onready var player: CharacterBody2D = $"../Player"

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
	print("Item Index 2: ", index)
	item_index = index

## For a Buy + Sell Feature 
func _vendor_item(buyer, seller) -> void:
	print("Vendoring Item")
	if item_index != null:
		print("Item Index: ", item_index)
		if seller.item_amount > 0:
			var item_stack = seller.remove_item(item_index)			
			buyer.add_item(item_stack)
		else:
			print("No Items in Seller Inventory")
			return
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Change to group?
		return
	if body.has_node("Inventory"):
		# Set sell control node to same resource as NPC
		npc_inventory_container.inventory_resource = body.inventory.inventory_resource
		# Update gold from player inventory node to player container node
		_update_inventory_ui(npc_inventory_container, body.inventory.gold)
		
func update_player_ui_inventory() -> void: # This is super confusing; need to simplify
	if player: # Change to group?
		var player_inventory : Inventory = player.get_node("Inventory")
		player_inventory_container.inventory_resource = player_inventory.inventory_resource
		_update_inventory_ui(player_inventory_container, player_inventory.gold)

func _update_inventory_ui(container: InventoryContainer, player_gold: int = 0) -> void:
	container.update_gold(player_gold)
	container.add_all_items()
	container.update_size()
	container.connect_signals()