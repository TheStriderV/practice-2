extends GritItemSpawner

@export var inventory : Inventory
# Static preload remains the same

#const item_scene = preload("uid://dkimflvel5gu0")


var grit_container: GritContainer

func _ready():
	grit_container = get_parent()

	await get_tree().create_timer(0.5).timeout

	add_all_items()
	add_all_items()

	
func add_all_items():
	for item in inventory.get_inventory():
		var new_item : GritInventoryItem = spawn_item(item,false, inventory.inventory_resource)
		P.pr(new_item)
		for slots in grit_container.grid_array:
			if grit_container.place_item(new_item, slots):
				new_item.grid_anchor = slots
				break
			else:
				continue
		if new_item.grid_anchor == null:
			new_item.queue_free()
			



