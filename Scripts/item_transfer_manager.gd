## Item Transfer Connector 
## Connects the correct signals needed.
extends Node

## Area to start transferring items
@export var transfer_area: Area2D

## Transfer UI - in this case buy/sell
@export var vendor_ui: VendorUi

## Player should always be set
@onready var player: CharacterBody2D = $"../Player"
@onready var player_inventory_container: Control = vendor_ui.player_inventory_container

func _ready() -> void:
	# player_inventory_container is null if we don't wait for the tree to finish loading
	await get_tree().process_frame
	player_inventory_container = vendor_ui.player_inventory_container
	
	transfer_area.body_entered.connect(_on_area_2d_body_entered)
	update_player_ui_inventory()


func _on_area_2d_body_entered(body: Node2D) -> void:

	if body.name == "Player":
		return
	if body.has_node("Inventory"):
		# Grab Sell UI Node
		var npc_inventory_container = vendor_ui.npc_inventory_container # Change to agnostic?
		var npc_inventory = body.inventory
		var npc_gold = npc_inventory.gold

		# Set sell control node to same resource as NPC
		npc_inventory_container.inventory_resource = npc_inventory.inventory_resource

		# Update gold from player inventory node to player container node

		_update_inventory_ui(npc_inventory_container, npc_gold)

func _on_area_2d_body_exited(body: Node2D) -> void:
	# Clear inventory
	pass
	

## Basically checks if player has an inventory, and sets its resource as
## the UI's inventory resource. This should probably be set directly
## Also player inventory should be a top node and not in the player node. 
## Unless of course maybe keep for multiplayer?	
func update_player_ui_inventory(): # This is super confusing; need to simplify
	if player:
		var player_inventory = player.get_node("Inventory")
		var player_gold = player_inventory.gold
		
		player_inventory_container.inventory_resource = player_inventory.inventory_resource

		# Update gold from player inventory node to player container node - this is even more confusing
		#player_inventory_container.update_gold(player_gold)
		_update_inventory_ui(player_inventory_container, player_gold)


func _update_inventory_ui(container: InventoryContainer, player_gold: int = 0):
	container.update_gold(player_gold)
	container.add_all_items()
	container.update_size()
	container.connect_signals()
		
		
