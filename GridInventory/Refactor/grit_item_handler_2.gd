## Class to handle items in UI Inventory
## Should be placed in a control node and should have at lease 1 GridInventoryContainer

extends Node
## Debug
@export var npc_button: Button
@export var player_button: Button


@export var randomize_item: bool = false

@export var _inventory_example : Inventory


@onready var item_scene := preload("uid://dkimflvel5gu0") # TODO: For debugging # GridInventoryItem

enum CharacterItem {sword, armor_bronze, bow_wood, potion, cutlass, axe}
##

var current_slot = null

var current_grid : GritSlotBuilder

var grid_inventories : Array

## FSM TEST

enum State {DEFAULT, HELD}

var current_state: State = State.DEFAULT

var item_held = null





func _ready() -> void:
	#### Connect Buttons
	if npc_button:
		npc_button.pressed.connect(_on_button_spawn_pressed_item_stacks.bind("Npc"))

	if player_button:
		player_button.pressed.connect(_on_button_spawn_pressed_item_stacks.bind("Player"))

	####
	# Connect any grid inventories

	grid_inventories = get_tree().get_nodes_in_group("grit")

	if grid_inventories.size() == 0:
		push_error("No GridInventoryContainer found!")
		return

	for grid_inventory in grid_inventories:
		#print("Grid Inventory: ", grid_inventory)
		_connect_signals(grid_inventory)

	current_grid = grid_inventories[0]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_2"):
		print("Debug 2 Pressed")
		if _inventory_example:

			get_viewport().set_input_as_handled()

	if event.is_action_pressed("debug_1"):
		print("Debug 1 Pressed")
# Clear

func _process(_delta: float) -> void:
	match current_state:
		State.DEFAULT:
			if Input.is_action_just_pressed("mouse_left"):
				# 		pass
				# 		if current_grid.check_if_grid_in_grid():
				# 			pass
				# 			#current_grid.pick_item()
				pass

		State.HELD:
			if current_grid == null:
				return

			current_grid.item_held = item_held

			if Input.is_action_just_pressed("mouse_right"):
				item_held.rotate_item()
				current_grid.clear_grid()

			if Input.is_action_just_pressed("mouse_left"):
				current_grid.place_item(item_held,current_slot)
				change_state(State.DEFAULT)


###
func change_state(new_state: State) -> void:
	current_state = new_state

	match current_state:
		State.DEFAULT:
			item_held = null


		State.HELD:
			pass

func _connect_signals(_grid_inventory_node) -> void:
	_grid_inventory_node.grid_entered.connect(_on_grid_mouse_entered)
	_grid_inventory_node.hovered_slot.connect(_on_slot_mouse_entered)
	print("Signals Connected")
	_grid_inventory_node.grid_exited.connect(_mouse_exited)
#_grid_inventory_node.item_currently_held.connect(_item_picked_up)


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
	change_state(State.HELD)

func _on_grid_mouse_entered(grid):
	print("Mouse Entered: ", grid)
	current_grid = grid

func _on_slot_mouse_entered(slot):
	current_slot = slot


func _mouse_exited():
	print("Mouse Exited")
	current_grid = null


func _item_picked_up(item):
	item_held = item



func random_item():
	return CharacterItem.find_key(randi_range(1,CharacterItem.size()-1))
