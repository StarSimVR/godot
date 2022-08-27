extends Control

const WIDTH := 5

onready var camera: Camera = get_node("/root/Main/3D/Camera")
onready var editor: Control = get_parent().get_node("GUI/Editor")

# Local coordinate system
var zero_point := Vector3.ZERO
var axis_length := 0

# Drawn vector
var origin := Vector3.ZERO
var dir := Vector3.ZERO

# Vector drawing (data that is only important at drawing time)
var offset_z := 0.0
var new_origin := Vector3.ZERO
var motion_start := Vector2.ZERO
var motion_end := Vector2.ZERO

# Selected object
var clicked := ""
var clicked_obj: Spatial

# Planet moving
var dragging_axis := Vector3.ZERO
var start_position := Vector3.ZERO

func _draw() -> void:
	if axis_length > 0:
		draw_axes()

	draw_vector(origin, origin + dir, Color(0, 1, 1), WIDTH)

# If part of the vector is behind the camera, then this function cuts the vector using a binary search
func _find_visible_start_recursive(start: Vector3, end: Vector3, l: Vector3, r: Vector3) -> Vector3:
	if (r - l).length() < 0.1:
		return r

	var middle := 0.5 * (l + r)
	if camera.is_position_behind(middle):
		return _find_visible_start_recursive(start, end, middle, r)
	else:
		return _find_visible_start_recursive(start, end, l, middle)

func find_visible_start(start: Vector3, end: Vector3) -> Vector3:
	return _find_visible_start_recursive(start, end, start, end)

func has_collision(point: Vector3) -> bool:
	var collision_check := camera.get_world().direct_space_state.intersect_ray(
		camera.global_transform.origin, point, [], 2147483647, true, true
	)
	return !collision_check.empty()

func draw_vector(start_world: Vector3, end_world: Vector3, color: Color, width: int, is_marker := false) -> void:
	var is_start_behind := camera.is_position_behind(start_world)
	var is_end_behind := camera.is_position_behind(end_world)
	if start_world == end_world || is_start_behind && is_end_behind:
		return

	if is_start_behind:
		start_world = find_visible_start(start_world, end_world)
	elif is_end_behind:
		end_world = find_visible_start(end_world, start_world)

	var middle_world := 0.5 * (start_world + end_world)
	if is_marker || !has_collision(start_world) || !has_collision(middle_world) || !has_collision(end_world):
		var start_screen := camera.unproject_position(start_world)
		var end_screen := camera.unproject_position(end_world)
		draw_line(start_screen, end_screen, color, width)
		if !is_marker:
			draw_triangle(end_screen, start_screen.direction_to(end_screen), color, width * 2)

func draw_triangle(pos: Vector2, tr_dir: Vector2, color: Color, size: int) -> void:
	var a := pos + tr_dir * size
	var b := pos + tr_dir.rotated(2 * PI / 3) * size
	var c := pos + tr_dir.rotated(4 * PI / 3) * size
	var points := PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))

func draw_axes() -> void:
	# Axes
	draw_vector(zero_point, zero_point + Vector3(axis_length, 0, 0), Color(1, 0, 0), WIDTH)
	draw_vector(zero_point, zero_point + Vector3(0, axis_length, 0), Color(0, 1, 0), WIDTH)
	draw_vector(zero_point, zero_point + Vector3(0, 0, axis_length), Color(0, 0, 1), WIDTH)

	# Markers
	var end := origin + dir
	draw_vector(
		Vector3(end.x - 0.1, zero_point.y, zero_point.z),
		Vector3(end.x + 0.1, zero_point.y, zero_point.z),
		Color(1, 0.7, 0.7), WIDTH, true
	)
	draw_vector(
		Vector3(zero_point.x, end.y - 0.1, zero_point.z),
		Vector3(zero_point.x, end.y + 0.1, zero_point.z),
		Color(0.7, 1, 0.7), WIDTH, true
	)
	draw_vector(
		Vector3(zero_point.x, zero_point.y, zero_point.z + offset_z - 0.1),
		Vector3(zero_point.x, zero_point.y, zero_point.z + offset_z + 0.1),
		Color(0.7, 0.7, 1), WIDTH, true
	)

func _process(delta: float) -> void:
	update()

	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if Input.is_action_pressed("decrease_z_when_dragging_vector"):
			offset_z -= delta
			set_vector()
		elif Input.is_action_pressed("increase_z_when_dragging_vector"):
			offset_z += delta
			set_vector()

func calc_collision(event: InputEvent) -> Dictionary:
	var from: Vector3 = camera.project_ray_origin(event.get_position())
	var to: Vector3 = from + camera.project_ray_normal(event.get_position()) * 1000
	var result := camera.get_world().direct_space_state.intersect_ray(from, to, [], 2147483647, true, true)
	if result.empty():
		return {"not_found": true}
	var object: Spatial = result.collider.get_parent()
	return {"name": object.name, "position": result.position, "object": object}

func calc_dir(origin_world: Vector3, dir_screen: Vector2) -> Vector3:
	var origin_screen := camera.unproject_position(origin)
	var end_screen := origin_screen + dir_screen
	var end_world_ray_origin := camera.project_ray_origin(end_screen)
	var end_world_ray_normal := camera.project_ray_normal(end_screen)
	var target_z := origin_world.z + offset_z
	# k is calculated so that end_world.z=target_z
	var k := (target_z - end_world_ray_origin.z) / end_world_ray_normal.z
	var end_world := end_world_ray_origin + k * end_world_ray_normal
	var dir_world := end_world - origin_world
	return dir_world

func set_vector() -> void:
	if motion_end == Vector2.ZERO:
		origin = Vector3.ZERO
		dir = Vector3.ZERO
	else:
		origin = new_origin
		var new_dir_screen := motion_end - motion_start
		dir = calc_dir(origin, new_dir_screen)

func drag_planet() -> void:
	var obj: Dictionary = editor.obj
	if dragging_axis == Vector3.ZERO || obj.has("not_found"):
		return

	var zero := zero_point
	var axis_end := zero_point + dragging_axis
	var axis := axis_end - zero
	var dir_corrected := dir if dragging_axis != Vector3.BACK else -Vector3(dir.x, 0, dir.y)
	var move := dir_corrected.project(axis)
	if true:
		clicked_obj.transform.origin = start_position + move
		zero_point = clicked_obj.transform.origin
	else:
		var new_pos := Vector3(obj.position[0], obj.position[1], obj.position[2]) + move
		editor.obj.position = [new_pos.x * 1e7, new_pos.y * 1e7, new_pos.z * 1e7]
		editor.save()

func calc_distance_to_axis(pos: Vector2, axis: Vector3) -> float:
	var zero := camera.unproject_position(zero_point)
	var axis_end := camera.unproject_position(zero_point + axis)
	var n: Vector2 = axis_end - zero
	var distance := abs((pos - zero).cross(n) / n.length())
	return distance

func set_dragging_axis(pos: Vector2) -> void:
	var threshold := 10
	var x_distance := calc_distance_to_axis(pos, Vector3.RIGHT)
	var y_distance := calc_distance_to_axis(pos, Vector3.UP)
	var z_distance := calc_distance_to_axis(pos, Vector3.BACK)
	if x_distance < threshold && y_distance > x_distance && z_distance > x_distance:
		dragging_axis = Vector3.RIGHT
	elif y_distance < threshold && z_distance > y_distance:
		dragging_axis = Vector3.UP
	elif z_distance < threshold:
		dragging_axis = Vector3.BACK
	else:
		dragging_axis = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if editor.gui_dragging:
		return

	if event is InputEventMouseButton && event.get_button_index() == BUTTON_LEFT:
		# Left mouse button pressed
		if event.is_pressed():
			var pos: Vector2 = event.get_position()
			var collision := calc_collision(event)
			clicked = collision.name if "name" in collision else ""
			clicked_obj = collision.object if clicked else null
			new_origin = collision.position if clicked else Vector3.ZERO
			motion_start = pos
			offset_z = 0 if clicked else offset_z
			set_dragging_axis(pos)
			start_position = clicked_obj.transform.origin if clicked else Vector3.ZERO
		# Left mouse button released & a planet is selected
		elif clicked:
			set_vector()
			drag_planet()

			editor.load_object(clicked)
			camera.enable()
			clicked = ""
			var obj: Dictionary = editor.obj
			zero_point = clicked_obj.transform.origin
			axis_length = int(max(1, round(obj.scale[0] * 2)))
		# Left mouse button released & no planet is selected
		else:
			editor.unload_object()
		motion_end = Vector2.ZERO
	elif event is InputEventMouseMotion && event.get_button_mask() == BUTTON_LEFT && clicked:
		camera.disable()
		motion_end = event.get_position()
		set_vector()
		drag_planet()
