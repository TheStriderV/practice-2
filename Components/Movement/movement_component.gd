class_name MovementComponent
extends Node
### Should be used with an Animator FSM
# Sets user input by default; 
#TODO Can be configured to use an AI controller 


@export var npc: bool = false
@export var npc_resource: String = ""

@export_category("Properties")
@export var speed: float = 150.0

signal direction_changed(direction: Vector2)

var _last_emitted: Vector2 = Vector2.ZERO

## The body this component moves. Set by the owner, or auto-detected from the parent.
var body: CharacterBody2D

var input


func _ready() -> void:
	if body == null:
		body = get_parent() as CharacterBody2D
	else:
		print_debug("Not connected to CharacterBody2D")
	
	if npc == false:
		input = InputHandler
	else:
		print_debug("NPC Not yet configured")
		#TODO: Get AI controller handler
		
		#input = $..\AIController

func _physics_process(delta: float) -> void:
	player_move()

func player_move():
	if npc == false:
		var input_direction = input.get_move_direction()
		body.velocity = input_direction * speed
		body.move_and_slide()
	
		direction_changed.emit(input_direction)
		
func npc_move():
	pass
	