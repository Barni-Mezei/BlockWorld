@icon("res://ui/icons/CollisionShape3D.svg")

extends Node3D
class_name Chunk

@onready var _terrain_mesh := %TerrainMesh
@onready var _terrain_collision_shape := %TerrainCollisionShape

@export var CHUNK_OFFSET : Vector2i
@export var BLOCK_SIZE : Vector3

@export_category("Materials")
@export var DEFAULT_MATERIAL : Material
@export var GRASS_MATERIAL : Material
@export var FOLIAGE_MATERIAL : Material
@export var GLOWING_MATERIAL : Material

const ATLAS_SIZE : Vector2 = Vector2(8, 8)
const BLOCK_MODELS : Dictionary = {
	"cube": "_create_cube",
	"cross": "_create_cross",
	"tall_cross": "_create_tall_cross",
}

var BLOCK_MATERIALS : Dictionary = {}

# Configuration for the current block, like top_rotation, or foliage_offset
var block_config : Dictionary[String, Variant] = {}

var thread : Thread
var thread_index : int  = 0

# The voxel data go generate the chunk from
var voxel_data : PackedInt32Array
var chunk_offset : Vector2i = Vector2i.ZERO

var vertex_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set block materials
	BLOCK_MATERIALS["default"] = DEFAULT_MATERIAL
	BLOCK_MATERIALS["grass"] = GRASS_MATERIAL
	BLOCK_MATERIALS["foliage"] = FOLIAGE_MATERIAL
	BLOCK_MATERIALS["glow"] = GLOWING_MATERIAL

	update()

	#prints("\t- Got thread:", thread_index, "T", ThreadManager.used_thread_count, "after", request_count)

func update(ignore_collision : bool = false):
	SignalBus.chunk_changed.emit(chunk_offset, "building")

	var thread_data : Dictionary = {
		"thread": null
	}

	#var request_count = 0
	
	# Request a thread from the thread pool
	while thread_data["thread"] == null:
		#print("Requesting thread...")
		#request_count += 1
		thread_data = ThreadManager.get_thread()
		await get_tree().create_timer(0.1).timeout
		#await get_tree().process_frame

	# Start mesh building on the thread
	thread_index = thread_data["index"]
	thread = thread_data["thread"]
	thread.start(generate_meshes.bind(ignore_collision))

func set_voxel_data(new_voxel_data) -> void:
	voxel_data = new_voxel_data

func set_chunk_offset(offset : Vector2i) -> void:
	chunk_offset = offset


## Multithreading functions
func __generation_finished():
	SignalBus.chunk_changed.emit(chunk_offset, "finished")

func __set_mesh(mesh : ArrayMesh):
	_terrain_mesh.mesh = mesh

func __set_surface_material(surfaces : Array):
	for surface_index in range(len(surfaces)):
		_terrain_mesh.mesh.surface_set_material(surface_index, BLOCK_MATERIALS[surfaces[surface_index]])

func __set_collision_shape(shape : ConcavePolygonShape3D):
	_terrain_collision_shape.shape = shape

	#__generation_finished.call_deferred()
	(func (): SignalBus.chunk_changed.emit(chunk_offset, "finished")).call_deferred()
	ThreadManager.free_thread(thread_index)
	#print("\t- Thread %d END" % thread_index)

func generate_meshes(ignore_collision : bool = false) -> void:
	var mesh_data = build_mesh()
	#__set_mesh.call_deferred(mesh_data["mesh"])
	(func (): _terrain_mesh.mesh = mesh_data["mesh"]).call_deferred()

	# Set surface materials
	#__set_surface_material.call_deferred(mesh_data["surfaces"])
	for surface_index in range(len(mesh_data["surfaces"])):
		(func (): _terrain_mesh.mesh.surface_set_material(surface_index, BLOCK_MATERIALS[mesh_data["surfaces"][surface_index]])).call_deferred()

	if ignore_collision:
		(func (): SignalBus.chunk_changed.emit(chunk_offset, "finished")).call_deferred()
		ThreadManager.free_thread(thread_index)
	else:
		var collider = build_collider(mesh_data["collider_mesh"])
		call_deferred_thread_group("__set_collision_shape", collider)


## Mesh generator functions

# Returns true if the face should be drawn
@warning_ignore("unused_parameter")
func _check_cull(local_block_pos : Vector3, face_normal: Vector3) -> bool:
	#if pos.x == 0 and normal.x == -1: return false
	#if pos.x == TERRAIN_GENERATOR.chunk_size.x-1 and normal.x == 1: return false
	#if pos.z == 0 and normal.z == -1: return false
	#if pos.z == TERRAIN_GENERATOR.chunk_size.z-1 and normal.z == 1: return false
	var global_block_pos = Vector3(chunk_offset.x, 0, chunk_offset.y)*Vector3(TerrainGenerator.chunk_size) + local_block_pos + face_normal 

	return TerrainGenerator.get_block_from_world(global_block_pos)["block_type"] in Blocks.get_block_group("transparent")

func _create_face(
		mesh_data : Dictionary, # vertex, uv, normal
		c1: Vector3, c2: Vector3, c3: Vector3, c4: Vector3, # Corners
		n: Vector3, # Normal
		t: Vector2, # Face tile coordinate
		r: int = 0, # Face UV rotation
	):

	var step = Vector2(1 / ATLAS_SIZE.x, 1 / ATLAS_SIZE.y)

	var uv = [
		step * t,
		step * t + Vector2(step.x, 0),
		step * t + Vector2(0, step.y),
		step * t + step,
	]

	var top_left = uv[(r+0) % 4]
	var top_right = uv[(r+1) % 4]
	var bottom_left = uv[(r+2) % 4]
	var bottom_right = uv[(r+3) % 4]

	if r == 1:
		top_left = uv[(r+3) % 4]
		top_right = uv[(r+1) % 4]
		bottom_left = uv[(r+0) % 4]
		bottom_right = uv[(r+2) % 4]

	mesh_data["vertex"].append_array([
		c1, c2, c3,
		c1, c4, c2,
	])

	mesh_data["uv"].append_array([
		top_left, bottom_right, bottom_left,
		top_left, top_right, bottom_right,
	])

	mesh_data["normal"].append_array([
		n, n, n,
		n, n, n,
	])

func _create_cube(mesh_data : Dictionary, origin: Vector3, size: Vector3, block_id: Blocks.BLOCK_TYPES):
	# Front
	if _check_cull(origin, Vector3(0, 0, 1)):
		_create_face(
			mesh_data,
			origin + Vector3(0, 1, 1) * size,
			origin + Vector3(1, 0, 1) * size,
			origin + Vector3(0, 0, 1) * size,
			origin + Vector3(1, 1, 1) * size,
			Vector3(0, 0, 1),
			Blocks.BLOCKS[block_id]["front"],
			0,
		)

	# Top
	if _check_cull(origin, Vector3(0, 1, 0)):
		_create_face(
			mesh_data,
			origin + Vector3(0, 1, 0) * size,
			origin + Vector3(1, 1, 1) * size,
			origin + Vector3(0, 1, 1) * size,
			origin + Vector3(1, 1, 0) * size,
			Vector3(0, 1, 0),
			Blocks.BLOCKS[block_id]["top"],
			block_config["top_rotation"]
		)

	# Back
	if _check_cull(origin, Vector3(0, 0, -1)):
		_create_face(
			mesh_data,
			origin + Vector3(0, 0, 0) * size,
			origin + Vector3(1, 1, 0) * size,
			origin + Vector3(0, 1, 0) * size,
			origin + Vector3(1, 0, 0) * size,
			Vector3(0, 0, -1),
			Blocks.BLOCKS[block_id]["back"],
			2
		)

	# Bottom
	if _check_cull(origin, Vector3(0, -1, 0)):
		_create_face(
			mesh_data,
			origin + Vector3(0, 0, 1) * size,
			origin + Vector3(1, 0, 0) * size,
			origin + Vector3(0, 0, 0) * size,
			origin + Vector3(1, 0, 1) * size,
			Vector3(0, -1, 0),
			Blocks.BLOCKS[block_id]["bottom"],
			0
		)

	# Left
	if _check_cull(origin, Vector3(-1, 0, 0)):
		_create_face(
			mesh_data,
			origin + Vector3(0, 1, 1) * size,
			origin + Vector3(0, 0, 0) * size,
			origin + Vector3(0, 1, 0) * size,
			origin + Vector3(0, 0, 1) * size,
			Vector3(-1, 0, 0),
			Blocks.BLOCKS[block_id]["left"],
			1
		)

	# Right
	if _check_cull(origin, Vector3(1, 0, 0)):
		_create_face(
			mesh_data,
			origin + Vector3(1, 1, 0) * size,
			origin + Vector3(1, 0, 1) * size,
			origin + Vector3(1, 1, 1) * size,
			origin + Vector3(1, 0, 0) * size,
			Vector3(1, 0, 0),
			Blocks.BLOCKS[block_id]["right"],
			1
		)

@warning_ignore("unused_parameter")
func _create_cross(mesh_data : Dictionary, origin: Vector3, size: Vector3, block_id: Blocks.BLOCK_TYPES, top_rotation: int = 0):
	var random_offset := Vector3(randf_range(-0.25, 0.25), -0.05, randf_range(-0.25, 0.25))
	
	# Front (double sided)
	_create_face(
		mesh_data,
		origin + random_offset + Vector3(0, 1, 0) * size,
		origin + random_offset + Vector3(0.68, 0, 0.68) * size,
		origin + random_offset + Vector3(0, 0, 0) * size,
		origin + random_offset + Vector3(0.68, 1, 0.68) * size,
		Vector3(0, 0, 1),
		Blocks.BLOCKS[block_id]["front"],
		0,
	)

	_create_face(
		mesh_data,
		origin + random_offset + Vector3(0.68, 1, 0.68) * size,
		origin + random_offset + Vector3(0, 0, 0) * size,
		origin + random_offset + Vector3(0.68, 0, 0.68) * size,
		origin + random_offset + Vector3(0, 1, 0) * size,
		Vector3(1, 0, 0),
		Blocks.BLOCKS[block_id]["front"],
		0,
	)

	# Back
	_create_face(
		mesh_data,
		origin + random_offset + Vector3(0, 1, 0.68) * size,
		origin + random_offset + Vector3(0.68, 0, 0) * size,
		origin + random_offset + Vector3(0, 0, 0.68) * size,
		origin + random_offset + Vector3(0.68, 1, 0) * size,
		Vector3(1, 0, 1),
		Blocks.BLOCKS[block_id]["front"],
		0,
	)

	_create_face(
		mesh_data,
		origin + random_offset + Vector3(0.68, 1, 0) * size,
		origin + random_offset + Vector3(0, 0, 0.68) * size,
		origin + random_offset + Vector3(0.68, 0, 0) * size,
		origin + random_offset + Vector3(0, 1, 0.68) * size,
		Vector3(0, 0, 0),
		Blocks.BLOCKS[block_id]["front"],
		0,
	)

@warning_ignore("unused_parameter")
func _create_tall_cross(mesh_data : Dictionary, origin: Vector3, size: Vector3, block_id: Blocks.BLOCK_TYPES, top_rotation: int = 0): pass

func _create_block(
		MESH_DATA : Dictionary[String, Dictionary],
		COLLIDER_MESH_DATA : Dictionary[Blocks.BLOCK_COLLISIONS, Array],
		origin: Vector3,
		size: Vector3,
		block_id: Blocks.BLOCK_TYPES
	) -> void:

	var method_name = BLOCK_MODELS[Blocks.get_block_model(block_id)]
	var block_material = Blocks.get_block_material(block_id)
	var block_collision = Blocks.get_block_collision(block_id)

	# Create mesh data
	var mesh_data = {
			"vertex": [],
			"uv": [],
			"normal": [],
	}
	self.call(method_name, mesh_data, origin, size, block_id)

	# Add to collider mesh
	if block_collision != Blocks.BLOCK_COLLISIONS.pass_through:
		COLLIDER_MESH_DATA[block_collision].append_array(mesh_data["vertex"])

	# Add to interaction mesh
	COLLIDER_MESH_DATA[Blocks.BLOCK_COLLISIONS.interaction].append_array(mesh_data["vertex"])

	# Merge mesh to the correct material
	for key in mesh_data:
		MESH_DATA[block_material][key].append_array(mesh_data[key])

func build_mesh() -> Dictionary:
	# Create surfaces
	var mesh_surface_data : Dictionary[String, Dictionary] = {}
	var collider_mesh_data : Dictionary[Blocks.BLOCK_COLLISIONS, Array] = {
		Blocks.BLOCK_COLLISIONS.default: [],
		Blocks.BLOCK_COLLISIONS.interaction: [],
	}

	for key in BLOCK_MATERIALS:
		mesh_surface_data[key] = {
			"vertex": [],
			"uv": [],
			"normal": [],
		}

	var pos : Vector3i
	#var packed_block_data : int
	var block_data : Dictionary
	var block_type : Blocks.BLOCK_TYPES

	for x in range(TerrainGenerator.chunk_size.x):
		for y in range(TerrainGenerator.chunk_size.y):
			for z in range(TerrainGenerator.chunk_size.z):
				pos = Vector3i(x, y, z)
				block_data = TerrainGenerator.get_block_by_pos(voxel_data, pos)
				block_type = block_data["block_type"]
				if Blocks.is_air(block_type): continue

				block_config["top_rotation"] = 0

				_create_block(mesh_surface_data, collider_mesh_data, Vector3(pos) * BLOCK_SIZE, BLOCK_SIZE, block_type)

	# Generate mesh with surfaces
	vertex_count = 0
	var mesh = ArrayMesh.new()
	var mesh_surfaces := []

	for surface in mesh_surface_data:
		if len(mesh_surface_data[surface]["vertex"]) == 0: continue
		
		var surface_data := []
		surface_data.resize(ArrayMesh.ARRAY_MAX)

		surface_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(mesh_surface_data[surface]["vertex"])
		surface_data[ArrayMesh.ARRAY_TEX_UV] = PackedVector3Array(mesh_surface_data[surface]["uv"])
		surface_data[ArrayMesh.ARRAY_NORMAL] = PackedVector3Array(mesh_surface_data[surface]["normal"])

		vertex_count += surface_data[ArrayMesh.ARRAY_VERTEX].size()

		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)
		if not mesh_surfaces.has(surface): mesh_surfaces.append(surface)

	# Generate collider meshes
	var collider_mesh = ArrayMesh.new()
	var interaction_mesh = ArrayMesh.new()

	if len(collider_mesh_data[Blocks.BLOCK_COLLISIONS.default]) > 0:
		var surface_data : Array = []
		surface_data.resize(ArrayMesh.ARRAY_MAX)

		surface_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(collider_mesh_data[Blocks.BLOCK_COLLISIONS.default])

		collider_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)

	if len(collider_mesh_data[Blocks.BLOCK_COLLISIONS.interaction]) > 0:
		var surface_data : Array = []
		surface_data.resize(ArrayMesh.ARRAY_MAX)

		surface_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(collider_mesh_data[Blocks.BLOCK_COLLISIONS.interaction])

		interaction_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)


	return {
		"mesh": mesh,
		"surfaces": mesh_surfaces,
		"collider_mesh": collider_mesh,
		"interaction_mesh": interaction_mesh,
	}

func build_collider(mesh: ArrayMesh) -> ConcavePolygonShape3D:
	return mesh.create_trimesh_shape()
