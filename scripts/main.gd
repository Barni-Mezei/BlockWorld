extends Node

@onready var _world_environment_node = %WorldEnvironment
@onready var _player = %Player
@onready var _terrain = %Terrain
@onready var _ui = %UI
@onready var _orbit_camera_container = %OrbitCameraContainer

@export var enable : bool
@export var world_env : Environment
@export var camera_attributes : CameraAttributes


func _ready() -> void:
	if enable:
		_world_environment_node.environment = world_env
		_world_environment_node.camera_attributes = camera_attributes
	else:
		_world_environment_node.environment = null
		_world_environment_node.camera_attributes = null

	# Spawn player at the surface
	_player.position.y = _terrain.TERRAIN_GENERATOR.chunk_size.y * _terrain.BLOCK_SIZE.y + 1
	_player.freeze()

	_terrain.chunk_finished.connect(_chunk_finished)
	_terrain.generation_finished.connect(_generation_finished)
	_terrain.output_text.connect(_log_text)

	_terrain.generate_terrain()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("game_camera"):
		_orbit_camera_container.visible = not _orbit_camera_container.visible

func _chunk_finished(chunk_pos : Vector2i) -> void:
	var percent = (float(_terrain.progress) / _terrain.progress_max) * 100;

	_ui.set_progress(percent, _terrain.progress, _terrain.progress_max)
	_ui.update_chunk(chunk_pos)

func _log_text(txt : String) -> void:
	_ui.log_text(txt)

func _generation_finished() -> void:
	_ui.hide_loading_screen()
	_player.unfreeze()
