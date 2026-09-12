@tool
extends EditorScript

const ITEMS_FOLDER := "res://Items/Resources/ItemData/"
const OUTPUT_PATH := "res://Items/items.gd"

func _run() -> void:
	var dir := DirAccess.open(ITEMS_FOLDER)
	if dir == null:
		push_error("Could not open folder: %s" % ITEMS_FOLDER)
		return

	var lines: Array[String] = ["class_name Items", "extends RefCounted", ""]

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource_path := ITEMS_FOLDER + file_name
			var const_name := file_name.get_basename().to_upper()
			lines.append("const %s = preload(\"%s\")" % [const_name, resource_path])
		file_name = dir.get_next()
	dir.list_dir_end()

	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.close()

	print("Generated ", OUTPUT_PATH)
	
	
	
