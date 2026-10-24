## Loads inventory; place as child of GritContainer
class_name GritInventoryLoader
extends GritItemSpawner

@export var inventory : Inventory


#const item_scene = preload("uid://dkimflvel5gu0")


var grit_container: GritContainer

func _ready():
	grit_container = get_parent()

	await get_tree().create_timer(0.1).timeout
	add_all_items()

## Creates new items and adds to GRIT
func add_all_items():
	var item_owner := grit_container.item_owner
	for item in inventory.get_inventory():
		var new_item : GritInventoryItem = spawn_item(item,false, inventory.inventory_resource, item_owner)

		for slots in grit_container.grid_array:
			if grit_container.place_item(new_item, slots):
				new_item.grid_anchor = slots
				break
			else:
				continue
		if new_item.grid_anchor == null:
			P.log("Not enough space")
			new_item.queue_free()
			
func load_inventory(new_inventory):
	inventory = new_inventory
	
	
