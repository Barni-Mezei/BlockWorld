extends Node

@export var generator_seed : int = -1
@export var min_value : float = 0
@export var max_value : float = 1

const number_of_masks : int = 20

var rng : RandomNumberGenerator
var seed_masks : PackedInt64Array

func _ready() -> void:
	randomize()

func set_seed(new_seed : int) -> void:
	generator_seed = new_seed
	rng = RandomNumberGenerator.new()
	rng.seed = new_seed
	var clean_state = rng.state

	generate_masks()

	rng.state = clean_state

func generate_masks() -> void:
	seed_masks.clear()
	seed_masks.resize(number_of_masks)

	for i in range(number_of_masks):
		seed_masks[i] = rng.randi()

func get_sub_seed(mask_index : int = 0) -> int:
	return generator_seed & seed_masks[mask_index]

func get_noise_at(x : int, y : int, variant : int = 0) -> float:
	var value : int = (x * get_sub_seed(variant) + y * get_sub_seed(variant+1) ) ^ get_sub_seed(variant+2)

	return remap(value, -9223372036854775808, 9223372036854775807, min_value, max_value)

func get_noise_atv(pos : Vector2i, variant : int = 0) -> float:
	return get_noise_at(pos.x, pos.y, variant)
