class_name GritItemHandler
extends Node

enum State {DEFAULT, HELD}
var current_state: State = State.DEFAULT

var item_held = null

var grit_inventories: Array

var current_grid = null

signal held(item)

func _ready():
	grit_inventories = get_tree().get_nodes_in_group("grit")
	
	if grit_inventories.size() == 0:
		push_error("No GridInventoryContainer found!")
		return
	
	for grit in grit_inventories:
		_connect_signals(grit)

	get_parent().item_held.connect(_on_item_held)

func _input(event: InputEvent) -> void:
	if current_grid == null:
		return
	match current_state:

		State.HELD:
			if event.is_action_pressed("mouse_left"):
				if current_grid.place_item(item_held):	
					change_state(State.DEFAULT)
					
			if event.is_action_pressed("mouse_right"):
				item_held.queue_free()
				change_state(State.DEFAULT)
				
		State.DEFAULT:
			if event.is_action_pressed("mouse_left"):
				current_grid.pick_item()
				
				change_state(State.HELD)


func _on_item_held(item):
	item_held = item
	
	change_state(State.HELD)

func _connect_signals(_grit_inventory_node) -> void:
	_grit_inventory_node.grid_entered.connect(_on_grid_mouse_entered)
	_grit_inventory_node.grid_exited.connect(_on_grid_mouse_exited)

func _on_grid_mouse_entered(grid):
	current_grid = grid
	
func _on_grid_mouse_exited():
	current_grid = null
	
func change_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.DEFAULT:
			item_held = null
		State.HELD:			
			pass
