extends BaseController

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("slower"):
		slower()
	if Input.is_action_just_pressed("faster"):
		faster()
