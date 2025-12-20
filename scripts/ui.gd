extends Control

signal start_generation

@export var SLOT_SIZE : float = 20.0
@export var SLOT_ORIGIN : Vector2 = Vector2(-1, -1)

@warning_ignore("unused_private_class_variable")
@onready var _experience_bar = %ExperienceBar
@warning_ignore("unused_private_class_variable")
@onready var _health_bar = %HealthBar
@warning_ignore("unused_private_class_variable")
@onready var _food_bar = %FoodBar
@onready var _hotbar_selected_slot = %SelectedSlot

# Debug menu
@onready var _debug_menu = %DebugMenu
@onready var _fps_label = %FpsLabel
@onready var _debug_info = %DebugInfo
@onready var _system_debug_info = %SystemDebugInfo
@onready var _player_pos = %PlayerPos
@onready var _player_block_pos = %PlayerBlockPos
@onready var _player_chunk_pos = %PlayerChunkPos
@onready var _player_view_block_pos = %PlayerViewBlockPos
@onready var _player_view_block_info = %PlayerViewBlockInfo

# Loading screen
@onready var _loading_screen = %LoadingScreen
@onready var _log_text: Label = %LogText
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_value: Label = %ProgressValue
@onready var _generate_button = %Generate

var selected_slot : int = 0
var image : Image

var hotbar : Array[Blocks.BLOCK_TYPES] = [
	Blocks.BLOCK_TYPES.stone,
	Blocks.BLOCK_TYPES.oak_log,
	Blocks.BLOCK_TYPES.bricks,
	Blocks.BLOCK_TYPES.stone_bricks,
	Blocks.BLOCK_TYPES.dirt,
	Blocks.BLOCK_TYPES.coarse_dirt,
	Blocks.BLOCK_TYPES.iron_ore,
	Blocks.BLOCK_TYPES.deepslate,
	Blocks.BLOCK_TYPES.tnt,
]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 4 and event.pressed: selected_slot -= 1
		if event.button_index == 5 and event.pressed: selected_slot += 1

	selected_slot = clamp(selected_slot, 0, 8)

	_hotbar_selected_slot.position = SLOT_ORIGIN + Vector2(SLOT_SIZE * selected_slot, 0)

	Global.player_selected_block = hotbar[selected_slot]

func _ready() -> void:
	update_world_size()

	Global.player_selected_block = hotbar[0]

	SignalBus.chunk_changed.connect(update_chunk_display)

	_generate_button.pressed.connect(func ():
		_generate_button.disabled = true
		start_generation.emit()
	)

	await get_tree().process_frame

	start_generation.emit()
	_generate_button.disabled = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("game_ui_toggle_debug_screen"):
		_debug_menu.visible = not _debug_menu.visible

	# Update debug menu
	_fps_label.value = str(Engine.get_frames_per_second())
	_debug_info.text = "E: %d D: %d P: %d" % [
		get_node("/root/Main/Entity").get_child_count(),
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
	]

	@warning_ignore("narrowing_conversion")
	_system_debug_info.text = "vRAM: %s" % [
		String.humanize_size(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	]

	var p = Global.player_pos
	var bp = round(Global.player_pos - Vector3(0, 0.5, 0)) + Vector3(0, 0.5, 0)
	var cp = floor(Global.player_chunk_pos)
	var lp = Global.player_view_block_pos

	var target_block_position = Vector3(lp) - Global.global_origin_offset + Vector3(0, -1, 0)
	var target_block_data = TerrainGenerator.get_block_from_world(Vector3i(target_block_position))

	_player_pos.text = "Pos XZY: %.4f %.4f %.4f" % [p.x, p.y, p.z]
	_player_block_pos.text = "Block pos XYZ: %d %d %d" % [bp.x, bp.y, bp.z]
	_player_chunk_pos.text = "Chunk pos XYZ: %d %d %d" % [cp.x, bp.y, cp.y]

	if Global.player_view_has_block:
		_player_view_block_pos.text = "Target XYZ: %d %d %d" % [lp.x, lp.y, lp.z]
		_player_view_block_info.text = "Block type: %s\nLight level: %d\nBiome: %s" % [
			Blocks.BLOCK_TYPES.find_key(target_block_data["block_type"]),
			target_block_data["light_level"],
			Blocks.BIOMES.find_key(target_block_data["biome"])
		]
	else:
		_player_view_block_pos.text = ""
		_player_view_block_info.text = ""


func log_text(txt : String) -> void:
	_log_text.text = txt

func set_progress(value : float, progress : int, max_progress : int) -> void:
	_progress_bar.value = value
	_progress_value.text = "%d/%d" % [progress, max_progress]

func update_world_size() -> void:
	if TerrainGenerator.max_world_size.x == 0 or TerrainGenerator.max_world_size.y == 0: return

	image = Image.create_empty(TerrainGenerator.max_world_size.x + 2, TerrainGenerator.max_world_size.y + 2, false, Image.FORMAT_RGB8)
	image.fill(Color.BLACK)

	for map in get_tree().get_nodes_in_group("ChunkMap"):
		map.texture = ImageTexture.create_from_image(image)

func update_chunk_display(chunk_pos : Vector2i, type : String) -> void:
	if chunk_pos.x < 0 or chunk_pos.x > image.get_width() or\
	   chunk_pos.y < 0 or chunk_pos.y > image.get_height():
		return

	var color = Color.from_rgba8(64, 64, 64, 255)
	match type:
		"generated": color = Color.from_rgba8(128, 128, 128, 255) # Voxel data is generated
		"building": color = Color.from_rgba8(0, 192, 0, 255) # Started constructing the mesh
		"finished": color = Color.from_rgba8(192, 192, 192, 255) # Mesh is constructed

	image.set_pixelv(chunk_pos + Vector2i(1, 1), color)

	for map in get_tree().get_nodes_in_group("ChunkMap"):
		map.texture.update(image)

func hide_loading_screen() -> void:
	_loading_screen.hide()
