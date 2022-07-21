class_name BaseCamera
extends Camera


onready var _math_objects := get_node("/root/Main/Objects/Space/MathObjects")
onready var _labels := get_node("/root/Main/Objects/CanvasLayer/Labels")
var motion_trail_scene := preload("res://MotionTrail/MotionTrail.tscn")
var collision_object_scene := preload("res://scenes/collision_object.tscn")

##++++The Base Camera currently has no features that both the vr and the 3D camera need, hence it is empty++++
##++++This may change in the future, given more overlap++++
