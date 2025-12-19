extends Node3D

@onready var camera = $Camera3D

@export_range(0.01, 5.0, 0.01) var orbit_speed : float = 0.25

var angle = 0

func _process(delta: float) -> void:
	angle += delta * 10
	self.rotate_y(deg_to_rad(orbit_speed))

	#var depth : int = 32
#
	#var start = 100 - depth/2.0 - 0.5
	#var end = 100 + depth/2.0 - 0.5
	#
	#var d = end - start
#
	#camera.near = start + fmod(angle, d)
	#camera.far = camera.near + 1
