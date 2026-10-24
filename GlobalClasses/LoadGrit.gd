class_name LoadGrit

static var grit

static func load_grit(from: Node) -> Array[Node]:
	return from.get_tree().get_nodes_in_group("grit")