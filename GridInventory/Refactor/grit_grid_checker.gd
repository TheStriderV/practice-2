extends Control
# GritGridChecker
# Checks if particular grid is occupied

signal grid_entered(grid)
signal grid_exited(grid)

var is_hovering := false


# This is for grid checking
func _process(_delta: float) -> void:
	# Placement
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			grid_entered.emit(self)

	else:
		if is_hovering:
			is_hovering = false
			grid_exited.emit(self)
