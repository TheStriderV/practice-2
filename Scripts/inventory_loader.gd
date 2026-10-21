extends Node
## Place as child node in NPC Grid Inventory Container

@onready var shop_area_2d: Area2D = %ShopArea2D


var npc_grid_inventory : GridInventoryContainer

#signal npc_entered
#signal npc_exited 


func _ready() -> void:
	# Assigns NPC Inventory Resource to Grid Inventory Container
	npc_grid_inventory = get_parent()
	
	shop_area_2d.body_entered.connect(_on_area_2d_body_entered)
	shop_area_2d.body_exited.connect(_on_area_2d_body_exited)
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Change to group?
		return
		
	if body.has_node("Inventory"):
		npc_grid_inventory.inventory = body.inventory.inventory_resource # npc_inventory.inventory is inventory resource
		npc_grid_inventory.inventory.gold_changed.emit()
		npc_grid_inventory.place_all_items()
		
		P.log("Placed NPC Inventory")


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass
