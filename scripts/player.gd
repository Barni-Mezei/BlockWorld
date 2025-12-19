extends CharacterBody3D
class_name PLayer

@onready var _camera : Camera3D = %Camera3D
@onready var _spawner = %Spawner
@onready var _selected_block = %SelectedBlock
@onready var _vision_ray: RayCast3D = %VisionRay
@onready var _point: MeshInstance3D = $Point

@export var SPEED : float = 5.0
@export var RUNNING_SPEED : float = 10.0
@export var JUMP_VELOCITY : float = 6.5
@export var GRAVITY : Vector3 = Vector3(0, -20.0, 0)
@export var TURN_YAW_SPEED : float = 3.0
@export var TURN_PITCH_SPEED : float = 3.0
@export var MOUSE_SENSITIVITY : float = 0.2

@export var ORB_SCENE : PackedScene
@export var ORB_SPEED : float = 100
@export var ORB_SPREAD : float = 5.0

var current_speed : float = SPEED
var frozen : bool = false

var _pitch : float = 0
var _yaw : float = 0

func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Default rotation
	_yaw = rad_to_deg(self.rotation.y)
	_pitch = rad_to_deg(_camera.rotation.x)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("game_escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#get_tree().quit()

	if Input.is_action_pressed("game_respawn"):
		position = Vector3(0, 64, 0)
		velocity = Vector3.ZERO

	if Input.is_action_pressed("place_block"):
		var new_orb = ORB_SCENE.instantiate()
		get_node("/root/Main/Entity").add_child(new_orb)
		new_orb.global_position = _spawner.global_position
		var dir = _spawner.global_position - _camera.global_position
		var rand = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * ORB_SPREAD
		new_orb.apply_force(
			velocity + dir.normalized() * ORB_SPEED + rand,
			Vector3(0, 0, 0)
		)

	if _vision_ray.is_colliding():
		_selected_block.show()
		#_point.show()
		var pos = _vision_ray.get_collision_point()
		var norm = _vision_ray.get_collision_normal()
		_point.global_position = pos
		_selected_block.global_position = round(pos - norm * 0.01 - Vector3(0, 0.5, 0)) + Vector3(0, 0.5, 0)
		_selected_block.global_rotation = Vector3.ZERO
	else:
		_selected_block.hide()
		#_point.hide()

func _unhandled_input(event: InputEvent) -> void:
	if frozen:
		velocity = Vector3.ZERO
		return
		
	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

		_yaw -= event.relative.x * MOUSE_SENSITIVITY
		_pitch -= event.relative.y * MOUSE_SENSITIVITY

		_pitch = clamp(_pitch, -90, 90)

	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if frozen:
		velocity = Vector3.ZERO
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var new_speed = SPEED
	if Input.is_action_pressed("run"): new_speed = RUNNING_SPEED

	current_speed = lerp(current_speed, new_speed, 0.5)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	var turn_yaw = Input.get_axis("look_right", "look_left")
	var turn_pitch = Input.get_axis("look_down", "look_up")
	if abs(turn_yaw) > 0.1: _yaw += turn_yaw * TURN_YAW_SPEED
	if abs(turn_pitch) > 0.1: _pitch += turn_pitch * TURN_YAW_SPEED
	
	self.rotation.y = deg_to_rad(_yaw)
	_camera.rotation.x = deg_to_rad(_pitch)

	Global.player_pos = position

	move_and_slide()

func freeze() -> void: frozen = true
func unfreeze() -> void: frozen = false
