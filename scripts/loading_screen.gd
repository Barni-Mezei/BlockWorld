extends Control

@onready var _progress_bar = %ProgressBar

@export_file_path("*.tscn") var main_scene_path : String

func _ready() -> void:
	var scene = ResourceLoader.load(main_scene_path)
	print(scene)
	get_tree().change_scene_to_packed(scene)

func _process(_delta: float) -> void:
	_progress_bar.value = randf_range(0, 100)
