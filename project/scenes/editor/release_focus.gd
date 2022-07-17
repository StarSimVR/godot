extends LineEdit

func _is_pos_in(checkpos: Vector2):
	var r := get_global_rect()
	return checkpos.x >= r.position.x && checkpos.y >= r.position.y && checkpos.x < r.end.x && checkpos.y < r.end.y

func _input(event):
	if event is InputEventMouseButton && !_is_pos_in(event.position):
		release_focus()
