extends Control

func _on_Start3D_pressed():
	var _err = get_tree().change_scene("res://scenes/3d/3d.tscn")

func _on_StartVR_pressed():
	var _err = get_tree().change_scene("res://scenes/vr/vr.tscn")
