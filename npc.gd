extends CharacterBody2D



@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var shop_area_2d: Area2D = $"../ShopArea2D"
@onready var exit_area: Area2D = $"../ExitArea2D"

@onready var inventory: Inventory = $Inventory

const SPEED := 150

var direction: Vector2 

@export var selling : bool = true
# Data

var gold :int = 0


func _ready():
	#inventory.get_inventory()
	pass
# Should move this all to a component

func _physics_process(delta: float):
	if selling:
		move_to_area(shop_area_2d, delta)
	else:
		move_to_area(exit_area, delta)


func move_to_area(area, delta):
	navigation_agent_2d.target_position = area.global_position
	direction = global_position.direction_to(navigation_agent_2d.get_next_path_position())

	if navigation_agent_2d.is_target_reached() == false:
		velocity = velocity.lerp(direction * SPEED, delta)
		move_and_slide()
			
