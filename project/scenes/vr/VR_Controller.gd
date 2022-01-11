extends ARVRController

#onready var grab_area = $Area
#onready var grab_raycast = $GrabCast
#onready var grab_pos_node = $Grab_Pos
#onready var hand_mesh = $Hand
#onready var teleport_raycast = $RayCast

var controller_velocity = Vector3(0, 0, 0)
var prior_controller_position = Vector3(0, 0, 0)
var prior_controller_velocities = []

var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}

var grab_mode = "AREA"
var teleport_pos
var teleport_mesh
var teleport_button_down

const CONTROLLER_DEADZONE = 0.65

const MOVEMENT_SPEED = 1.5

var directional_movement = false

func _ready():
	#teleport_mesh = get_tree().root.get_node("Game/Teleport_Mesh")
	teleport_button_down = false

	grab_mode = "AREA"
	#get_node("Sleep_Area").connect("body_entered", self, "sleep_area_entered")
	#get_node("Sleep_Area").connect("body_exited", self, "sleep_area_exited")

	connect("button_pressed", self, "button_pressed")
	connect("button_release", self, "button_released")


func _physics_process(delta):

	# Controller velocity
	# --------------------
	if get_is_active():
		controller_velocity = Vector3(0, 0, 0)

		if prior_controller_velocities.size() > 0:
			for vel in prior_controller_velocities:
				controller_velocity += vel

			# Get the average velocity, instead of just adding them together.
			controller_velocity = controller_velocity / prior_controller_velocities.size()

		prior_controller_velocities.append((global_transform.origin - prior_controller_position) / delta)

		controller_velocity += (global_transform.origin - prior_controller_position) / delta
		prior_controller_position = global_transform.origin

		if prior_controller_velocities.size() > 30:
			prior_controller_velocities.remove(0)

	# --------------------

	# Directional movement
	# --------------------
	# NOTE: you may need to change this depending on which VR controllers
	# you are using and which OS you are on.
	var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
	var joystick_vector = Vector2(-get_joystick_axis(5), get_joystick_axis(4))

	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		trackpad_vector = Vector2(0, 0)
	else:
		trackpad_vector = trackpad_vector.normalized() * ((trackpad_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	if joystick_vector.length() < CONTROLLER_DEADZONE:
		joystick_vector = Vector2(0, 0)
	else:
		joystick_vector = joystick_vector.normalized() * ((joystick_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	var forward_direction = get_parent().get_node("ARVRCamera").global_transform.basis.z.normalized()
	var right_direction = get_parent().get_node("ARVRCamera").global_transform.basis.x.normalized()

	var movement_vector = (trackpad_vector + joystick_vector).normalized()

	var movement_forward = forward_direction * movement_vector.x * delta * MOVEMENT_SPEED
	var movement_right = right_direction * movement_vector.y * delta * MOVEMENT_SPEED

	movement_forward.y = 0
	movement_right.y = 0

	if movement_right.length() > 0 or movement_forward.length() > 0:
		get_parent().translate(movement_right + movement_forward)
		directional_movement = true
	else:
		directional_movement = false
	# --------------------


func button_pressed(button_index):
	var string = "Pressed: %d"
	string = string % button_index
	print(string)

func button_released(button_index):
	var string = "Released: %d"
	string = string % button_index
	print(string)

func sleep_area_entered(body):
	pass

func sleep_area_exited(body):
	pass
