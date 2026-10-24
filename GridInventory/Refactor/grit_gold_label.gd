extends Label
## Place next to Grid Inventory Container in tree and connect.

@export var inventory: Inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	inventory.inventory_resource.gold_changed.connect( update_gold)
	text = "Gold: %d" % inventory.get_gold_amount()


# Signal to update text if gold changes	
func update_gold():
	text = "Gold: %d" % inventory.get_gold_amount()

func connect_signals():

	pass
