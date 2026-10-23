class_name GritItemSpawner
extends Node
# Static preload remains the same
var item_scene = preload("uid://dkimflvel5gu0")

## Spawns an item given its string
func spawn_item(item: String, selected:bool = true, _inventory_resource = null, item_owner: String = "None"):
	var new_item: GritInventoryItem = item_scene.instantiate()
	get_parent().add_child(new_item)
	if _inventory_resource:
		new_item.load_item_stack(item, _inventory_resource)
	new_item.load_item_stack(item)
	new_item.item_owner = item_owner
	if selected: new_item.selected = true
	return new_item
