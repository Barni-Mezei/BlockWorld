extends Node

@warning_ignore("unused_signal")
signal terrain_changed(pos : Vector3i, block_type : Blocks.BLOCK_TYPES)

@warning_ignore("unused_signal")
signal chunk_changed(chunk_pos : Vector2i, status : String)

@warning_ignore("unused_signal")
signal block_changed(pos : Vector3i, block_type : Blocks.BLOCK_TYPES)
