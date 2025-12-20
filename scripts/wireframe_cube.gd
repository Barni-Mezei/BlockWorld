@tool
@icon("res://ui/icons/CollisionShape3D.svg")

extends ArrayMesh
class_name WireframeCube

@export_tool_button("Generate mesh", "GDScript") var action = create_mesh
@export var SIZE : Vector3 = Vector3(1, 1, 1)
@export var COLOR : Color = Color.ORANGE_RED

func create_mesh():
	var corners : PackedVector3Array = [
		Vector3(0,0,0),
		Vector3(0,1,0),
		Vector3(1,0,0),
		Vector3(1,1,0),

		Vector3(0,0,1),
		Vector3(0,1,1),
		Vector3(1,0,1),
		Vector3(1,1,1),
	] as PackedVector3Array

	var corner_colors : PackedColorArray = [
		Color.from_rgba8(255, 0, 0, 255),
		Color.from_rgba8(0, 255, 0, 255),
		Color.from_rgba8(0, 0, 255, 255),
		Color.from_rgba8(0, 255, 255, 255),

		Color.from_rgba8(255, 255, 0, 255),
		Color.from_rgba8(255, 0, 255, 255),
		Color.from_rgba8(128, 128, 255, 255),
		Color.from_rgba8(0, 0, 0, 255),
	] as PackedColorArray

	var corner_normals : PackedVector3Array = [
		Vector3(-1,-1,-1),
		Vector3(-1, 1,-1),
		Vector3( 1,-1,-1),
		Vector3( 1, 1,-1),
		Vector3(-1,-1, 1),
		Vector3(-1, 1, 1),
		Vector3( 1,-1, 1),
		Vector3( 1, 1, 1),
	] as PackedVector3Array

	var lines : PackedByteArray = [
		# Bottom
		0, 2,
		2, 6,
		6, 4,
		4, 0,

		# Top
		1, 3,
		3, 7,
		7, 5,
		5, 1,
		
		# Edges
		0, 1,
		2, 3,
		4, 5,
		6, 7,
	] as PackedByteArray

	var vertices : PackedVector3Array
	var normals : PackedVector3Array
	var colors : PackedColorArray

	vertices.resize(lines.size())
	normals.resize(lines.size())
	colors.resize(lines.size())

	for edge_index in range(12):
		for offset in range(2):
			vertices[edge_index*2 + offset] = corners[lines[edge_index*2 + offset]] * SIZE
			normals[edge_index*2 + offset] = corner_normals[lines[edge_index*2 + offset]]
			colors[edge_index*2 + offset] = corner_colors[lines[edge_index*2 + offset]]

	var surface_data : Array = []
	surface_data.resize(ArrayMesh.ARRAY_MAX)

	surface_data[ArrayMesh.ARRAY_VERTEX] = vertices
	surface_data[ArrayMesh.ARRAY_NORMAL] = normals
	surface_data[ArrayMesh.ARRAY_COLOR] = colors

	var material = StandardMaterial3D.new()
	material.albedo_color = COLOR
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#material.albedo_color = Color.WHITE
	#material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	clear_surfaces()

	add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_data)
	surface_set_name(0, "Primary surface")
	surface_set_material(0, material)
