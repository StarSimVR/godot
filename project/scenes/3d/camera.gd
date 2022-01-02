extends Camera

export var speed := 5.0
export var look_sensitivity := 1.0
var _mouse_motion := Vector2()

func _process(delta: float) -> void:
	transform.basis = Basis(Vector3(_mouse_motion.y * -0.001, _mouse_motion.x * -0.001, 0))

	var input := Vector2()
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	input = input.normalized()

	var forward := global_transform.basis.z
	var right := global_transform.basis.x
	var direction := forward * input.y + right * input.x
	var velocity := delta * speed * direction
	translate(velocity)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(BUTTON_LEFT):
		_mouse_motion += event.relative * look_sensitivity
