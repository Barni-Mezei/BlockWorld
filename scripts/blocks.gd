extends  Node

const BLOCKS : Dictionary[BLOCK_TYPES, Dictionary] = {
	# Impossible blocks
	BLOCK_TYPES.air: {
		"top":    Vector2(7, 7),
		"bottom": Vector2(7, 7),
		"front":  Vector2(7, 7),
		"back":   Vector2(7, 7),
		"left":   Vector2(7, 7),
		"right":  Vector2(7, 7),
	},

	BLOCK_TYPES.cave_air: {
		"top":    Vector2(7, 7),
		"bottom": Vector2(7, 7),
		"front":  Vector2(7, 7),
		"back":   Vector2(7, 7),
		"left":   Vector2(7, 7),
		"right":  Vector2(7, 7),
	},

	# Terrain
	BLOCK_TYPES.bedrock: {
		"top":    Vector2(0, 0),
		"bottom": Vector2(0, 0),
		"front":  Vector2(0, 0),
		"back":   Vector2(0, 0),
		"left":   Vector2(0, 0),
		"right":  Vector2(0, 0),
	},

	BLOCK_TYPES.deepslate: {
		"top":    Vector2(1, 0),
		"bottom": Vector2(1, 0),
		"front":  Vector2(1, 0),
		"back":   Vector2(1, 0),
		"left":   Vector2(1, 0),
		"right":  Vector2(1, 0),
	},

	BLOCK_TYPES.stone: {
		"top":    Vector2(2, 0),
		"bottom": Vector2(2, 0),
		"front":  Vector2(2, 0),
		"back":   Vector2(2, 0),
		"left":   Vector2(2, 0),
		"right":  Vector2(2, 0),
	},

	# Ores
	BLOCK_TYPES.iron_ore: {
		"top":    Vector2(2, 0),
		"bottom": Vector2(2, 0),
		"front":  Vector2(2, 0),
		"back":   Vector2(2, 0),
		"left":   Vector2(2, 0),
		"right":  Vector2(2, 0),
		"material": "glow",
	},

	BLOCK_TYPES.redstone_ore: {
		"top":    Vector2(0, 0),
		"bottom": Vector2(0, 0),
		"front":  Vector2(0, 0),
		"back":   Vector2(0, 0),
		"left":   Vector2(0, 0),
		"right":  Vector2(0, 0),
		"material": "glow",
	},

	# In-ground blocks
	BLOCK_TYPES.andesite: {
		"top":    Vector2(3, 2),
		"bottom": Vector2(3, 2),
		"front":  Vector2(3, 2),
		"back":   Vector2(3, 2),
		"left":   Vector2(3, 2),
		"right":  Vector2(3, 2),
	},

	BLOCK_TYPES.diorite: {
		"top":    Vector2(4, 2),
		"bottom": Vector2(4, 2),
		"front":  Vector2(4, 2),
		"back":   Vector2(4, 2),
		"left":   Vector2(4, 2),
		"right":  Vector2(4, 2),
	},

	BLOCK_TYPES.granite: {
		"top":    Vector2(5, 2),
		"bottom": Vector2(5, 2),
		"front":  Vector2(5, 2),
		"back":   Vector2(5, 2),
		"left":   Vector2(5, 2),
		"right":  Vector2(5, 2),
	},

	# Surface blocks
	BLOCK_TYPES.dirt: {
		"top":    Vector2(3, 0),
		"bottom": Vector2(3, 0),
		"front":  Vector2(3, 0),
		"back":   Vector2(3, 0),
		"left":   Vector2(3, 0),
		"right":  Vector2(3, 0),
	},

	BLOCK_TYPES.coarse_dirt: {
		"top":    Vector2(6, 2),
		"bottom": Vector2(6, 2),
		"front":  Vector2(6, 2),
		"back":   Vector2(6, 2),
		"left":   Vector2(6, 2),
		"right":  Vector2(6, 2),
	},

	# Natural blocks
	BLOCK_TYPES.grass_block: {
		"top":    Vector2(2, 0),
		"bottom": Vector2(0, 0),
		"front":  Vector2(1, 0),
		"back":   Vector2(1, 0),
		"left":   Vector2(1, 0),
		"right":  Vector2(1, 0),
		"material": "grass",
	},

	BLOCK_TYPES.grass: {
		"top":    Vector2(0, 0),
		"bottom": Vector2(0, 0),
		"front":  Vector2(3, 0),
		"back":   Vector2(3, 0),
		"left":   Vector2(0, 0),
		"right":  Vector2(0, 0),
		"material": "foliage",
		"model": "cross",
		"collision": BLOCK_COLLISIONS.pass_through
	},

	BLOCK_TYPES.tall_grass: {
		"top":    Vector2(0, 0),
		"bottom": Vector2(0, 0),
		"front":  Vector2(7, 0),
		"back":   Vector2(7, 0),
		"left":   Vector2(0, 0),
		"right":  Vector2(0, 0),
		"material": "foliage",
		"model": "tall_cross",
		"collision": BLOCK_COLLISIONS.pass_through
	},

	BLOCK_TYPES.oak_log: {
		"top":    Vector2(0, 2),
		"bottom": Vector2(0, 2),
		"front":  Vector2(1, 2),
		"back":   Vector2(1, 2),
		"left":   Vector2(1, 2),
		"right":  Vector2(1, 2),
	},
	
	BLOCK_TYPES.oak_leaves: {
		"top":    Vector2(3, 1),
		"bottom": Vector2(3, 1),
		"front":  Vector2(3, 1),
		"back":   Vector2(3, 1),
		"left":   Vector2(3, 1),
		"right":  Vector2(3, 1),
		"material": "foliage",
	},

	# Building blocks
	BLOCK_TYPES.tnt: {
		"top":    Vector2(4, 0),
		"bottom": Vector2(6, 0),
		"front":  Vector2(5, 0),
		"back":   Vector2(5, 0),
		"left":   Vector2(5, 0),
		"right":  Vector2(5, 0),
	},

	BLOCK_TYPES.cobblestone: {
		"top":    Vector2(3, 1),
		"bottom": Vector2(3, 1),
		"front":  Vector2(3, 1),
		"back":   Vector2(3, 1),
		"left":   Vector2(3, 1),
		"right":  Vector2(3, 1),
	},

	BLOCK_TYPES.stone_bricks: {
		"top":    Vector2(4, 1),
		"bottom": Vector2(4, 1),
		"front":  Vector2(4, 1),
		"back":   Vector2(4, 1),
		"left":   Vector2(4, 1),
		"right":  Vector2(4, 1),
	},

	BLOCK_TYPES.mossy_stone_bricks: {
		"top":    Vector2(5, 1),
		"bottom": Vector2(5, 1),
		"front":  Vector2(5, 1),
		"back":   Vector2(5, 1),
		"left":   Vector2(5, 1),
		"right":  Vector2(5, 1),
	},

	BLOCK_TYPES.bricks: {
		"top":    Vector2(6, 1),
		"bottom": Vector2(6, 1),
		"front":  Vector2(6, 1),
		"back":   Vector2(6, 1),
		"left":   Vector2(6, 1),
		"right":  Vector2(6, 1),
	},
}

enum BLOCK_TYPES {
	# Special
	air,
	cave_air,

	# Terrain
	dirt,
	coarse_dirt,

	stone,
	diorite,
	andesite,
	granite,
	deepslate,
	bedrock,

	# Ores
	coal_ore,
	copper_ore,
	iron_ore,
	gold_ore,
	diamond_ore,
	emerald_ore,
	redstone_ore,
	lapis_ore,

	deepslate_coal_ore,
	deepslate_copper_ore,
	deepslate_iron_ore,
	deepslate_gold_ore,
	deepslate_diamond_ore,
	deepslate_emerald_ore,
	deepslate_redstone_ore,
	deepslate_lapis_ore,

	# Netural
	grass_block,
	grass,
	tall_grass,

	# Leaves
	acacia_leaves,
	oak_leaves,
	spruce_leaves,
	dark_oak_leaves,
	jungle_leaves,
	birch_leaves,

	# Logs
	acacia_log,
	oak_log,
	spruce_log,
	dark_oak_log,
	jungle_log,
	birch_log,

	# Building
	bricks,
	stone_bricks,
	mossy_stone_bricks,
	tnt,
	cobblestone,
}

enum BLOCK_COLLISIONS {
	default,
	pass_through,
	interaction,
}

var BLOCK_GROUPS : Dictionary[String, Array] = {
	"none": [] as Array[BLOCK_TYPES],

	"transparent": [
		BLOCK_TYPES.air,
		BLOCK_TYPES.cave_air,
		BLOCK_TYPES.grass,
		BLOCK_TYPES.tall_grass,
		BLOCK_TYPES.oak_leaves,
	] as Array[BLOCK_TYPES],

	"all": [
		BLOCK_TYPES.air,
		BLOCK_TYPES.cave_air,

		BLOCK_TYPES.dirt,
		BLOCK_TYPES.coarse_dirt,
		BLOCK_TYPES.stone,
		BLOCK_TYPES.diorite,
		BLOCK_TYPES.andesite,
		BLOCK_TYPES.granite,
		BLOCK_TYPES.deepslate,
		BLOCK_TYPES.bedrock,
		
		BLOCK_TYPES.coal_ore,
		BLOCK_TYPES.copper_ore,
		BLOCK_TYPES.iron_ore,
		BLOCK_TYPES.gold_ore,
		BLOCK_TYPES.diamond_ore,
		BLOCK_TYPES.emerald_ore,
		BLOCK_TYPES.redstone_ore,
		BLOCK_TYPES.lapis_ore,

		BLOCK_TYPES.deepslate_coal_ore,
		BLOCK_TYPES.deepslate_copper_ore,
		BLOCK_TYPES.deepslate_iron_ore,
		BLOCK_TYPES.deepslate_gold_ore,
		BLOCK_TYPES.deepslate_diamond_ore,
		BLOCK_TYPES.deepslate_emerald_ore,
		BLOCK_TYPES.deepslate_redstone_ore,
		BLOCK_TYPES.deepslate_lapis_ore,

		BLOCK_TYPES.grass_block,
		BLOCK_TYPES.grass,
		BLOCK_TYPES.tall_grass,
		
		BLOCK_TYPES.acacia_leaves,
		BLOCK_TYPES.oak_leaves,
		BLOCK_TYPES.spruce_leaves,
		BLOCK_TYPES.dark_oak_leaves,
		BLOCK_TYPES.jungle_leaves,
		BLOCK_TYPES.birch_leaves,
		
		BLOCK_TYPES.acacia_log,
		BLOCK_TYPES.oak_log,
		BLOCK_TYPES.spruce_log,
		BLOCK_TYPES.dark_oak_log,
		BLOCK_TYPES.jungle_log,
		BLOCK_TYPES.birch_log,

		BLOCK_TYPES.bricks,
		BLOCK_TYPES.stone_bricks,
		BLOCK_TYPES.mossy_stone_bricks,
		BLOCK_TYPES.tnt,
		BLOCK_TYPES.cobblestone,
	] as Array[BLOCK_TYPES],
	
	"ores": [
		BLOCK_TYPES.coal_ore,
		BLOCK_TYPES.copper_ore,
		BLOCK_TYPES.iron_ore,
		BLOCK_TYPES.gold_ore,
		BLOCK_TYPES.diamond_ore,
		BLOCK_TYPES.emerald_ore,
		BLOCK_TYPES.redstone_ore,
		BLOCK_TYPES.lapis_ore,

		BLOCK_TYPES.deepslate_coal_ore,
		BLOCK_TYPES.deepslate_copper_ore,
		BLOCK_TYPES.deepslate_iron_ore,
		BLOCK_TYPES.deepslate_gold_ore,
		BLOCK_TYPES.deepslate_diamond_ore,
		BLOCK_TYPES.deepslate_emerald_ore,
		BLOCK_TYPES.deepslate_redstone_ore,
		BLOCK_TYPES.deepslate_lapis_ore,
	] as Array[BLOCK_TYPES],

	"underground_top": [
		BLOCK_TYPES.stone,
		BLOCK_TYPES.andesite,
		BLOCK_TYPES.diorite,
		BLOCK_TYPES.granite,
		
		BLOCK_TYPES.coal_ore,
		BLOCK_TYPES.copper_ore,
		BLOCK_TYPES.iron_ore,
		BLOCK_TYPES.gold_ore,
		BLOCK_TYPES.diamond_ore,
		BLOCK_TYPES.emerald_ore,
		BLOCK_TYPES.redstone_ore,
		BLOCK_TYPES.lapis_ore,
	] as Array[BLOCK_TYPES],

	"foliage_can_spawn_on": [
		BLOCK_TYPES.grass_block,
	] as Array[BLOCK_TYPES],

	"foliage": [
		BLOCK_TYPES.grass,
		BLOCK_TYPES.tall_grass,
		BLOCK_TYPES.oak_leaves,
	] as Array[BLOCK_TYPES],

	"grass": [
		BLOCK_TYPES.grass,
		BLOCK_TYPES.tall_grass,
	] as Array[BLOCK_TYPES],

	"leaves": [
		BLOCK_TYPES.acacia_leaves,
		BLOCK_TYPES.oak_leaves,
		BLOCK_TYPES.spruce_leaves,
		BLOCK_TYPES.dark_oak_leaves,
		BLOCK_TYPES.jungle_leaves,
		BLOCK_TYPES.birch_leaves,
	] as Array[BLOCK_TYPES],

	"logs": [
		BLOCK_TYPES.acacia_log,
		BLOCK_TYPES.oak_log,
		BLOCK_TYPES.spruce_log,
		BLOCK_TYPES.dark_oak_log,
		BLOCK_TYPES.jungle_log,
		BLOCK_TYPES.birch_log,
	] as Array[BLOCK_TYPES],

	"surface_blocks": [
		BLOCK_TYPES.grass_block,
		BLOCK_TYPES.dirt,
		BLOCK_TYPES.coarse_dirt,
	] as Array[BLOCK_TYPES],
}

func get_block_group(group_name : String = "all") -> Array[BLOCK_TYPES]:
	if group_name in BLOCK_GROUPS: return BLOCK_GROUPS[group_name]
	return BLOCK_GROUPS["none"]

func get_block_id(block_name : String) -> BLOCK_TYPES:
	if block_name in BLOCK_TYPES: return BLOCK_TYPES.get(block_name)
	return BLOCK_TYPES.air

func get_block_name(block_id : BLOCK_TYPES) -> String:
	return BLOCK_TYPES.find_key(block_id)

func is_air(block_id : BLOCK_TYPES) -> bool:
	return block_id in [BLOCK_TYPES.air, BLOCK_TYPES.cave_air]

func get_block_material(block_id : BLOCK_TYPES) -> String:
	# Possible materials:
	# - default
	# - foliage
	# - glow

	var block_data = BLOCKS[block_id]

	if "material" in block_data: return block_data["material"]
	return "default"

func get_block_model(block_id : BLOCK_TYPES) -> String:
	# Possible models:
	# - cube
	# - cross
	# - tall_cross

	var block_data = BLOCKS[block_id]

	if "model" in block_data: return block_data["model"]
	return "cube"

func get_block_collision(block_id : BLOCK_TYPES) -> BLOCK_COLLISIONS:
	var block_data = BLOCKS[block_id]

	if "collision" in block_data: return block_data["collision"]
	return BLOCK_COLLISIONS.default
