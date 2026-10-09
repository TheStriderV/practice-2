extends CharacterBody2D


@export var shop_area_2d: Area2D
@export var exit_area: Area2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var inventory: Inventory = $Inventory

const SPEED := 150

var direction: Vector2 

@export var selling : bool = true

# Data

func _ready():
	inventory.inventory_empty.connect(inventory_empty)
	exit_area.body_entered.connect(_on_area_exited)
	

func _physics_process(delta: float):
	if selling:
		move_to_area(shop_area_2d, delta)
	else:
		move_to_area(exit_area, delta)

func _on_area_exited(body: Node2D):
	print("Exited Area")
	queue_free()
	

func inventory_empty():
	#print("It's empty...")
	selling = false
	
func move_to_area(area, delta):
	navigation_agent_2d.target_position = area.global_position
	direction = global_position.direction_to(navigation_agent_2d.get_next_path_position())

	if navigation_agent_2d.is_target_reached() == false:
		velocity = velocity.lerp(direction * SPEED, delta)
		move_and_slide()
	else:
		pass

			

	

	
