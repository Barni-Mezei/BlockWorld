@icon("res://ui/icons/WorldIcon.svg")

extends Node3D
class_name Terrain

signal chunk_finished(chunk_position : Vector2i)
@warning_ignore("unused_signal")
signal generation_finished
signal output_text(text : String)

@onready var _chunk_container = %Chunks

"""
World generation benchmarks (single threaded):
512x512
8:   02:33
16:  02:37
32:  02:31
64:  02:28
128: 02:30
256: 02:30

256x256
8:   00:38
16:  00:38
32:  00:37
64:  00:36
128: 00:37
256: 00:38

128x128
8:   00:10
16:  00:09
32:  00:09
64:  00:09
128: 00:09
"""

"""
World generation multithreaded:
1 thread:
128x128:
8:   00:19.19321
16:  00:11.10977
32:  00:11.10977
64:  00:09.9326
128: 00:09.9410

2 threads:
8:   00:10.10226
16:  00:06.5830
32:  00:05.5472
64:  00:06.5753
128: 00:09.9488

4 threads:
8:   00:04.4191
16:  00:03.3388
32:  00:03.3443
64:  00:04.3827
128: 00:10.9703

8 threads:
8:   00:04.4187
16:  00:04.3650
32:  00:05.4594
64:  00:04.3805
128: -

8 threads (everything closed):
8:   00:04.3648
16:  00:04.3977
32:  00:05.4863
64:  00:04.3859
128: 00:10.9595

512x512:
3 threads:
16: 01:69.69095
32: 01:61.61315
64: 01:62.61627

4 threads:
8:  01:97.96673
16: 00:56.55746
32: 00:49.49500
64: 00:51.50744

8 threads:
8:  01:115.115186
16: 01:72.72347
32: 01:63.63498
64: 01:75.75419
"""

@export var TERRAIN_GENERATOR : TerrainGenerator
@export var WORLD_SIZE : Vector2i = Vector2i(32, 32)
@export var CHUNK_SIZE : Vector2i = Vector2i(8, 8)
@export var BLOCK_SIZE : Vector3 = Vector3(1, 1, 1)

@export var CHUNK_SCENE : PackedScene

var enable_external_logging : bool = true

var voxel_data : Array
var world_size_in_chunks : Vector2i

var progress : int = 0
var progress_max : int = 0

var start_time : int

func _ready() -> void:
	randomize()

	world_size_in_chunks = Vector2i(
		ceil(WORLD_SIZE.x / float(CHUNK_SIZE.x)),
		ceil(WORLD_SIZE.y / float(CHUNK_SIZE.y)),
	)

	# Setup terrain generator
	TERRAIN_GENERATOR.world_size = WORLD_SIZE
	TERRAIN_GENERATOR.chunk_size.x = CHUNK_SIZE.x
	TERRAIN_GENERATOR.chunk_size.z = CHUNK_SIZE.y
	TERRAIN_GENERATOR.terrain_seed = randi()

func generate_terrain() -> void:
	# Update world seed
	Global.world_seed = TERRAIN_GENERATOR.terrain_seed

	progress = 0
	progress_max = world_size_in_chunks.x * world_size_in_chunks.y

	# Start generation timer
	start_time = Time.get_ticks_usec()

	log_text("Creating world: %d x %d\nChunks: %d" % [WORLD_SIZE.x, WORLD_SIZE.y, progress_max])

	for z in range(world_size_in_chunks.x):
		for x in range(world_size_in_chunks.y):

			var new_chunk = CHUNK_SCENE.instantiate().duplicate()
			new_chunk.TERRAIN_GENERATOR = TERRAIN_GENERATOR
			new_chunk.CHUNK_OFFSET = Vector2i(x * CHUNK_SIZE.x, z * CHUNK_SIZE.y)
			new_chunk.BLOCK_SIZE = BLOCK_SIZE

			new_chunk.position = Vector3(
				-BLOCK_SIZE.x / 2.0 - (world_size_in_chunks.x / 2.0) * CHUNK_SIZE.x + x * CHUNK_SIZE.x,
				0,
				-BLOCK_SIZE.z / 2.0 - (world_size_in_chunks.y / 2.0) * CHUNK_SIZE.y + z * CHUNK_SIZE.y
			) + Vector3(0, 0, 0)

			_chunk_container.add_child(new_chunk)

			# Emit signal on chunk generation
			new_chunk.generation_finished.connect(_chunk_generated)


	# Wait for all chunks to generate
	#await get_tree().create_timer(1).timeout

	#generation_finished.emit()



func _chunk_generated(chunk : Chunk) -> void:
	progress += 1
	@warning_ignore("integer_division")
	log_text("Generated chunk   (%3d ; %-3d)" % [
		chunk.CHUNK_OFFSET.x / CHUNK_SIZE.x,
		chunk.CHUNK_OFFSET.y / CHUNK_SIZE.y
	])

	chunk_finished.emit(chunk.CHUNK_OFFSET / CHUNK_SIZE)

	if progress >= progress_max:
		#await get_tree().create_timer(1).timeout

		# Debug logging
		print("World seed: %d" % TERRAIN_GENERATOR.terrain_seed)
		var took_usec = Time.get_ticks_usec() - start_time
		var took_ms = roundi(took_usec / 1_000.0)
		var took_s = roundi(took_usec / 1_000_000.0)
		var took_m = int(took_s / 60.0)
		print("A world [%d;%d] with chunk size of [%d;%d] (%5d chunks) took %02d:%02d.%03d" % [
			WORLD_SIZE.x, WORLD_SIZE.y,
			CHUNK_SIZE.x, CHUNK_SIZE.y,
			progress_max,
			took_m, took_s, took_ms
		])

		generation_finished.emit()


func log_text(txt : String) -> void:
	if enable_external_logging:
		output_text.emit(txt)
	else:
		print(txt)
