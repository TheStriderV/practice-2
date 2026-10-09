@tool
class_name GridInventorySlot
extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

@onready var filter: ColorRect = $StatusFilter

var slot_ID
var is_hovering := false
enum States{DEFAULT, TAKEN, FREE}
var state := States.DEFAULT
var item_stored = null

const DEFAULT_SIZE := Vector2(50, 50)

var scaled_amount: Vector2:
	get:
		return size / DEFAULT_SIZE
		

func set_color(a_state = States.DEFAULT) -> void:
	match a_state:
		States.DEFAULT:
			filter.color = Color(Color.WHITE, 0.0)
		States.TAKEN:
			filter.color = Color(Color.RED, 0.2)
		States.FREE:
			filter.color = Color(Color.GREEN, 0.2)

func _ready() -> void:
	#print("Scaled amnount: ", size, scaled_amount)
	pass

func _process(_delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			slot_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			slot_exited.emit(self)
			
#const default_size := Vector2(50,50)

func change_size(new_size):
	var updated_size := Vector2(new_size, new_size)
	set_size(updated_size)
	
