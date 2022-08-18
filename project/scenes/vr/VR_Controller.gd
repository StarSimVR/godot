extends ARVRController

const BUTTON = {
	"Trigger": 15,
	"TouchPad": 14,
	"SideButton": 2
}
#Load Nodes
onready var StarSimVRCamera := get_node("../StarSimVRCamera")
onready var _math_objects := get_node("/root/Main/Objects/Space/MathObjects")
onready var BaseController := get_node("../Controller")
onready var grabCast := get_node("GrabCast")

#Setup const
const CONTROLLER_DEADZONE = 0.65
const MOVEMENT_SPEED = 0.5
const ColorNotColliding = Color(0, 0, 1, 0.5)
const ColorColliding = Color(1, 0, 0, 0.5)

var isInited = false

#Controller Movement
var controller_velocity = Vector3(0, 0, 0)
var prior_controller_position = Vector3(0, 0, 0)
var prior_controller_velocities = []
var directional_movement = false

#Controller Functions
var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}
var grab_mode = "AREA"
var teleport_pos
var teleport_mesh
var teleport_button_down


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
	
	#Call the trackpad function
	_physics_process_directional_movement(delta)
	
	
#Function to track the trackpad, not finished	
func _physics_process_directional_movement(delta):
	# Convert the VR controller's trackpad axis values into a Vector2 and store it in a variable called trackpad_vector.
	var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
	# If the trackpad_vector's length is less than CONTROLLER_DEADZONE, then just ignore the input entirely.
	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		trackpad_vector = Vector2(0,0)
	# If the trackpad_vector's length is not less than CONTROLLER_DEADZONE, then process the input
	# while accounting for the deadzones within the controller.
	else:
		# (See the link at CONTROLLER_DEADZONE for an explanation of how this code works!)
		trackpad_vector = trackpad_vector.normalized() * ((trackpad_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))
	
	var movement_vector = trackpad_vector.normalized()
	
	var forward_direction = get_parent().get_node("StarSimVRCamera").global_transform.basis.z.normalized()
	var right_direction = get_parent().get_node("StarSimVRCamera").global_transform.basis.x.normalized()
	
	# Calculate the amount of movement the player will take on the Z (forward) axis and assign it to movement_forward.
	var movement_forward = forward_direction * movement_vector.x * delta * MOVEMENT_SPEED
	# Calculate the amount of movement the player will take on the X (right) axis and assign it to movement_forward.
	var movement_right = right_direction * movement_vector.y * delta * MOVEMENT_SPEED
	
	#+++Not finished, further adjustments when functionality is needed+++
	
#Function to init the scene upon the first load
func init():
	if(self.name == "RightController"):
		grabCast.visible = true
		grabCast.collide_with_areas = true
		grabCast.collide_with_bodies = false
		grabCast.set_enabled(true)
		grabCast.cast_to = Vector3(0, 0, -100)
	else:
		grabCast.visible = false
	
	update_camera_position_on_warp()
	isInited = true;

#Function to handle any physical input
func _process(_delta):
	if not isInited:
		 init()
	else:
		var leftController = get_node("../LeftController")
		var rightController = get_node("../RightController")
		var rightRayCast = rightController.getRayCast()
		#If the raycast is hitting and object, notify the user by rumbling the controller
		if(rightRayCast.is_colliding()):
			leftController.rumble = 0.3
			get_node("../RightController/GrabCast/Mesh").get_mesh().surface_get_material(0).emission = ColorColliding
		else:
			leftController.rumble = 0
			get_node("../RightController/GrabCast/Mesh").get_mesh().surface_get_material(0).emission = ColorNotColliding
			


#Function to specify the behaviour once a button is pressed
func button_pressed(button_index):
	match button_index:
		BUTTON.Trigger:
			match self.name:
				"LeftController":
					change_to_god_view()
				"RightController":
					teleport()
				_:
					print("Trigger__ControllerID: %d" % self.controller_id)
		BUTTON.TouchPad:
			match self.name:
				"LeftController": 
					change_warp_point_backwards()
				"RightController":
					change_warp_point_forwards()
				_:
					print("TouchPad__ControllerID: %d" % self.controller_id)
		BUTTON.SideButton:
			match self.name:
				"LeftController":
					BaseController.slower()
				"RightController":
					BaseController.faster()
				_:
					print("SideButton__ControllerID: %d" % self.controller_id)
		_:
			print("Did not match. pressed: %d" % button_index)


#Not yet implemented, will be relevant in the editing stage
func button_released(button_index):
	#print("Released: %d" % button_index)
	pass
	
	
#Function to call upon the BaseController warp point backwards functionality and update the camera
func change_warp_point_backwards():
	BaseController.prev_warp_point()
	update_camera_position_on_warp()
	
#Function to call upon the BaseController warp point forwards functionality and update the camera	
func change_warp_point_forwards():
	BaseController.next_warp_point()
	update_camera_position_on_warp()
	
	
	#Function to specify how to update and redisplay a scene in VR upon a warp point change
func update_camera_position_on_warp():
	var object: Spatial = _math_objects.get_cur_object()
	if(object == null): return
	var origin := object.transform.origin
	var camera_offset = get_parent().get_node("StarSimVRCamera").global_transform.origin - get_parent().global_transform.origin
	camera_offset.y = 0
	get_parent().global_transform.origin = origin - camera_offset
		
		
#Function to specify how to update and redisplay a scene in VR upon a teleport
func update_camera_position_on_teleport():
	var object: Spatial = _math_objects.get_cur_object()
	if(object == null): return
	var object_origin := object.transform.origin
	var camera_direction = get_parent().global_transform.origin - object_origin
	#camera_direction.y = 0
	get_parent().global_transform.origin = object_origin + 2 * camera_direction.normalized()
		

#Function to specify what happens when a teleport interaction is triggered
func teleport():
	var rightRayCast = get_node("../RightController").getRayCast()
	rightRayCast.force_raycast_update()
	#when a collision is detected, teleport the user to the location
	if(rightRayCast.is_colliding()):
		var body = rightRayCast.get_collider()
		_math_objects.set_cur_object(body)
		update_camera_position_on_teleport()

func sleep_area_entered(body):
	pass

func sleep_area_exited(body):
	pass
	
#Function to move the user to and entity outside of the scene, called the godView
func change_to_god_view():
	var object: Spatial = get_node("../../Objects/GodView")
	var origin := object.transform.origin
	var camera_offset = get_parent().get_node("StarSimVRCamera").global_transform.origin - get_parent().global_transform.origin
	camera_offset.y = 0
	get_parent().global_transform.origin = origin - camera_offset
	
func getRayCast():
	return grabCast
