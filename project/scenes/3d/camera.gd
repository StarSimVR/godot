extends Camera

export var speed := 5.0
export var speed_with_shift := 25.0
export var look_sensitivity := 1.0
onready var _objects := get_node("/root/Main/Objects/Space").get_children()
onready var _labels := get_node("/root/Main/Objects/CanvasLayer/Labels")
var _rotation := Vector2()
var _free_flight_mode := false
var _curr_object := 1

func _ready() -> void:
	for object in _objects:
		if object.name == "sun":
			continue
		var label := Label.new()
		label.name = object.name
		label.set_text(object.name)
		_labels.add_child(label)

func _process(delta: float) -> void:
	var input := Vector3()
	if !_free_flight_mode:
		var sun: Spatial = _objects[0]
		var object: Spatial = _objects[_curr_object]
		var origin := object.transform.origin
		var sun_origin := sun.transform.origin
		var position := origin + origin.normalized() * 1
		if position != sun_origin:
			look_at_from_position(position, sun_origin, Vector3(0, 0, 1))
	else:
		transform.basis = Basis(Vector3(_rotation.y, _rotation.x, 0))
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

	var curr_speed := speed_with_shift if Input.is_key_pressed(KEY_SHIFT) else speed
	var velocity := delta * curr_speed * input
	translate(velocity)

	if Input.is_action_just_pressed("print_position"):
		print("Position: ", transform.origin)
		print("Rotation: ", _rotation)
	if Input.is_action_just_pressed("toggle_free_flight_mode"):
		_free_flight_mode = !_free_flight_mode

	for object in _objects:
		if object.name == "sun":
			continue
		var label: Label = _labels.get_node(object.name)
		var offset := Vector2(label.get_size().x / 2, 0)
		var object_position: Vector3 = object.global_transform.origin
		if is_position_behind(object_position):
			label.hide()
		else:
			label.show()
		label.rect_position = unproject_position(object_position) - offset

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(BUTTON_LEFT):
		_rotation += event.relative * look_sensitivity * (-0.001)
		_rotation.x = fmod(_rotation.x, 2 * PI)
		_rotation.y = fmod(_rotation.y, 2 * PI)

	if Input.is_action_just_pressed("prev_warp_point"):
		_curr_object -= 1
		if _curr_object == 0:
			_curr_object = _objects.size() - 1
	if Input.is_action_just_pressed("next_warp_point"):
		_curr_object += 1
		if _curr_object == _objects.size():
			_curr_object = 1
