extends Control

const WIDTH := 5

onready var camera: Camera = get_node("/root/Main/3D/Camera")
onready var editor := get_parent().get_node("GUI/Editor")
onready var full_editor := get_parent().get_node("GUI/FullEditor")
onready var draw_button := get_parent().get_node("GUI/FullEditor/Buttons/Draw")

# Local coordinate system
var zero_point := Vector3.ZERO
var axis_length := 0

# Drawn vector
var origin := Vector3.ZERO
var dir := Vector3.ZERO
var is_velocity := true

# Vector drawing (data that is only important at drawing time)
var offset_fixed_coord := 0.0
var new_origin := Vector3.ZERO
var motion_start := Vector2.ZERO
var motion_end := Vector2.ZERO
var fixed_coord := "z"

# Selected object
var clicked := ""
var clicked_obj: Spatial
var is_selected := false

# Planet moving
var dragging_axis := Vector3.ZERO
var start_position := Vector3.ZERO

func _draw() -> void:
	if axis_length > 0:
		draw_axes()

	draw_vector(origin, origin + dir, Color(0, 1, 1), WIDTH)

# If part of the vector is behind the camera, then this function cuts the vector using binary search
func find_visible_start(start: Vector3, end: Vector3) -> Vector3:
	if (end - start).length() < 0.1:
		return end

	var middle := 0.5 * (start + end)
	if camera.is_position_behind(middle):
		return find_visible_start(middle, end)
	else:
		return find_visible_start(start, middle)

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
	var x_start := zero_point
	var x_end := zero_point
	var y_start := zero_point
	var y_end := zero_point
	var z_start := zero_point
	var z_end := zero_point
	x_start.x = (end.x if fixed_coord != "x" else zero_point.x + offset_fixed_coord) - 0.1
	x_end.x   = (end.x if fixed_coord != "x" else zero_point.x + offset_fixed_coord) + 0.1
	y_start.y = (end.y if fixed_coord != "y" else zero_point.y + offset_fixed_coord) - 0.1
	y_end.y   = (end.y if fixed_coord != "y" else zero_point.y + offset_fixed_coord) + 0.1
	z_start.z = (end.z if fixed_coord != "z" else zero_point.z + offset_fixed_coord) - 0.1
	z_end.z   = (end.z if fixed_coord != "z" else zero_point.z + offset_fixed_coord) + 0.1
	draw_vector(x_start, x_end, Color(1, 0.7, 0.7), WIDTH, true)
	draw_vector(y_start, y_end, Color(0.7, 1, 0.7), WIDTH, true)
	draw_vector(z_start, z_end, Color(0.7, 0.7, 1), WIDTH, true)

func _process(delta: float) -> void:
	update()

	if Input.is_action_just_pressed("switch_to_plane_yz"):
		fixed_coord = "x"
	elif Input.is_action_just_pressed("switch_to_plane_xz"):
		fixed_coord = "y"
	elif Input.is_action_just_pressed("switch_to_plane_xy"):
		fixed_coord = "z"
	elif Input.is_mouse_button_pressed(BUTTON_LEFT):
		if Input.is_action_pressed("decrease_fixed_coord_when_dragging_vector"):
			offset_fixed_coord -= delta
			set_vector()
		elif Input.is_action_pressed("increase_fixed_coord_when_dragging_vector"):
			offset_fixed_coord += delta
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
	var target_fixed_coord := origin_world[fixed_coord] + offset_fixed_coord
	# k is calculated so that end_world.z=target_z (or x/y instead of z)
	var k := (target_fixed_coord - end_world_ray_origin[fixed_coord]) / end_world_ray_normal[fixed_coord]
	var end_world := end_world_ray_origin + abs(k) * end_world_ray_normal
	var dir_world := end_world - origin_world
	return dir_world

func show_vector() -> void:
	origin = clicked_obj.transform.origin
	var vec: Array = editor.obj.velocity if is_velocity else editor.obj.orientation
	dir = Vector3(vec[0], vec[1], vec[2]) / (1e4 if is_velocity else 1.0)

func arr_to_vec(arr: Array) -> Vector3:
	return Vector3(arr[0], arr[1], arr[2])

func vec_to_arr(vec: Vector3) -> Array:
	return [vec.x, vec.y, vec.z]

func set_vector(finally := false) -> void:
	if motion_end == Vector2.ZERO:
		origin = Vector3.ZERO
		dir = Vector3.ZERO
	else:
		origin = new_origin
		var new_dir_screen := motion_end - motion_start
		dir = calc_dir(origin, new_dir_screen)
	if finally && is_velocity && dir != Vector3.ZERO:
		editor.obj.velocity = vec_to_arr(1e4 * dir)
	elif finally && dir != Vector3.ZERO:
		editor.obj.orientation = vec_to_arr(dir)

func drag_planet() -> void:
	var obj: Dictionary = editor.obj
	if dragging_axis == Vector3.ZERO || obj.has("not_found"):
		return

	var zero := zero_point
	var axis_end := zero_point + dragging_axis
	var axis := axis_end - zero
	var move := dir.project(axis)
	var new_pos := start_position + move
	clicked_obj.transform.origin = new_pos
	zero_point = new_pos
	full_editor.get_node("Params/Position").set_text(new_pos * 1e7)
	editor.obj.position = [new_pos.x * 1e7, new_pos.y * 1e7, new_pos.z * 1e7]

func calc_distance_to_axis(pos: Vector2, axis: Vector3) -> float:
	var axis_end := camera.unproject_position(zero_point + axis_length * axis)
	var distance := (axis_end - pos).length()
	return distance

func set_dragging_axis(pos: Vector2) -> void:
	var threshold := 10
	var x_distance := calc_distance_to_axis(pos, Vector3.RIGHT)
	var y_distance := calc_distance_to_axis(pos, Vector3.UP)
	var z_distance := calc_distance_to_axis(pos, Vector3.BACK)
	if x_distance < threshold && y_distance > x_distance && z_distance > x_distance:
		dragging_axis = Vector3.RIGHT
		fixed_coord = "z"
	elif y_distance < threshold && z_distance > y_distance:
		dragging_axis = Vector3.UP
		fixed_coord = "z"
	elif z_distance < threshold:
		dragging_axis = Vector3.BACK
		fixed_coord = "x"
	else:
		if dragging_axis != Vector3.ZERO:
			fixed_coord = "z"
		dragging_axis = Vector3.ZERO

func clear() -> void:
	zero_point = Vector3.ZERO
	axis_length = 0
	origin = Vector3.ZERO
	dir = Vector3.ZERO
	offset_fixed_coord = 0.0
	new_origin = Vector3.ZERO
	fixed_coord = "z"
	clicked = ""
	clicked_obj = null

func _input(event: InputEvent) -> void:
	if editor.gui_input:
		return

	if event is InputEventMouseButton && event.get_button_index() == BUTTON_LEFT:
		# Left mouse button pressed
		if event.is_pressed():
			var pos: Vector2 = event.get_position()
			set_dragging_axis(pos)
			if dragging_axis == Vector3.ZERO || !clicked:
				var collision := calc_collision(event)
				is_selected = ("name" in collision)
				if is_selected:
					clicked = collision.name
					clicked_obj = collision.object
					new_origin = clicked_obj.transform.origin
			motion_start = pos
			offset_fixed_coord = 0.0 if clicked else offset_fixed_coord
			start_position = clicked_obj.transform.origin if clicked else Vector3.ZERO
		# Left mouse button released & a planet is selected
		elif clicked:
			set_vector(true)
			drag_planet()

			if is_selected:
				editor.load_object(clicked)
				zero_point = clicked_obj.transform.origin
				var obj: Dictionary = editor.obj
				axis_length = int(max(1, round(obj.scale[0] * 2)))
				show_vector()
			else:
				editor.unload_object()
			camera.enable()
		# Left mouse button released & a planet was moved
		elif dragging_axis != Vector3.ZERO:
			drag_planet()
		# Left mouse button released & no planet is selected
		else:
			editor.unload_object()
		motion_end = Vector2.ZERO
	elif event is InputEventMouseMotion && event.get_button_mask() == BUTTON_LEFT && is_selected:
		camera.disable()
		motion_end = event.get_position()
		set_vector()
		drag_planet()

func toggle_param():
	is_velocity = !is_velocity
	var param_name := "orientation" if is_velocity else "velocity"
	draw_button.set_text("Draw " + param_name)
	show_vector()
