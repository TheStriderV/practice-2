## Class to handle items in UI Inventory
## Should be placed in a control node and should have at lease 1 GridInventoryContainer
class_name ItemHandler
extends Node

@export var test_button: Button
@export var load_item_id:int
@export var randomize_item: bool = false

@onready var item_scene := preload("uid://bs6djdnvwyvox") # TODO: For debugging

signal item_picked_up(item)

var item_held = null:
	set(value):
		item_picked_up.emit(value)
		item_held = value

var current_slot = null
var can_place := false
var icon_anchor : Vector2
var drag_offset: Vector2 = Vector2.ZERO
var current_grid : GridInventoryContainer

var top_grid_inventory: GridInventoryContainer

func _ready() -> void:		
	if test_button:
		test_button.pressed.connect(_on_button_spawn_pressed_2)	
	var grid_inventories := get_tree().get_nodes_in_group("GridInventoryContainer")

	if grid_inventories.size() == 0:		
		push_error("No GridInventoryContainer found!")
		return
		
	#print("Connected inventories:", grid_inventories)
	top_grid_inventory = grid_inventories[0]
	
	for grid_inventory in grid_inventories:
		#print("Grid Inventory: ", grid_inventory)
		_connect_signals(grid_inventory)


	
	#current_grid = grid_inventory_node
	
func _process(_delta: float) -> void:
	if current_grid == null:
		return
	
	if item_held:
		
		if Input.is_action_just_pressed("mouse_right"):
			current_grid.rotate_item(item_held)
			
		if Input.is_action_just_pressed("mouse_left"):
			if current_grid.check_if_grid_in_grid():
				if current_grid.place_item(item_held): # Returns true if placed success
					item_held.reparent(current_grid)
					item_held = null
	else:
		if Input.is_action_just_pressed("mouse_left"):			
			if current_grid.check_if_grid_in_grid():
				current_grid.pick_item() 

func _on_button_spawn_pressed() -> void:
	if randomize_item:
		load_item_id = randi_range(1,6)
	print("Spawning: ", load_item_id)
	var new_item = item_scene.instantiate()
	get_parent().add_child(new_item) 
	new_item.load_item(load_item_id)
	new_item.selected = true	
	await get_tree().process_frame
	#new_item.grid_item_texture_path.scale = top_grid_inventory.scaled_amount
	item_held = new_item
	
func _on_button_spawn_pressed_2() -> void:
	var new_item = item_scene.instantiate()
	get_parent().add_child(new_item)
	new_item.load_item_stack("cutlass")
	new_item.selected = true	
	await get_tree().process_frame
	item_held = new_item
	

func _connect_signals(_grid_inventory_node: GridInventoryContainer) -> void:
	_grid_inventory_node.grid_entered.connect(_mouse_entered)
	_grid_inventory_node.grid_exited.connect(_mouse_exited)
	_grid_inventory_node.item_picked_up.connect(_item_picked_up)	

func _mouse_entered(node):
	current_grid = node
	
func _mouse_exited(_node):
	current_grid = null

func _item_picked_up(item):
	item_held = item

		
