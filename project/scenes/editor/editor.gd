extends Control

var saved_margin_bottom := self.margin_bottom
var scene: SceneEncoder = null
var obj := {"not_found": true}
var orig_mass := 0.0
var orig_radius := 0.0
var dragging := false

func _ready():
	scene = SceneEncoder.new("solar_system")
	init()

func _input(event: InputEvent) -> void:
	if !dragging && event is InputEventMouseButton && !event.is_pressed() && event.button_index == BUTTON_LEFT:
		var camera: Camera = get_node("/root/Main/3D/Camera")
		var from: Vector3 = camera.project_ray_origin(event.position)
		var to: Vector3 = from + camera.project_ray_normal(event.position) * 1000
		var result := camera.get_world().direct_space_state.intersect_ray(from, to, [], 2147483647, true, true)
		if result.empty():
			unload_object()
		else:
			load_object(result.collider.get_parent().name)

func _on_slider_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		dragging = event.is_pressed()
		if !dragging:
			update_params()

func init():
	get_node("/root/Main/HUD/Background").set_margin(MARGIN_BOTTOM, saved_margin_bottom + 40)

func update_params() -> void:
	if obj.has("not_found"):
		$Params/Mass.set_value(50)
		$Params/Radius.set_value(50)
		return

	var mass_change: int = $Params/Mass.get_value()
	var radius_change: int = $Params/Radius.get_value()
	if mass_change == 50 && radius_change == 50:
		return
	if $Locked.is_pressed():
		if mass_change == 50:
			mass_change = radius_change
		else:
			radius_change = mass_change

	calc_new_mass(mass_change)
	calc_new_radius(radius_change)
	orig_mass = get_mass()
	orig_radius = get_radius()
	$Params/Mass.set_value(50)
	$Params/Radius.set_value(50)
	save()

func save():
	var name: String = ""
	if "name" in obj:
		name = obj.name
	scene.save("solar_system")

	var space := get_node("/root/Main/Objects/Space")
	for planet in space.get_children():
		if planet.name != "Stars":
			planet.free()

	var camera := get_node("/root/Main/3D/Camera")
	camera.start()
	if name:
		load_object(name)

func get_mass() -> float:
	return obj.mass if "mass" in obj else 0.0

func get_radius() -> float:
	if !obj.has("scale") && !obj.has("radius"):
		return 0.0
	return obj.scale[0] if "with_script" in obj && obj.with_script else obj.radius

func set_mass(mass: float) -> void:
	obj.mass = mass

func set_radius(radius: float) -> void:
	if "with_script" in obj && obj.with_script:
		obj.scale = [radius, radius, radius]
	else:
		obj.radius = radius

func load_object(name: String) -> void:
	obj = scene.get_object(name)
	orig_mass = get_mass()
	orig_radius = get_radius()
	update_info()

func unload_object() -> void:
	obj = {"not_found": true}
	orig_mass = 0.0
	orig_radius = 0.0
	update_info()

func update_info() -> void:
	if "not_found" in obj:
		$Info.set_text("")
	else:
		var params := [obj.name, get_mass(), get_radius()]
		$Info.set_text("name=%s, mass=%.1f, radius=%.1f" % params)

func get_change_coeff(change: int) -> float:
	var pct := change - 50
	pct = pct if pct < 0 else pct * 2
	return 1 + pct / 100.0

func calc_new_mass(change: int) -> void:
	set_mass(orig_mass * get_change_coeff(change))

func calc_new_radius(change: int) -> void:
	set_radius(orig_radius * get_change_coeff(change))

func update_mass(change: int) -> void:
	calc_new_mass(change)
	if $Locked.is_pressed():
		calc_new_radius(change)
	update_info()

func update_radius(change: int) -> void:
	calc_new_radius(change)
	if $Locked.is_pressed():
		calc_new_mass(change)
	update_info()

func _on_gui_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		dragging = event.is_pressed()

func to_creator():
	var creator := get_node("../Creator")
	self.hide()
	creator.show()
	creator.init()

func delete():
	if "name" in obj:
		print(obj)
		scene.delete_object(obj.name, obj.parent if "parent" in obj else "")
		unload_object()
		save()
