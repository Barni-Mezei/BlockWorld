extends HBoxContainer
class_name ValueLabel

@onready var _title = %Title
@onready var _value = %Value

@export var title : String = "Value:":
	get():
		return title
	set(v):
		if _title: _title.text = str(v)
		title = v

@export var value : String = "0":
	get():
		return value
	set(v):
		if _value: _value.text = str(v)
		value = v

func _ready() -> void:
	_title.text = title
	_value.text = str(value)
