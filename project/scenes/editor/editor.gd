extends Node

enum Mode {MASS_DENSITY, MASS_RADIUS}
var scene: SceneEncoder = null
var mode := 0
var obj := {}
var orig_radius := 0.0

func _ready():
	scene = SceneEncoder.new("solar_system")

func save():
	var name: String = $Name.get_text()
	var mass_radius := float($MassRadius.get_text())
	var density_radius := float($DensityRadius.get_text())
	var mass: float
	var radius: float
	var density: float
	if mode == Mode.MASS_DENSITY:
		mass = mass_radius
		radius = mass_radius
		density = density_radius
	elif mode == Mode.MASS_RADIUS:
		mass = mass_radius
		radius = density_radius
		density = mass / calc_volume(radius)

	set_radius(radius)
	scene.save("solar_system")

	var space := get_node("/root/Main/Objects/Space")
	for planet in space.get_children():
		if planet.name != "Stars":
			planet.free()

	var camera := get_node("/root/Main/3D/Camera")
	camera.start()

	load_object(name)

func calc_volume(radius: float):
	return (4.0 / 3) * PI * pow(radius, 3)

func get_radius() -> float:
	if !obj.has("scale") && !obj.has("radius"):
		return 0.0
	return obj.scale[0] if "with_script" in obj && obj.with_script else obj.radius

func get_mass() -> float:
	return 0.0

func get_density() -> float:
	return 0.0

func set_radius(radius: float) -> void:
	if "with_script" in obj && obj.with_script:
		obj.scale = [radius, radius, radius]
	else:
		obj.radius = radius

func load_object(name: String) -> void:
	obj = scene.get_object(name)
	var mass_radius: float
	var density_radius: float
	if mode == Mode.MASS_DENSITY:
		mass_radius = get_radius()
		density_radius = get_density()
	elif mode == Mode.MASS_RADIUS:
		mass_radius = get_mass()
		density_radius = get_radius()
	orig_radius = mass_radius
	#$Name.set_text(name)
	#$MassRadius.set_value(mass_radius)
	#$DensityRadius.set_value(density_radius)
	update_info()

func change_mode(new_mode: int):
	mode = new_mode
	if mode == Mode.MASS_DENSITY:
		$MassRadiusLabel.set_text("Mass/radius: ")
		$DensityRadiusLabel.set_text("Density: ")
	else:
		$MassRadiusLabel.set_text("Mass: ")
		$DensityRadiusLabel.set_text("Radius: ")

func update_info():
	if "not_found" in obj:
		$Info.set_text("Not found")
	else:
		var params := [get_mass(), get_radius(), get_density()]
		$Info.set_text("mass=%.1f, radius=%.1f, density=%.1f" % params)

func update_mass_radius(change: int):
	#if Input.is_mouse_button_pressed(BUTTON_LEFT):
		#return
	var radius := get_radius()
	var pct := change - 50
	pct = pct if pct < 0 else pct * 2
	radius = orig_radius + pct / 100.0 * orig_radius
	set_radius(radius)
	update_info()

func update_density_radius(value: int):
	pass # Replace with function body.
