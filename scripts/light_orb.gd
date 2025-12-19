extends RigidBody3D

@onready var _light = $OmniLight3D
@onready var _mesh = $MeshInstance3D

@export var life_time : float = 20.0

var start_time : float

func _ready() -> void:
	start_time = Time.get_ticks_msec()
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	var progress = remap(current_time - start_time, 0, life_time * 1000, 1,0)
	_light.light_energy = progress
	_mesh.mesh.material.albedo_color.a = progress * 0.25
