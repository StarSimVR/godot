class_name BaseController
extends Spatial

onready var _objects := get_node("/root/Main/Objects/Space").get_children()

func slower() -> void:
	for object in _objects:
		object.slower()

func faster() -> void:
	for object in _objects:
		object.faster()
