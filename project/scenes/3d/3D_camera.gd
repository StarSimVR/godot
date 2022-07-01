extends BaseCamera

export var speed := 5.0
export var speed_with_shift := 25.0
export var look_sensitivity := 1.0
var _rotation := Vector2()
var _free_flight_mode := false

func _ready() -> void:
	start()

func start() -> void:
	SceneDecoder.create("solar_system")
	#SceneDecoder.create("stars")
	create_labels()
	create_trails()
	create_collision_objects()

func move_in_free_flight_mode(delta: float) -> void:
	var input := Vector3()
	if Input.is_action_pressed("move_forward"):
		input.z -= 1
	if Input.is_action_pressed("move_backward"):
		input.z += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	if Input.is_action_pressed("move_up"):
		input.y += 1
	if Input.is_action_pressed("move_down"):
		input.y -= 1
	input = input.normalized()

	transform.basis = Basis(Vector3(_rotation.y, _rotation.x, 0))
	var curr_speed := speed_with_shift if Input.is_key_pressed(KEY_SHIFT) else speed
	var velocity := delta * curr_speed * input
	translate(velocity)

func _process(delta: float) -> void:
	if _free_flight_mode:
		move_in_free_flight_mode(delta)
	else:
		look_at_current_object()

	if Input.is_action_just_pressed("print_position"):
		print("Position: ", transform.origin)
		print("Rotation: ", _rotation)
	if Input.is_action_just_pressed("toggle_free_flight_mode"):
		_free_flight_mode = !_free_flight_mode

	render_labels()

func zoom_in() -> void:
	fov = max(fov - 0.5, 1)

func zoom_out() -> void:
	fov = min(fov + 0.5, 179)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(BUTTON_LEFT):
		_rotation += event.relative * look_sensitivity * (-0.001)
		_rotation.x = fmod(_rotation.x, 2 * PI)
		_rotation.y = fmod(_rotation.y, 2 * PI)

	if Input.is_action_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_pressed("zoom_out"):
		zoom_out()

func look_at_current_object() -> void:
	var _objects := _space.get_children()
	if len(_objects) < 1:
		return
	var sun: Spatial = _objects[0]
	var object :Spatial = _space.get_cur_object()
	var origin := object.transform.origin
	var sun_origin := sun.transform.origin
	var position := origin + origin.normalized() * 1
	if position != sun_origin:
		look_at_from_position(position, sun_origin, Vector3(0, 0, 1))

func render_labels() -> void:
	for object in _space.get_children():
		if object.name == "sun":
			continue
		var label: Label = _labels.get_node(object.name)
		var object_position: Vector3 = object.global_transform.origin
		if is_position_behind(object_position):
			label.hide()
			continue

		var object_to_exclude: Node = object.get_node_or_null("CollisionObject")
		var exclude = [] if object_to_exclude == null else [object_to_exclude]
		var result := get_world().direct_space_state.intersect_ray(
			global_transform.origin, object_position, exclude, 2147483647, true, true
		)
		if result.empty():
			label.show()
			var offset := Vector2(label.get_size().x / 2, 0)
			label.rect_position = unproject_position(object_position) - offset
		else:
			label.hide()

func create_labels() -> void:
	for object in _space.get_children():
		if object.name == "sun":
			continue
		var label := Label.new()
		label.name = object.name
		label.set_text(object.name)
		_labels.add_child(label)

func create_trails() -> void:
	for object in _space.get_children():
		if object.name == "sun":
			continue
		var motion_trail = motion_trail_scene.instance()
		motion_trail.name = "MotionTrail"
		motion_trail.fromWidth = 0.05
		motion_trail.startColor = Color(0.52, 0.55, 0.72)
		motion_trail.rotate_y(PI / 2)
		object.add_child(motion_trail)

func create_collision_objects() -> void:
	for object in _space.get_children():
		if object.name == "Stars":
			continue
		var collision_object := collision_object_scene.instance()
		collision_object.name = "CollisionObject"
		collision_object.set_scale(object.get_child(0).get_scale())
		object.add_child(collision_object)
