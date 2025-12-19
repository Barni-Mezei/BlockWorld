@icon("res://ui/icons/RegionEdit.svg")

extends Resource
class_name TerrainGeneratorSettings

@export_group("Generation settings")
@export_subgroup("Landscape settings")
@export var terrain_start : int = 32
@export var terrain_end : int = 64
@export var deepslate_level : int = 16
@export_subgroup("Noises")
@export var height_noise : FastNoiseLite
@export var biome_noise : FastNoiseLite
@export var cave_noise : FastNoiseLite
@export var river_noise : FastNoiseLite

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

@export_group("Feature frequencies")
@export var underground_patch_frequency : int = 1500
@export var tree_frequency : int = 40
@export var foliage_frequency : int = 3
@export var mud_frequency : int = 80
@export_range(0, 5.0, 0.01) var iron_ore_multiplier : float = 0.75

@export_group("Depth dependent values")
@export var iron_ore_distribution : Curve
@export var coal_ore_distribution : Curve
@export var diamond_ore_distribution : Curve

@export var underground_patch_size : Curve
@export var noise_cave_size_stone : Curve
@export var noise_cave_size_deepslate : Curve
