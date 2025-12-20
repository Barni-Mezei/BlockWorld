extends Node

var player_pos : Vector3
var player_chunk_pos : Vector2
var player_view_block_pos : Vector3i
var player_place_block_pos : Vector3i
var player_view_has_block : bool

var player_selected_block : Blocks.BLOCK_TYPES

var global_origin_offset : Vector3

var intial_generation_finshed : bool = false
