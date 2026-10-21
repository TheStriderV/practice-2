## Class to handle items in UI Inventory
## Should be placed in a control node and should have at lease 1 GridInventoryContainer
class_name ItemHandler
extends Node

@export var npc_button: Button
@export var player_button: Button


@export var load_item_id:int
@export var randomize_item: bool = false
@export var _inventory_example : Inventory
enum CharacterItem {sword, armor_bronze, bow_wood, potion, cutlass}
@export var character_items: Array[CharacterItem]

#@export_enum("sword", "axe", "bow_wood", "potion","planks","cutlass") var item_to_spawn: String

@onready var item_scene := preload("uid://bs6djdnvwyvox") # TODO: For debugging # GridInventoryItem

var item_held = null

var current_slot = null
var can_place := false
var icon_anchor : Vector2
var drag_offset: Vector2 = Vector2.ZERO
var current_grid : GridInventoryContainer

var top_grid_inventory : GridInventoryContainer
var grid_inventories

func _ready() -> void:
	if npc_button:
		npc_button.pressed.connect(_on_button_spawn_pressed_item_stacks.bind("Npc"))	
	
		
	if player_button:
		player_button.pressed.connect(_on_button_spawn_pressed_item_stacks.bind("Player"))	
	
		
	grid_inventories = get_tree().get_nodes_in_group("GridInventoryContainer")

	if grid_inventories.size() == 0:		
		push_error("No GridInventoryContainer found!")
		return		

	top_grid_inventory = grid_inventories[0]
	
	for grid_inventory in grid_inventories:
		#print("Grid Inventory: ", grid_inventory)
		_connect_signals(grid_inventory)	

	# await get_tree().process_frame
	# top_grid_inventory.place_all_items(_inventory_example)

	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_2"):
		print("Debug 2 Pressed")
		if _inventory_example:
			print("Placing all items")
			#print("inv example", _inventory_example)
			#check_all_slots()
			if current_grid:
				current_grid.place_all_items(_inventory_example.list, true)
			get_viewport().set_input_as_handled()
			
	if event.is_action_pressed("debug_1"):
		print("Debug 1 Pressed")
		get_tree().call_group("grid_inventory_item", "clear")
		get_tree().call_group("grid_slot", "clear_slots")
		for i in grid_inventories:
			i.clear()
		
###
func _connect_signals(_grid_inventory_node) -> void:
	_grid_inventory_node.grid_entered.connect(_mouse_entered)
	_grid_inventory_node.grid_exited.connect(_mouse_exited)
	_grid_inventory_node.item_currently_held.connect(_item_picked_up)	
	_grid_inventory_node.hovered_slot.connect(_on_slot_mouse_entered)

func random_item():
	return CharacterItem.find_key(randi_range(1,CharacterItem.size()-1))

func _process(_delta: float) -> void:
	if current_grid == null:
		return
	
	if item_held:		
		if Input.is_action_just_pressed("mouse_right"):
			item_held.rotate_item()
			current_grid.clear_grid()			
			
		if Input.is_action_just_pressed("mouse_left"):
			if current_grid.check_if_grid_in_grid():
				if current_grid.place_item(item_held,current_slot): # Returns true if placed success
					#item_held.reparent(current_grid)
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
	new_item.item_owner = "Npc"
	await get_tree().process_frame

	item_held = new_item
	
func _on_button_spawn_pressed_item_stacks(item_owner : String = "None") -> void:
	var new_item = item_scene.instantiate()
	get_parent().add_child(new_item)
	var rand = random_item()	
	if rand:	
		new_item.load_item_stack(rand)
	new_item.item_owner = item_owner
	new_item.selected = true	
	await get_tree().process_frame
	item_held = new_item
	
func _mouse_entered(node):
	current_grid = node
	
func _mouse_exited(_node):
	#current_grid = null
	pass

func _item_picked_up(item): 
	item_held = item

func _on_slot_mouse_entered(slot):
	current_slot = slot
