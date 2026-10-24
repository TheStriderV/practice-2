#class_name GritItemSpawner
extends GritItemSpawner

## Debug
@export var npc_button: Button
@export var player_button: Button

@export var randomize_item: bool = false
@export var _inventory_example : Inventory


enum CharacterItem {sword, armor_bronze, bow_wood, potion, cutlass, axe}


func _ready() -> void:
	#### Connect Buttons
	if npc_button:
		npc_button.pressed.connect(_on_button_spawn_pressed_item_stacks.bind("Npc"))

	if player_button:
		player_button.pressed.connect(_on_button_spawn_pressed_item_stacks.bind("Player"))

func _on_button_spawn_pressed_item_stacks(item_owner : String = "None") -> void:
	var rand = random_item()
	spawn_item(rand,true, _inventory_example.inventory_resource, item_owner)
	

func random_item():
	return CharacterItem.find_key(randi_range(1,CharacterItem.size()-1))
