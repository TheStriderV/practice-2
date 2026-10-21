extends Label

@export var inventory_container : GridInventoryContainer


var total_gold : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_gold = inventory_container.inventory.get_gold()
	text = "Gold: %d" % total_gold
	
