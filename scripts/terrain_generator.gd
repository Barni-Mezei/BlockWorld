extends Resource
class_name TerrainGenerator

@export_group("Generation settings")
@export var chunk_size : Vector3i = Vector3i(32, 64, 32)
@export var terrain_start : int = 32
@export var terrain_end : int = 64
@export var deepslate_level : int = 16

@export var height_noise : FastNoiseLite
@export var biome_noise : FastNoiseLite
@export var cave_noise : FastNoiseLite
@export var river_noise : FastNoiseLite

@export_group("Depth dependent values")
@export var iron_ore_distribution : Curve
@export var coal_ore_distribution : Curve
@export var diamond_ore_distribution : Curve

@export var underground_patch_size : Curve
@export var noise_cave_size_stone : Curve
@export var noise_cave_size_deepslate : Curve

@export_subgroup("Feature frequencies")
@export var underground_patch_frequency : int = 1500
@export var tree_frequency : int = 40
@export var foliage_frequency : int = 3
@export var mud_frequency : int = 80
@export_range(0, 5.0, 0.01) var iron_ore_multiplier : float = 0.75

@export_group("Terrain features")
@export var enable_trees : bool = true
@export_enum("oak", "birch") var TREE_TYPES : int = 0
@export var enable_foliage : bool = true
@export var use_bushes_in_foliage : bool = true
@export var enable_ores : bool = true
@export var enable_underground_patches : bool = true
@export var enable_caves : bool = true
@export var enable_mud : bool = true
@export var enable_water : bool = false

var packed_block_data_structure : Dictionary = {
	"block_type": 10,
	"light_level": 4,
	"biome": 4,
}

var packed_block_data : Dictionary = {
	"masks": {},
	"offsets": {},
}

var terrain_seed : int = -1
var world_size : Vector2i

func _init() -> void:
	randomize()

	# Generate block data bitmasks
	var offset = 0
	for data_key in packed_block_data_structure:
		var length = packed_block_data_structure[data_key]

		var mask = int(pow(2, length) - 1)

		packed_block_data["masks"][data_key] = mask
		packed_block_data["offsets"][data_key] = offset

		offset += length

	prints(get_block_indexv(Vector3(0,0,0), 2,2))
	get_block_by_index([], 8)

	var block_data : Dictionary[String, int] = {
		"block_type": 1024,
		"light_level": 16,
		"biome": 0,
	}

	var packed = pack_block_data(block_data)

	prints(String.num_uint64(packed, 2).lpad(32, "0"))

	var unpacked = unpack_block_data(packed)
	prints(unpacked)

	packed = set_packed_block_data(packed, "light_level", 2)

	unpacked = unpack_block_data(packed)
	prints(unpacked)



# Utils
static func get_block_o(data : Array, pos : Vector3) -> Blocks.BLOCK_TYPES:
	var x = int(pos.x)
	var y = int(pos.y)
	var z = int(pos.z)

	if x >= 0 and x < len(data):
		if z >= 0 and z < len(data[x]):
			if y >= 0 and y < len(data[x][z]):
				return data[x][z][y]

	return Blocks.BLOCK_TYPES.air

func unpack_block_data(block_data : int) -> Dictionary[String, int]:
	var block_data_out : Dictionary[String, int] = {}

	for key in packed_block_data_structure:
		block_data_out[key] = (block_data >> packed_block_data["offsets"][key]) & packed_block_data["masks"][key]

	return block_data_out

func set_packed_block_data(block_data : int, key : String, value : int) -> int:
	var mask = packed_block_data["masks"][key] << packed_block_data["offsets"][key]

	var erased_block_data = block_data & ~mask

	var modified_part = (value << packed_block_data["offsets"][key]) & mask

	return erased_block_data | modified_part

func pack_block_data(block_data : Dictionary[String, int]) -> int:
	var block_data_out : int = 0

	for key in packed_block_data_structure:
		block_data_out |= (block_data[key] & packed_block_data["masks"][key]) << packed_block_data["offsets"][key]

	return block_data_out

func get_block_by_index(data : PackedInt32Array, index : int) -> int:
	if index < 0 or index > data.size(): return Blocks.BLOCK_TYPES.air
	
	return data[index]

func get_block(data : PackedInt32Array, pos : Vector3i) -> Dictionary[String, int]:
	var index = get_block_indexv(pos)
	if index < 0 or index > data.size():
		return {
			"block_type": Blocks.BLOCK_TYPES.air,
			"light_level": 0,
			"biome": 0,
		}

	return unpack_block_data(data[index])

func check_block(data : Array, pos : Vector3, allowed_block_types : Array[Blocks.BLOCK_TYPES]) -> bool:
	var x = int(pos.x)
	var y = int(pos.y)
	var z = int(pos.z)

	if x >= 0 and x < len(data):
		if z >= 0 and z < len(data[x]):
			if y >= 0 and y < len(data[x][z]):
				return data[x][z][y] in allowed_block_types

	return false

func set_block_o(data : Array, pos : Vector3, block : Blocks.BLOCK_TYPES) -> void:
	var x = int(pos.x)
	var y = int(pos.y)
	var z = int(pos.z)

	if x >= 0 and x < len(data):
		if z >= 0 and z < len(data[x]):
			if y >= 0 and y < len(data[x][z]):
				data[x][z][y] = block


func set_block(data : PackedInt32Array, pos : Vector3i, block_type : Blocks.BLOCK_TYPES) -> void:
	var index : int = get_block_indexv(pos)
	if index < 0 or index > data.size(): return

	data[index] = set_packed_block_data(data[index], "block_type", block_type)


func replace_block(data : Array, pos : Vector3, block : Blocks.BLOCK_TYPES, replaced_blocks : Array[Blocks.BLOCK_TYPES]) -> void:
	var x = int(pos.x)
	var y = int(pos.y)
	var z = int(pos.z)

	if x >= 0 and x < len(data):
		if z >= 0 and z < len(data[x]):
			if y >= 0 and y < len(data[x][z]):
				# Replace block if listed in the allowed blocks
				if data[x][z][y] in replaced_blocks:
					data[x][z][y] = block

func replace_sphere(data : Array, pos : Vector3, radius : float, block : Blocks.BLOCK_TYPES, replaced_blocks : Array[Blocks.BLOCK_TYPES]) -> void:
	var r_start = -int(round(radius))
	var r_end = int(round(radius)) + 1
	
	for y in range(r_start, r_end):
		for x in range(r_start, r_end):
			for z in range(r_start, r_end):
				var offset := Vector3(x, y, z)
				if offset.length() > radius - 0.5: continue
				var block_pos = pos + offset
				replace_block(data, block_pos, block, replaced_blocks)

func generate_oak_tree(data : Array, pos : Vector3) -> void:
	# Tree trunk
	for y in range(0, 5):
		set_block(data, pos + Vector3(0, y, 0), Blocks.BLOCK_TYPES.oak_log)

	# Big leaf blob
	for y in range(3, 5):
		for x in range(-2, 3):
			for z in range(-2, 3):
				if x == 0 and z == 0: continue
				if abs(x) + abs(z) == 4 and randi_range(0, 3) == 0: continue
				set_block(data, pos + Vector3(x, y, z), Blocks.BLOCK_TYPES.oak_leaves)

	# Small leaf blob
	for y in range(5, 7):
		for x in range(-1, 2):
			for z in range(-1, 2):
				if abs(x) + abs(z) == 2 and (randi_range(0, 10) > 1 or y == 6): continue
				set_block(data, pos + Vector3(x, y, z), Blocks.BLOCK_TYPES.oak_leaves)

func get_height_at(pos : Vector2) -> int:
	return round(
		clamp(remap( # Constrain the noise value between 0 and the specified world height
			height_noise.get_noise_2dv(pos),
		-1, 1, terrain_start, terrain_end), terrain_start, terrain_end) 
	)

func get_cave_at(pos : Vector3) -> float:
	return clamp(remap(
		cave_noise.get_noise_3dv(pos),
	-1,0, 0,1), 0, 1)

func get_block_index(x : int, y : int, z : int, width : int = chunk_size.x, depth : int = chunk_size.z) -> int:
	return y * (width * depth) + z * width + x

func get_block_indexv(pos : Vector3i, width : int = chunk_size.x, depth : int = chunk_size.z) -> int:
	return pos.y * (width * depth) + pos.z * width + pos.x

func get_block_pos(index : int, width : int = chunk_size.x, depth : int = chunk_size.z) -> Vector3i:
	@warning_ignore("integer_division")
	return Vector3i(
		index % width,
		index / (width * depth),
		(index / width) % depth
	)

# Chunk generators
func generate_chunk(chunk_offset : Vector2i) -> PackedInt32Array:
	if terrain_seed == -1: terrain_seed = randi()
	height_noise.seed = terrain_seed
	biome_noise.seed = terrain_seed
	cave_noise.seed = terrain_seed
	river_noise.seed = terrain_seed

	var data : PackedInt32Array = []
	data.resize(chunk_size.x * chunk_size.y * chunk_size.z)

	for x in range(0, chunk_size.x):
		for z in range(0, chunk_size.z):
			var current_height = get_height_at(chunk_offset + Vector2i(x, z))

			for y in range(0, chunk_size.y):
				var block_type : Blocks.BLOCK_TYPES = Blocks.BLOCK_TYPES.air

				if y <= current_height: block_type = Blocks.BLOCK_TYPES.stone
				if y < deepslate_level + randi_range(-5, 5): block_type = Blocks.BLOCK_TYPES.deepslate

				if y == 0: block_type = Blocks.BLOCK_TYPES.bedrock

				set_block(data, Vector3i(x,y,z), block_type)

	return data

func generate_chunk_o(chunk_offset : Vector2i) -> Array:
	if terrain_seed == -1: terrain_seed = randi()
	height_noise.seed = terrain_seed
	biome_noise.seed = terrain_seed
	cave_noise.seed = terrain_seed
	river_noise.seed = terrain_seed
	
	var max_progress = chunk_size.x * chunk_size.z
	var progress = 0
	var progress_step = 100

	var tree_positions : PackedVector3Array = []
	var u_blob_positions : PackedVector3Array = [] # Undergound blobs
	var s_blob_positions : PackedVector3Array = [] # Surface blobs
	var data : Array = [] # Array[Array[Array[Blocks.BLOCK_TYPES]]]

	for x in range(0, chunk_size.x):
		# Rows
		data.append([])
		for z in range(0, chunk_size.z):
			# Get progress
			@warning_ignore("integer_division")
			if progress % max(1, int(max_progress / progress_step)) == 0:
				@warning_ignore("integer_division")
				#print(
				#	progress, "/", int(max_progress),
				#	"\t(", int(round((progress / float(max_progress)*100))),"%)")
			progress += 1

			# Columns
			data[x].append([])

			# Height value at the given position
			var current_height = get_height_at(chunk_offset + Vector2i(x, z))

			for y in range(0, chunk_size.y):
				var block_type : Blocks.BLOCK_TYPES = Blocks.BLOCK_TYPES.air

				# Below terrain
				if y <= current_height:
					block_type = Blocks.BLOCK_TYPES.stone
					#block_type = Blocks.BLOCK_TYPES.cave_air
					if y >= current_height - 3: block_type = Blocks.BLOCK_TYPES.dirt
					if y == current_height: block_type = Blocks.BLOCK_TYPES.grass_block

					if y < deepslate_level + randi_range(-2, 2): block_type = Blocks.BLOCK_TYPES.deepslate

					if enable_underground_patches and block_type in [Blocks.BLOCK_TYPES.stone] and randi_range(0, underground_patch_frequency) == 0:
						u_blob_positions.append(Vector3(x, y, z))

					# Cave generation
					var cave_threshold = 0
					if y <= deepslate_level:
						var progress_y = remap(y, deepslate_level,0, 0,1)
						cave_threshold = noise_cave_size_deepslate.sample(progress_y)
					else:
						var progress_y = remap(y, current_height,deepslate_level, 0,1)
						cave_threshold = noise_cave_size_stone.sample(progress_y)

					if enable_caves and get_cave_at(Vector3(x + chunk_offset.x, y, z + chunk_offset.y)) > cave_threshold:
						block_type = Blocks.BLOCK_TYPES.cave_air
				else:
					# Above terrain
					if enable_trees and y == current_height + 1 and randi_range(0, tree_frequency) == 0:
						tree_positions.append(Vector3(x, y, z))

					if enable_foliage and y == current_height + 1 and randi_range(0, foliage_frequency) == 0:
						if check_block(data, Vector3(x, y - 1, z), Blocks.get_block_group("foliage_can_spawn_on")):
							block_type = Blocks.BLOCK_TYPES.oak_leaves if use_bushes_in_foliage and randi_range(0, 5) == 0 else Blocks.BLOCK_TYPES.grass

					if enable_mud and y == current_height and randi_range(0, mud_frequency) == 0:
						s_blob_positions.append(Vector3(x, y, z))

				if y == 0: block_type = Blocks.BLOCK_TYPES.bedrock

				data[x][z].append(block_type)

	# Add surface material blobs (coarse_dirt)
	for blob_center in s_blob_positions:
		# Create sphere
		for y in range(-2, 3):
			for x in range(-2, 3):
				for z in range(-2, 3):
					var offset := Vector3(x, y, z)
					if offset.length() + randi_range(-1, 1) > 2: continue
					var block_pos = blob_center + offset
					if check_block(data, block_pos, [Blocks.BLOCK_TYPES.dirt, Blocks.BLOCK_TYPES.grass_block]):
						if check_block(data, block_pos, [Blocks.BLOCK_TYPES.grass_block]):
							set_block(data, block_pos + Vector3(0,1,0), Blocks.BLOCK_TYPES.air)
						set_block(data, block_pos, Blocks.BLOCK_TYPES.coarse_dirt)

	# Add trees to marked positions
	for tree_pos in tree_positions:
		var allow_tree := true
		for s_blob_pos in s_blob_positions:
			if (tree_pos - s_blob_pos).length() < 5:
				allow_tree = false
				break

		if not check_block(data, tree_pos + Vector3(0, -1, 0), Blocks.get_block_group("foliage_can_spawn_on")):
			allow_tree = false

		if allow_tree: generate_oak_tree(data, tree_pos)

	# Add underground material blobs (diorite, andesite, granite and dirt)
	for blob_center in u_blob_positions:
		var allowed_materials : Dictionary[Blocks.BLOCK_TYPES, float] = {
			Blocks.BLOCK_TYPES.andesite: 1.5,
			Blocks.BLOCK_TYPES.granite: 1.0,
			Blocks.BLOCK_TYPES.diorite: 1.5,
			Blocks.BLOCK_TYPES.dirt: 0.75,
		}

		var rng = RandomNumberGenerator.new()
		var material_index = rng.rand_weighted(PackedFloat32Array(allowed_materials.values()))

		var material = allowed_materials.keys()[material_index]

		# Create sphere
		@warning_ignore("narrowing_conversion")
		var current_height = get_height_at(chunk_offset + Vector2i(blob_center.x, blob_center.z))
		var progress_y = remap(blob_center.y, current_height, deepslate_level, 0, 1)
		var blob_size = underground_patch_size.sample(progress_y)
		blob_size += randi_range(-1, 1)
		if blob_size <= 1: continue
		blob_size = max(3, blob_size)
		replace_sphere(data, blob_center, blob_size, material, Blocks.get_block_group("underground_top"))

	# Add random ores
	if enable_ores:
		for i in range(int(max_progress * iron_ore_multiplier)):
			@warning_ignore("narrowing_conversion")
			var vein_pos = Vector3(randi_range(0, chunk_size.x), randi_range(0, chunk_size.y), randi_range(0, chunk_size.z))
			
			# Place vein
			@warning_ignore("narrowing_conversion")
			var current_height = get_height_at(chunk_offset + Vector2i(vein_pos.x, vein_pos.z))
			var progress_y = remap(vein_pos.y, current_height, 0, 0, 1)
			var vein_chance = iron_ore_distribution.sample(progress_y)
			if randf_range(0, 1) > vein_chance: continue

			for y in range(2):
				for x in range(2):
					for z in range(2):
						var offset := Vector3(x, y, z)
						var block_pos = vein_pos + offset
						replace_block(data, block_pos, Blocks.BLOCK_TYPES.iron_ore, [Blocks.BLOCK_TYPES.stone])

	return data
