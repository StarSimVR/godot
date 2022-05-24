extends Node
const model_dir := "geometry/solarSystem/glTF2/"
const params := ["speed", "radius", "eccentricity", "centre", "normal", "tangent"]
const scripts := {
	"gdmath": preload("res://gdmath.gdns"),
	"rotate": preload("res://scenes/rotate.gd"),
	"planet": preload("res://Planet/Planet.gd")
}

func save(scene_name) -> void:
	var data := encode()
	var file := File.new()
	var _err := file.open("res://encoded_scenes/" + scene_name + ".json", File.WRITE)
	file.store_string(data)
	file.close()

func encode() -> String:
	var data := {"config": {"model_dir": model_dir, "params": params}, "lights": [],
				"geometries": [], "planet_data": [], "objects": []}
	var space := get_node("/root/Main/Objects/Space")

	var geometries := {}
	var planet_data := {}
	for object in space.get_children():
		add_object(object, data, geometries, planet_data)

	for geometry_name in geometries:
		data.geometries.push_back(geometries[geometry_name])

	for planet_data_name in planet_data:
		data.planet_data.push_back(planet_data[planet_data_name])

	return JSON.print(data, "\t")

func add_object(object: Spatial, data: Dictionary, geometries: Dictionary, planet_data: Dictionary, child_of := "") -> void:
	if object is ImmediateGeometry || object is Area || object.name == "Stars":
		return

	var path = get_mesh_path(object)
	var geometry_name = path.split(".")[0]
	if geometry_name && !geometries.has(geometry_name):
		geometries[geometry_name] = {"name": geometry_name, "type": "mesh", "path": path}

	var object_info = {"name": object.name}

	var script: Script = object.get_script()
	if script == scripts.gdmath:
		object_info.with_script = true

	var is_glb := object is Spatial && object.get_child_count() > 0 && object.get_child(0) is MeshInstance
	var generated: bool = object.get_child_count() > 0 && object.get_child(0).get_script() == scripts.planet

	if script == scripts.planet:
		object_info.with_script = "planet"
	var mesh: Spatial = object.get_child(0) if is_glb || generated else null
	if mesh && "planet_data" in mesh:
		var pd_name: String = mesh.planet_data.name
		planet_data[pd_name] = get_planet_data(mesh.planet_data)
		object_info.geometry = "planet"
		object_info.planet_data = pd_name

	if geometry_name:
		object_info.geometry = geometry_name
	if child_of:
		object_info.child_of = child_of
	var scale: Vector3 = mesh.get_scale() if is_glb else object.get_scale()
	if scale != Vector3.ONE:
		object_info.scale = [scale.x, scale.y, scale.z]
	var position: Vector3 = object.transform.origin
	if position != Vector3.ZERO || object is DirectionalLight:
		object_info["direction" if object is DirectionalLight else "position"] = [position.x, position.y, position.z]
	if object is CollisionObject:
		object_info.is_collision_object = true
	for param in params:
		if param in object:
			var val = object[param]
			object_info[param] = [val.x, val.y, val.z] if val is Vector3 else val

	if object is Light:
		var color: Color = object.get_color()
		object_info.color = [color.r, color.g, color.b, color.a]
		if object is OmniLight:
			object_info.radius = object.get_param(Light.PARAM_RANGE)
			object_info.attenuation = object.get_param(Light.PARAM_ATTENUATION)
		data.lights.push_back(object_info)
	else:
		data.objects.push_back(object_info)

	if !(object is CollisionObject):
		for child in object.get_children():
			if (!is_glb || !(child is MeshInstance)) && (!generated || child.get_script() != scripts.planet):
				add_object(child, data, geometries, planet_data, object.name)

func get_mesh_path(object: Spatial) -> String:
	if object.get_child_count() < 1:
		return ""
	var mesh_instance := object.get_child(0)
	if !(mesh_instance is MeshInstance):
		return ""
	var path: String = mesh_instance.get_mesh().resource_path
	path = path.replace("res://", "")
	path = path.split("::")[0]
	path = path.replace(model_dir, "")
	return path

func get_planet_data(pd: PlanetData) -> Dictionary:
	var pd_info := {"name": pd.name, "radius": pd.radius, "resolution": pd.resolution}

	var pd_color := pd.planet_color
	var colors := []
	for color in pd_color.gradient.colors:
		colors.append_array([color.r, color.g, color.b, color.a])
	pd_info.planet_color = {
		"width": pd_color.width,
		"offsets": pd_color.gradient.offsets,
		"colors": colors
	}

	var pd_noise: Array = pd.planet_noise
	var pd_noise_info := []
	for curr_noise in pd_noise:
		var noise_map: OpenSimplexNoise = curr_noise.noise_map
		var curr_noise_info := {
			"amplitude": curr_noise.amplitude,
			"min_height": curr_noise.min_height,
			"use_first_layer_as_mask": curr_noise.use_first_layer_as_mask,
			"octaves": noise_map.octaves,
			"period": noise_map.period,
			"persistence": noise_map.persistence,
			"lacunarity": noise_map.lacunarity
		}
		pd_noise_info.push_back(curr_noise_info)
	pd_info.planet_noise = pd_noise_info
	return pd_info
