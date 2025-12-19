extends Control

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
@onready var _fps_label = %FpsLabel
@onready var _entity_count = %EntityCount

# Loading screen
@onready var _loading_screen = %LoadingScreen
@onready var _image: TextureRect = %Image
@onready var _log_text: Label = %LogText
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_value: Label = %ProgressValue

var selected_slot : int = 0
var image : Image

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 4 and event.pressed: selected_slot -= 1
		if event.button_index == 5 and event.pressed: selected_slot += 1

	selected_slot = clamp(selected_slot, 0, 8)

	_hotbar_selected_slot.position = SLOT_ORIGIN + Vector2(SLOT_SIZE * selected_slot, 0)

func _ready() -> void:
	image = Image.create_empty(64, 64, false, Image.FORMAT_RGB8)
	image.fill(Color.BLACK)

	_image.texture = ImageTexture.create_from_image(image)

func _process(_delta: float) -> void:
	_fps_label.value = str(Engine.get_frames_per_second())
	_entity_count.value = str(get_node("/root/Main/Entity").get_child_count())

func log_text(txt : String) -> void:
	_log_text.text = txt

func set_progress(value : float, progress : int, max_progress : int) -> void:
	_progress_bar.value = value
	_progress_value.text = "%d/%d" % [progress, max_progress]

func update_chunk(chunk_pos : Vector2i) -> void:
	image.set_pixelv(chunk_pos, Color.from_rgba8(0, 192, 0))

	_image.texture.update(image)

func hide_loading_screen() -> void:
	_loading_screen.hide()
