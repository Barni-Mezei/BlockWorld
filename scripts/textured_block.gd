@tool
@icon("res://ui/icons/ImageTexture3D.svg")

extends ArrayMesh
class_name TexturedBlock

@export_tool_button("Generate mesh", "GDScript") var action = create_mesh
@export var SIZE : Vector3 = Vector3(1, 1, 1)
@export var MATERIAL : Material
@export var BLOCK_TYPE : Blocks.BLOCK_TYPES

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

	var corner_color : PackedColorArray = [
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

	var faces : PackedByteArray = [
	] as PackedByteArray

	var uvs : PackedVector2Array = [
	] as PackedVector2Array


	var vertices : PackedVector3Array
	var normals : PackedVector3Array
	var colors : PackedColorArray

	vertices.resize(vertices.size())
	normals.resize(vertices.size())
	colors.resize(vertices.size())

	for face_index in range(6):
		for offset in range(6):
			vertices[face_index*6 + offset] = corners[faces[face_index*6 + offset]] * SIZE
			normals[face_index*6 + offset] = corner_normals[faces[face_index*6 + offset]]
			colors[face_index*6 + offset] = corner_color[faces[face_index*6 + offset]]

	var surface_data : Array = []
	surface_data.resize(ArrayMesh.ARRAY_MAX)

	surface_data[ArrayMesh.ARRAY_VERTEX] = vertices
	surface_data[ArrayMesh.ARRAY_NORMAL] = normals
	surface_data[ArrayMesh.ARRAY_TEX_UV] = uvs
	surface_data[ArrayMesh.ARRAY_COLOR] = colors

	var material = MATERIAL
	if MATERIAL == null:
		material = StandardMaterial3D.new()

		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.vertex_color_use_as_albedo = true
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.albedo_texture = Image.load_from_file("res://textures/atlases/texture_atlas.png")

	clear_surfaces()

	add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)
	surface_set_name(0, "Primary surface")
	surface_set_material(0, material)
