extends Control

var grit_inventories : Array

@export var label : Label
@export var debug_label_1 : Label

@export var npc_inv : Inventory


func _ready():
	label.text = ""
	grit_inventories = LoadGrit.load_grit(self)

	if grit_inventories.size() == 0:
		push_error("No GridInventoryContainer found!")
		return

	for grit in grit_inventories:
		_connect_signals(grit)

func _process(_delta: float) -> void:
	# Get the current mouse position on the screen
	#var mouse_pos := get_global_mouse_position()

	# Set the label's position to the mouse position + an offset to the right
	# (Optional: add a slight vertical offset so it doesn't overlap the cursor directly)
	#global_position = mouse_pos + Vector2(15, -10)
	pass

# ## Debug
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_1"):
		print("Debug 1 Pressed")
		get_item_list()
		#grit_inventories[0].get_item_location()

	if event.is_action_pressed("debug_2"):
		print("Debug 2 Pressed")
		
func _connect_signals(_grit_inventory_node) -> void:
	_grit_inventory_node.grid_entered.connect(_on_grid_mouse_entered)
	_grit_inventory_node.grid_exited.connect(_on_grid_mouse_exited)

	_grit_inventory_node.hovered_slot.connect(_on_slot_mouse_entered)
	#_grit_inventory_node.debug_text.connect(_debug_text)


func _on_grid_mouse_entered(_grid):
	#text = str(_grid)
	pass

func _on_slot_mouse_entered(slot: GridInventorySlot):
	if slot.item_stored == null:
		label.text = ""#str(slot.slot_ID)
		return
	var item_id = slot.item_stored.get_id()
	var item_value = slot.item_stored.get_value()
	var item_owner = slot.item_stored.get_item_owner()
	if item_id:
		label.text = "%s: %sg, Owner: %s, Slot ID: %s" % [str(item_id).capitalize(), item_value, item_owner, slot.slot_ID]

func _on_grid_mouse_exited():
	label.text = ""
	
func _debug_text(text):
	debug_label_1.text = ""
	debug_label_1.text = str(text)



func get_item_list() -> void:
	var items = npc_inv.get_inventory_list()
	
	# 1. Convert each item in the array to a string
	var item_strings = items.map(func(item): return str(item.get_id()))
	
	# 2. Join them together with a newline character (\n)
	debug_label_1.text = "\n".join(item_strings)
	
	
