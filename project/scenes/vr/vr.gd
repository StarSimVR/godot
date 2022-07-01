extends Spatial

func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false

		OS.vsync_enabled = false
		Engine.target_fps = 90
		# Also, the physics FPS in the project settings is also 90 FPS. This makes the physics
		# run at the same frame rate as the display, which makes things look smoother in VR!
	SceneDecoder.create("stars")
	SceneDecoder.create("solar_system")
	
func _process(delta):
	var node := get_node("/root/Main/Objects/Space/saturn/ringsOfSaturn")
	if node == null:
		return
	node._process(delta)
