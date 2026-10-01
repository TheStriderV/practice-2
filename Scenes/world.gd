extends Node2D


@onready var area_2d: Area2D = $ShopArea2D
@onready var player_inventory_container: Control = $VendorUI/VBoxContainer/PlayerInventoryContainer
@onready var vendor_ui: Control = $VendorUI



func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	update_player_ui_inventory()


func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("Entered: ", body)
	if body.name == "Player":
		return
	if body.has_node("Inventory"):
		# Grab Sell UI Node
		var npc_inventory_container = vendor_ui.npc_inventory_container
		var npc_inventory = body.get_node("Inventory")
		
		#print("Has Inventory", body.get_node("Inventory").get_inventory())
		# Set sell control node to same resource as NPC
		npc_inventory_container.inventory = npc_inventory.inventory
		
		# Update gold from player inventory node to player container node
		npc_inventory_container.update_gold(npc_inventory.gold)
		_update_inventory_ui(npc_inventory_container)

## Basically checks if player has an inventory, and sets its resource as
## the UI's inventory resource. This should probably be set directly
## Also player inventory should be a top node and not in the player node. 
## Unless of course maybe keep for multiplayer?	
func update_player_ui_inventory(): # This is super confusing; need to simplify
	if has_node("Player"):
		var player_inventory = get_node("Player").get_node("Inventory")
		player_inventory_container.inventory = player_inventory.inventory
		
		# Update gold from player inventory node to player container node - this is even more confusing
		player_inventory_container.update_gold(player_inventory.gold)
		_update_inventory_ui(player_inventory_container)

		
func _update_inventory_ui(container: InventoryContainer):
	container.add_all_items()
	container.update_size()
	
	container.connect_signals()
		
		