@icon("res://ui/icons/WorldIcon.svg")

extends Node3D
class_name Terrain

@warning_ignore("unused_signal")
signal generation_finished
signal output_text(text : String)

@onready var _chunk_container = %Chunks

@export_category("World settings")
@export var GENERATION_SETTINGS : TerrainGeneratorSettings
@export var WORLD_SIZE : Vector2i = Vector2i(64, 64)
@export var CHUNK_SIZE : Vector2i = Vector2i(16, 16)
@export var RENDER_DISTANCE : int = 10

@export_category("Chunk settings")
@export var BLOCK_SIZE : Vector3 = Vector3(1, 1, 1)
@export var CHUNK_SCENE : PackedScene

var voxel_data : Array
var vertex_count : int = 0
var world_size_in_chunks : Vector2i
var chunks : Dictionary[Vector2i, Chunk]

var progress : int = 0
var progress_max : int = 0

var start_time : int

func _ready() -> void:
	randomize()

	# Setup terrain generator
	TerrainGenerator.chunk_size.x = CHUNK_SIZE.x
	TerrainGenerator.chunk_size.z = CHUNK_SIZE.y
	TerrainGenerator.settings = GENERATION_SETTINGS
	TerrainGenerator.set_seed()

	world_size_in_chunks = Vector2i(
		ceil(WORLD_SIZE.x / float(TerrainGenerator.chunk_size.x)),
		ceil(WORLD_SIZE.y / float(TerrainGenerator.chunk_size.z)),
	)

	TerrainGenerator.max_world_size = world_size_in_chunks #Vector2i(16, 16)

	SignalBus.block_changed.connect(_block_changed)
	SignalBus.chunk_changed.connect(_chunk_changed)

func _block_changed(block_pos : Vector3i, _block_type : Blocks.BLOCK_TYPES) -> void:
	var affected_chunk := TerrainGenerator.get_chunk_coordinate(block_pos)

	# Update chunk and its neighbors
	var offsets : PackedVector2Array = [
		Vector2(0, 0),
		Vector2(0, -1),
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
	]

	for offset in offsets:
		var chunk_pos := affected_chunk + Vector2i(offset)
		if chunk_pos in chunks:
			chunks[chunk_pos].update()

func _chunk_changed(chunk_offset : Vector2i, type : String):
	if type == "finished":
		_chunk_generated(chunk_offset)

func generate_terrain(offset : Vector2i = Vector2i.ZERO) -> void:
	var gen_rect = Rect2i(
		offset,
		Vector2i(
			min(RENDER_DISTANCE * 2, TerrainGenerator.max_world_size.x),
			min(RENDER_DISTANCE * 2, TerrainGenerator.max_world_size.y),
		)
	)

	log_text("Generating %d x %d (%d) chunks" % [gen_rect.size.x, gen_rect.size.y, progress_max])

	for x in range(gen_rect.size.x):
		for z in range(gen_rect.size.x):
			@warning_ignore("integer_division")
			#var chunk_pos = Vector2i(
				#x + TerrainGenerator.max_world_size.x/2 -pregen_size.x/2,
				#z + TerrainGenerator.max_world_size.y/2 -pregen_size.y/2,
			#)
			
			var chunk_pos = Vector2i(x, z) + TerrainGenerator.max_world_size/2 - gen_rect.size / 2
			
			TerrainGenerator.generate_chunk(chunk_pos)
			SignalBus.chunk_changed.emit(chunk_pos, "generated")
			log_text("Generated chunk (%3d ; %-3d)" % [chunk_pos.x, chunk_pos.y])
			await get_tree().process_frame

	progress = 0
	progress_max = gen_rect.get_area()

	# Start mesh generation timer
	start_time = Time.get_ticks_usec()

	log_text("Creating world mesh...")

	var chunk_size_flat : Vector2 = Vector2(TerrainGenerator.chunk_size.x, TerrainGenerator.chunk_size.z)
	Global.global_origin_offset = -Vector3(BLOCK_SIZE.x, 0, BLOCK_SIZE.z) / 2\
		- (Vector3(TerrainGenerator.max_world_size.x, 0, TerrainGenerator.max_world_size.y) / 2)\
		* Vector3(chunk_size_flat.x, 0, chunk_size_flat.y)

	for chunk_pos : Vector2i in TerrainGenerator.chunks:
		var new_chunk = CHUNK_SCENE.instantiate().duplicate()
		new_chunk.name = "Chunk_%d_%d" % [chunk_pos.x, chunk_pos.y]
		new_chunk.BLOCK_SIZE = BLOCK_SIZE
		new_chunk.set_voxel_data(TerrainGenerator.get_chunk(chunk_pos))
		new_chunk.set_chunk_offset(chunk_pos)

		var chunk_pos_in_world = -Vector2(
			BLOCK_SIZE.x / 2,
			BLOCK_SIZE.z / 2,
		) - (Vector2(TerrainGenerator.max_world_size) / 2) * chunk_size_flat + Vector2(chunk_pos) * chunk_size_flat

		new_chunk.position.x = chunk_pos_in_world.x
		new_chunk.position.y = 0
		new_chunk.position.z = chunk_pos_in_world.y

		_chunk_container.add_child(new_chunk)
		chunks[chunk_pos] = new_chunk
		#await get_tree().process_frame

func _chunk_generated(chunk_offset : Vector2i) -> void:
	if Global.intial_generation_finshed: return

	progress += 1
	@warning_ignore("integer_division")
	log_text("Generated chunk (%3d ; %-3d)" % [
		chunk_offset.x,
		chunk_offset.y
	])

	if progress >= progress_max:
		Global.intial_generation_finshed = true

		# Debug logging
		var took_usec = Time.get_ticks_usec() - start_time
		var took_ms = roundi(took_usec / 1_000.0)
		var took_s = roundi(took_usec / 1_000_000.0)
		var took_m = int(took_s / 60.0)

		print("World seed: %d" % TerrainGenerator.generator_seed)
		print("A world [%d;%d] with chunk size of [%d;%d] (%5d chunks) took %02d:%02d.%03d" % [
			TerrainGenerator.max_world_size.x, TerrainGenerator.max_world_size.y,
			TerrainGenerator.chunk_size.x, TerrainGenerator.chunk_size.z,
			progress_max,
			took_m, took_s, took_ms
		])

		await get_tree().create_timer(1).timeout
		generation_finished.emit()

func log_text(txt : String) -> void:
	output_text.emit(txt)
