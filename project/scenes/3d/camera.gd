extends Camera

export var speed := 5.0
export var speed_with_shift := 25.0
export var look_sensitivity := 1.0
var _mouse_motion := Vector2()

func _process(delta: float) -> void:
	transform.basis = Basis(Vector3(_mouse_motion.y * -0.001, _mouse_motion.x * -0.001, 0))

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

	var curr_speed := speed_with_shift if Input.is_key_pressed(KEY_SHIFT) else speed
	var direction := global_transform.basis * input
	var velocity := delta * curr_speed * direction
	translate(velocity)

	if Input.is_action_just_pressed("print_position"):
		print("Translation:", transform.origin)
		print("Basis:", transform.basis)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(BUTTON_LEFT):
		_mouse_motion += event.relative * look_sensitivity
