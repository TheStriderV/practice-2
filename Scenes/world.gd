extends Node2D


@onready var area_2d: Area2D = $ShopArea2D
@onready var player_inventory_container: Control = $Sell/VBoxContainer/PlayerInventoryContainer



func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	update_player_ui_inventory()




func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("Entered: ", body)
	if body.name == "Player":
		return
	if body.has_node("Inventory"):
		# Grab Sell UI Node
		var inventory_container = get_node("Sell").inventory_container
		#print("Has Inventory", body.get_node("Inventory").get_inventory())
		# Set sell control node to same resource as NPC
		inventory_container.inventory = body.get_node("Inventory").inventory
		inventory_container.add_all_items()
		inventory_container.update_size()
		inventory_container.connect_signals()
		
func update_player_ui_inventory(): # This is super confusing; need to simplify
	if has_node("Player"):
		var player_inventory = get_node("Player").get_node("Inventory")
		player_inventory_container.inventory = player_inventory.inventory
		player_inventory_container.add_all_items()
		player_inventory_container.update_size()
		player_inventory_container.connect_signals()
		
		# Basically checks if player has an inventory, and sets its resource as
		# the UI's inventory resource. This should probably be set directly
		# Also player inventory should be a top node and not in the player node. 
		# Unless of course maybe keep for multiplayer?
		
		
		
		