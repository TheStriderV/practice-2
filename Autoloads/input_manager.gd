#class_name InputManager
extends Node

var current_state: InputState = PlayerState.new() # Default State

func change_state(new_state: InputState) -> void:
	current_state = new_state

func get_move_direction() -> Vector2:
	return current_state.get_move_direction()

func attack() -> bool:
	return current_state.attack()

func open_menu():
	if current_state.open_menu():
		change_state(InventoryState.new())
		return true


	
