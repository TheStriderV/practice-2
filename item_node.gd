extends Node2D

@export var item_data: ItemData

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_data != null:
		sprite.texture = item_data.icon
	
