extends CanvasLayer


@onready var button: Button = $ColorRect/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	button.pressed.connect(_test)

	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if InputHandler.open_menu():
		open()
	if InputHandler.close_menu():	
		resume()	
	
func toggle_menu() -> void:
	if visible:
		resume()
	else:
		open()

func open() -> void:	
	show()
	get_tree().paused = true

func resume() -> void:	
	hide()
	get_tree().paused = false


func _on_resume_pressed() -> void:
	resume()


func _on_quit_pressed() -> void:
	get_tree().quit()

func _test() -> void:
	print("WORKS!")
