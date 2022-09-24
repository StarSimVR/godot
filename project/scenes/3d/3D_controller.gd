extends BaseController

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("slower"):
		slower()
	if Input.is_action_just_pressed("faster"):
		faster()
	if Input.is_action_just_pressed("prev_warp_point"):
		prev_warp_point()
	if Input.is_action_just_pressed("next_warp_point"):
		next_warp_point()
	if Input.is_action_just_pressed("go_to_start"):
		var _err = get_tree().change_scene("res://scenes/start.tscn")
