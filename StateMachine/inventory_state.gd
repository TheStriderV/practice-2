class_name InventoryState
extends InputState

func close_menu()-> bool:
	return Input.is_action_pressed("ui_cancel")