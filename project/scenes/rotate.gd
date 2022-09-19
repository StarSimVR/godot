extends Spatial

export(bool) var is_editor = false
onready var _math_objects := get_node("/root/Main/Objects/Space/MathObjects")

func _process(delta) -> void:
	if !is_editor:
		rotate_z(_math_objects.speed * delta)

func slower() -> void:
	if SceneDecoder.is_editor:
		return
	if _math_objects.speed <= 1:
		_math_objects.speed = 0
		return
	_math_objects.speed /= 2


func faster() -> void:
	if SceneDecoder.is_editor:
		return
	if _math_objects.speed == 0:
		_math_objects.speed = 1
		return
	_math_objects.speed *= 2
