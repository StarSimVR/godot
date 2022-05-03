extends ARVRController

const BUTTON = {
	"Trigger": 15,
	"TouchPad": 14,
	"SideButton": 2
}

onready var StarSimVRCamera := get_node("../StarSimVRCamera")
onready var Space := get_node("/root/Main/Objects/Space")
onready var BaseController := get_node("../Controller")
onready var grabCast := get_node("GrabCast")
var isInited = false


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
	
	
func init():
	if(self.controller_id == 2):
		grabCast.visible = true
		grabCast.collide_with_areas = true
		grabCast.collide_with_bodies = false
		grabCast.set_enabled(true)
		grabCast.cast_to = Vector3(0, 0, -100)
	else:
		grabCast.visible = false
	
	update_camera_position()
	isInited = true;

func _process(_delta):
	if not isInited:
		 init()
	else:
		var leftController = get_node("../LeftController")
		var rightController = get_node("../RightController")
		var rightRayCast = rightController.getRayCast()
		if(rightRayCast.is_colliding()):
			leftController.rumble = 0.3
		else:
			leftController.rumble = 0

func button_pressed(button_index):
	match button_index:
		BUTTON.Trigger:
			match self.controller_id:
				1:
					change_to_god_view()
				2:
					grab()
				_:
					print("Trigger__ControllerID: %d" % self.controller_id)
		BUTTON.TouchPad:
			match self.controller_id:
				1: 
					change_warp_point_backwards()
				2:
					change_warp_point_forwards()
				_:
					print("TouchPad__ControllerID: %d" % self.controller_id)
		BUTTON.SideButton:
			match self.controller_id:
				1:
					BaseController.slower()
				2:
					BaseController.faster()
				_:
					print("SideButton__ControllerID: %d" % self.controller_id)
		_:
			print("Did not match. pressed: %d" % button_index)

func button_released(button_index):
	#print("Released: %d" % button_index)
	pass
	
	
func change_warp_point_backwards():
	BaseController.prev_warp_point()
	update_camera_position()
	
func change_warp_point_forwards():
	BaseController.next_warp_point()
	update_camera_position()
		
func update_camera_position():
	var object: Spatial = Space.get_cur_object()
	if(object == null): return
	var origin := object.transform.origin
	var camera_offset = get_parent().get_node("StarSimVRCamera").global_transform.origin - get_parent().global_transform.origin
	camera_offset.y = 0
	get_parent().global_transform.origin = origin - camera_offset
	#StarSimVRCamera.updatePosition(origin)
		
func grab():
	var rightRayCast = get_node("../RightController").getRayCast()
	rightRayCast.force_raycast_update()
	if(rightRayCast.is_colliding()):
		var body = rightRayCast.get_collider()
		Space.set_cur_object(body)
		update_camera_position()

func sleep_area_entered(body):
	pass

func sleep_area_exited(body):
	pass
	
func change_to_god_view():
	var object: Spatial = get_node("../../Objects/GodView")
	var origin := object.transform.origin
	var camera_offset = get_parent().get_node("StarSimVRCamera").global_transform.origin - get_parent().global_transform.origin
	camera_offset.y = 0
	get_parent().global_transform.origin = origin - camera_offset
	
func getRayCast():
	return grabCast
