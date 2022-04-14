class_name BaseController
extends Spatial

func slower() -> void:
	var _objects := get_node("/root/Main/Objects/Space").get_children()
	for object in _objects:
		object.slower()

func faster() -> void:
	var _objects := get_node("/root/Main/Objects/Space").get_children()
	for object in _objects:
		object.faster()
