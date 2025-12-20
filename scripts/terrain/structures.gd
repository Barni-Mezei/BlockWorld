extends Node3D
class_name StructureLoader

var structures : Dictionary[StringName, Dictionary]

func _ready() -> void:
	for child in get_children():
		
	var lib := _oak_tree.mesh_library

	for item_id in lib.get_item_list():
		var item_name := lib.get_item_name(item_id)

		prints(item_id, item_name)

	_oak_tree.get_used_cells()
