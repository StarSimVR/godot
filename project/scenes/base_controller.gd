class_name BaseController
extends Spatial

onready var _math_objects := get_node("/root/Main/Objects/Space/MathObjects")
const TIMER_LIMIT = 1.0
var timer = 0.0

func _process(delta):
	timer += delta
	if timer >= TIMER_LIMIT:
		timer = 0.0
		print("FPS: ", Engine.get_frames_per_second())

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
	if _math_objects.speed >= _math_objects.speed_upper_bound:
		_math_objects.speed = _math_objects.speed_upper_bound


func prev_warp_point() -> void:
	_math_objects._curr_object -= 1
	if _math_objects._curr_object == 0:
		_math_objects._curr_object = _math_objects.get_child_count() - 1

func next_warp_point() -> void:
	_math_objects._curr_object += 1
	if _math_objects._curr_object == _math_objects.get_child_count():
		_math_objects._curr_object = 1
