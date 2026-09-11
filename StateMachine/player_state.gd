class_name PlayerState
extends InputState

func get_move_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

func open_menu()-> bool:
	return Input.is_action_pressed("inventory")
		
	
