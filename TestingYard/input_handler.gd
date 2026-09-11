extends Node

const INPUT_LEFT := "left"
const INPUT_RIGHT := "right"
const INPUT_UP := "up"
const INPUT_DOWN := "down"

const INVENTORY := "inventory"
const ESCAPE := "ui_cancel"

func get_move_direction() -> Vector2:
	return Input.get_vector(INPUT_LEFT, INPUT_RIGHT, INPUT_UP, INPUT_DOWN)

func open_menu():
	return Input.is_action_pressed(INVENTORY)

func close_menu():
	return Input.is_action_pressed(ESCAPE)

