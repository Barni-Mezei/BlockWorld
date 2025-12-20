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
	#_player.position.y = TerrainGenerator.chunk_size.y * _terrain.BLOCK_SIZE.y + 1
	_player.position.y = 128
	_player.freeze()

	SignalBus.chunk_changed.connect(_chunk_changed)
	_terrain.generation_finished.connect(_generation_finished)
	_terrain.output_text.connect(_log_text)
	_ui.start_generation.connect(func (): _terrain.generate_terrain())

	_ui.update_world_size()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("game_change_camera"):
		_orbit_camera_container.visible = not _orbit_camera_container.visible

func _chunk_changed(chunk_pos : Vector2i, type : String) -> void:
	_ui.update_chunk_display(chunk_pos, type)

	if type == "finished":
		var percent = (float(_terrain.progress) / _terrain.progress_max) * 100;

		_ui.set_progress(percent, _terrain.progress, _terrain.progress_max)

func _log_text(txt : String) -> void:
	_ui.log_text(txt)

func _generation_finished() -> void:
	_player.unfreeze()
	_ui.hide_loading_screen()
