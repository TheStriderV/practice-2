extends Label
## Place next to Grid Inventory Container in tree and connect.
@export var inventory_container : GridInventoryContainer


var total_gold : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory_container.inventory_resource_changed.connect(connect_signals)
	inventory_container.inventory.gold_changed.connect(update_gold)
	
	
	total_gold = inventory_container.inventory.get_gold()
	text = "Gold: %d" % total_gold


# Signal to update text if gold changes	
func update_gold():
	#P.log("Gold updated")
	total_gold = inventory_container.inventory.get_gold()
	#P.p(total_gold)
	text = "Gold: %d" % total_gold

func connect_signals():
	#P.log("Resource changed")
	#if inventory_container.inventory == new_resource:
	#	return
	inventory_container.inventory.gold_changed.disconnect(update_gold)
	inventory_container.inventory.gold_changed.connect(update_gold)
	update_gold()
