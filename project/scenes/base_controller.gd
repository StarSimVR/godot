class_name BaseController
extends Spatial

onready var _space := get_node("/root/Main/Objects/Space")

func slower() -> void:
	var _objects := get_node("/root/Main/Objects/Space").get_children()
	for object in _objects:
		object.slower()

func faster() -> void:
	var _objects := get_node("/root/Main/Objects/Space").get_children()
	for object in _objects:
		object.faster()

func prev_warp_point() -> void:
	_space._curr_object -= 1
	if _space._curr_object == 0:
		_space._curr_object = _space.get_child_count() - 1

func next_warp_point() -> void:
	_space._curr_object += 1
	if _space._curr_object == _space.get_child_count():
		_space._curr_object = 1
