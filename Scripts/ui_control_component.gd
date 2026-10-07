extends Node

@export var grid_inventory_node :GridInventory
@export var grid_inventory_node_2 :GridInventory

@export var test_button: Button
@export var load_item_id:int

@onready var item_scene = preload("uid://bs6djdnvwyvox")



var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2
var drag_offset: Vector2 = Vector2.ZERO
var current_grid : GridInventory = grid_inventory_node


func _ready() -> void:
	if grid_inventory_node:
		grid_inventory_node.grid_entered.connect(_mouse_entered)
		grid_inventory_node.grid_exited.connect(_mouse_exited)
		grid_inventory_node.item_picked_up.connect(_item_picked_up)
		
	if grid_inventory_node_2:
		grid_inventory_node_2.grid_entered.connect(_mouse_entered)
		grid_inventory_node_2.grid_exited.connect(_mouse_exited)
		grid_inventory_node_2.item_picked_up.connect(_item_picked_up)

	test_button.pressed.connect(_on_button_spawn_pressed)
	current_grid = grid_inventory_node
	
func _process(_delta: float) -> void:
	
	if item_held:
		if Input.is_action_just_pressed("mouse_rightclick"):
			current_grid.rotate_item(item_held)
		if Input.is_action_just_pressed("mouse_leftclick"):
			print("Click current grid: ", current_grid)
			if current_grid.get_global_rect().has_point(current_grid.get_global_mouse_position()):
				print("Current Slot: ", current_grid.current_slot.slot_ID)
				if current_grid.place_item(item_held):
					item_held = null
	else:
		if Input.is_action_just_pressed("mouse_leftclick"):
			if current_grid.get_global_rect().has_point(current_grid.get_global_mouse_position()):
				current_grid.pick_item() 
				
	pass
func _mouse_entered(node):
	print("Mouse Entered! : ", node)
	current_grid = node
	
func _mouse_exited(node):
	#print("Mouse exited! : ", node)
	#current_grid = null
	pass

func _item_picked_up(item):
	print("I cant believe this works...")
	get_parent().add_child(item)
	item_held = item

func _on_button_spawn_pressed() -> void:
	print("Button pressed")
	var new_item = item_scene.instantiate()
	get_parent().add_child(new_item) # Testing only...
	#new_item.load_item(1)
	new_item.load_item(load_item_id)
	new_item.selected = true
	grid_inventory_node.item_held = new_item
	grid_inventory_node_2.item_held = new_item
	item_held = new_item
	
func place_item(item_held):
	
	pass
		
