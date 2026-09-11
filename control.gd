extends Control

@onready var inventory_screen: Control = $InventoryScreen
@onready var color_rect: ColorRect = $InventoryScreen/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:		
	inventory_screen.mouse_entered.connect(_entered)
	inventory_screen.mouse_exited.connect(_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _entered():
	color_rect.color = Color(0.754, 0.754, 0.754)
	print("mouse entered")
	
func _exited():
	color_rect.color = Color(0.5014, 0.5014, 0.5014, 1.0)
