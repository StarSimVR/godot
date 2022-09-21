extends BaseCamera

export var speed := 5.0
export var speed_with_shift := 25.0
export var look_sensitivity := 1.0
var _rotation := Vector2()
var _free_flight_mode := false
var _enabled := true

func _ready() -> void:
	start()

func start() -> void:
	SceneDecoder.create(SceneDecoder.STARS_SCENE)
	SceneDecoder.create(SceneDecoder.opened_scene)
	if !SceneDecoder.is_editor:
		create_trails()

func disable() -> void:
	_enabled = false

func enable() -> void:
	_enabled = true

func is_focused() -> bool:
	var gui: Control = get_node_or_null("/root/Main/HUD/GUI")
	if gui == null:
		return false
	var focus_owner := gui.get_focus_owner()
	return focus_owner != null && (focus_owner is LineEdit || focus_owner is TextEdit)

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
	if is_focused():
		return

	if _free_flight_mode || SceneDecoder.is_editor:
		move_in_free_flight_mode(delta)
	else:
		look_at_current_object()

	if Input.is_action_just_pressed("print_position"):
		print("Position: ", transform.origin)
		print("Rotation: ", _rotation)
	if Input.is_action_just_pressed("toggle_free_flight_mode"):
		_free_flight_mode = !_free_flight_mode

func zoom_in() -> void:
	fov = max(fov - 0.5, 1)

func zoom_out() -> void:
	fov = min(fov + 0.5, 179)

func _input(event: InputEvent) -> void:
	if _enabled && event is InputEventMouseMotion && Input.is_mouse_button_pressed(BUTTON_LEFT):
		_rotation += event.relative * look_sensitivity * (-0.001)
		_rotation.x = fmod(_rotation.x, 2 * PI)
		_rotation.y = fmod(_rotation.y, 2 * PI)

	if is_focused():
		return
	if Input.is_action_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_pressed("zoom_out"):
		zoom_out()

func look_at_current_object() -> void:
	var _objects := _math_objects.get_children()
	if len(_objects) < 1:
		return
	var sun: Spatial = _objects[0]
	var object :Spatial = _math_objects.get_cur_object()
	var origin := object.transform.origin
	var sun_origin := sun.transform.origin
	var position := origin + origin.normalized() * 1
	if position != sun_origin:
		look_at_from_position(position, sun_origin, Vector3(0, 0, 1))

func create_trails() -> void:
	for object in _math_objects.get_children():
		if object.name != "sun":
			create_trail(object)

func create_trail(object: Spatial) -> void:
	var motion_trail = motion_trail_scene.instance()
	motion_trail.name = "MotionTrail"
	motion_trail.fromWidth = 0.05
	motion_trail.startColor = Color(0.52, 0.55, 0.72)
	motion_trail.rotate_y(PI / 2)
	object.add_child(motion_trail)
