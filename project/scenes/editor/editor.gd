extends Control

onready var camera := get_node("/root/Main/3D/Camera")
onready var full_editor := get_node("../FullEditor")
onready var draw := get_node("/root/Main/HUD/Draw")

var saved_margin_bottom := self.margin_bottom
var scene: SceneEncoder = null
var obj := {"not_found": true}
var orig_mass := 0.0
var orig_scaling_factor := 0.0
var gui_input := false

func _ready() -> void:
	scene = SceneEncoder.new("solar_system")
	init()

func _on_slider_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		gui_input = event.is_pressed()
		if gui_input:
			camera.disable()
		else:
			camera.enable()
			update_params()

func init() -> void:
	get_node("/root/Main/HUD/Background").set_margin(MARGIN_BOTTOM, saved_margin_bottom + 70)

func not_saved() -> void:
	$Buttons/Save.set_disabled(false)

func saved() -> void:
	$Buttons/Save.set_disabled(true)

func update_params() -> void:
	if obj.has("not_found"):
		$Params/Mass.set_value(50)
		$Params/ScalingFactor.set_value(50)
		return

	var mass_change: int = $Params/Mass.get_value()
	var scaling_factor_change: int = $Params/ScalingFactor.get_value()
	if mass_change == 50 && scaling_factor_change == 50:
		return
	if $Locked.is_pressed():
		if mass_change == 50:
			mass_change = scaling_factor_change
		else:
			scaling_factor_change = mass_change

	calc_new_mass(mass_change)
	calc_new_scaling_factor(scaling_factor_change)
	orig_mass = get_mass()
	orig_scaling_factor = get_scaling_factor()
	$Params/Mass.set_value(50)
	$Params/ScalingFactor.set_value(50)

func save() -> void:
	var name: String = ""
	if "name" in obj:
		name = obj.name
	scene.save("solar_system")

	var space := get_node("/root/Main/Objects/Space/MathObjects")
	for planet in space.get_children():
			planet.free()

	camera.start()
	if name:
		load_object(name)
	saved()
	full_editor.saved()

func get_mass() -> float:
	return obj.mass if "mass" in obj else 0.0

func get_scaling_factor() -> float:
	if !obj.has("scale") && !obj.has("radius"):
		return 0.0
	return obj.scale[0] if "with_script" in obj && obj.with_script else obj.radius

func set_mass(mass: float) -> void:
	if "not_found" in obj:
		return

	obj.mass = mass
	not_saved()
	full_editor.not_saved()

func set_scaling_factor(scaling_factor: float) -> void:
	if "not_found" in obj:
		return

	if "with_script" in obj && obj.with_script:
		obj.scale = [scaling_factor, scaling_factor, scaling_factor]
	else:
		obj.radius = scaling_factor

	var new_scale := Vector3(scaling_factor, scaling_factor, scaling_factor)
	draw.clicked_obj.get_child(0).set_scale(new_scale)
	not_saved()
	full_editor.not_saved()

func load_object(name: String) -> void:
	obj = scene.get_object(name)
	orig_mass = get_mass()
	orig_scaling_factor = get_scaling_factor()
	update_info()

func unload_object() -> void:
	obj = {"not_found": true}
	orig_mass = 0.0
	orig_scaling_factor = 0.0
	update_info()
	draw.clear()

func update_info() -> void:
	if "not_found" in obj:
		$Info.clear()
		full_editor.clear()
	else:
		var params := [obj.name, get_mass(), get_scaling_factor()]
		$Info.set_bbcode("[b]%s:[/b] mass=%.1f, scaling factor=%.1f" % params)
		full_editor.load_object()

func get_change_coeff(change: int) -> float:
	var pct := change - 50
	pct = pct if pct < 0 else pct * 2
	return 1 + pct / 100.0

func calc_new_mass(change: int) -> void:
	set_mass(orig_mass * get_change_coeff(change))

func calc_new_scaling_factor(change: int) -> void:
	set_scaling_factor(orig_scaling_factor * get_change_coeff(change))

func update_mass(change: int) -> void:
	calc_new_mass(change)
	if $Locked.is_pressed():
		calc_new_scaling_factor(change)
	update_info()

func update_scaling_factor(change: int) -> void:
	calc_new_scaling_factor(change)
	if $Locked.is_pressed():
		calc_new_mass(change)
	update_info()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		gui_input = event.is_pressed()

func to_full_editor() -> void:
	self.hide()
	full_editor.show()
	full_editor.init()
	unload_object()

func delete_objects_with_parent(parent: String) -> void:
	var objects := scene.get_objects()
	for object in objects:
		if "parent" in object && object.parent == parent:
			if "with_script" in object && object.with_script:
				object.erase("parent")
			else:
				scene.delete_object(object.name, parent)
			delete_objects_with_parent(name)

	var lights := scene.get_lights()
	for light in lights:
		if "child_of" in light && light.child_of == parent:
			scene.delete_light(light.name)

func delete() -> void:
	var name: String = obj.name if "name" in obj else ""
	var parent: String = obj.parent if "parent" in obj else ""
	if name && yield($Confirm.ask("Are you sure to delete this object with all nested objects or their scripts?"), "completed"):
		scene.delete_object(name, parent)
		delete_objects_with_parent(name)
		unload_object()
	elif !name:
		$Alert.info("No object is selected for deletion.")
