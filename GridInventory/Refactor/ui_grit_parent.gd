class_name UIGritParent
extends Control

signal item_held(item)

var current_item_held: GritInventoryItem = null

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	for grit in get_tree().get_nodes_in_group("grit"):
		grit.item_removed.connect(_on_item_held)
		
func _on_child_entered_tree(child: Node) -> void:
	if child is GritInventoryItem:	
		#print("Child Entered: ", child)
		current_item_held = child
		if child.held.is_connected(_on_item_held):
			return
		child.held.connect(_on_item_held)
		child.unheld.connect(_on_item_unheld)
		

func _on_item_held(item : GritInventoryItem) -> void:
	current_item_held = item	
	item.reparent(self)
	get_tree().call_group("grit", "update_item_held", current_item_held)

	item_held.emit(current_item_held)

func _on_item_unheld(item) -> void:
	current_item_held = null
	get_tree().call_group("grit", "update_item_held", null)


func _on_child_order_changed() -> void:
	print("Child Order Changed")
	pass # Replace with function body.
