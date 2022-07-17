class_name BaseController
extends Spatial

onready var _space := get_node("/root/Main/Objects/Space")
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
	var _objects := get_node("/root/Main/Objects/Space/").get_children()
	for object in _objects:
		if object.name == "Stars":
			continue
		object.slower()

func faster() -> void:
	if SceneDecoder.is_editor:
		return
	var _objects := get_node("/root/Main/Objects/Space/").get_children()
	for object in _objects:
		if object.name == "Stars":
			continue
		object.faster()

func prev_warp_point() -> void:
	_space._curr_object -= 1
	if _space._curr_object == 0:
		_space._curr_object = _space.get_child_count() - 1

func next_warp_point() -> void:
	_space._curr_object += 1
	if _space._curr_object == _space.get_child_count():
		_space._curr_object = 1
