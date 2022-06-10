extends Node

const collision_object := preload("collision_object.tscn")
const gdmath := preload("res://gdmath.gdns")
const rotate := preload("res://scenes/rotate.gd")
const planet_scene := preload("res://Planet/Planet.tscn")
var is_editor := false

func load_scene(scene_name: String) -> Dictionary:
	var file := File.new()
	var _err := file.open("res://encoded_scenes/" + scene_name + ".json", File.READ)
	var content := file.get_as_text()
	file.close()
	var json_result := JSON.parse(content)
	if json_result.error:
		print("Error parsing JSON in " + scene_name)
		return {"error": true}
	var data: Dictionary = json_result.result
	return data

func create(scene_name: String) -> void:
	var data := load_scene(scene_name)
	if "error" in data:
		return

	if data.has("objects"):
		var textures := get_textures(data)
		var geometries := get_geometries(data)
		var materials := get_materials(data, textures)
		var planet_data := get_planet_data(data)
		var params: Array = data.config.params if "config" in data && "params" in data.config else []
		for object in data.objects:
			create_object(object, geometries, materials, planet_data, params)
	if data.has("lights"):
		for light in data.lights:
			create_light(light)


func get_textures(data: Dictionary) -> Dictionary:
	var texture_dir := "res://"
	if "config" in data && ("textureDir" in data.config || "texture_dir" in data.config):
		texture_dir += data.config.textureDir if "textureDir" in data.config else data.config.texture_dir
	var textures := {}
	if !data.has("textures"):
		return textures

	for texture in data.textures:
		if "name" in texture && "path" in texture:
			textures[texture.name] = load(texture_dir + texture.path)
			if ("loadLinear" in texture && texture.loadLinear) || ("load_linear" in texture && texture.load_linear):
				textures[texture.name].set_flags(Texture.FLAG_FILTER | Texture.FLAG_CONVERT_TO_LINEAR)

	return textures

func get_geometries(data: Dictionary) -> Dictionary:
	var model_dir := "res://"
	if "config" in data && ("modelDir" in data.config || "model_dir" in data.config):
		model_dir += data.config.modelDir if "modelDir" in data.config else data.config.model_dir
	var geometries := {"planet": planet_scene}
	if !data.has("geometries"):
		return geometries
	for geometry in data.geometries:
		if "name" in geometry && "path" in geometry && "type" in geometry && geometry.type == "mesh":
			if is_editor:
				var sphere := SphereMesh.new()
				geometries[geometry.name] = sphere
			else:
				geometries[geometry.name] = load(model_dir + geometry.path)
	return geometries

func get_materials(data: Dictionary, textures: Dictionary) -> Dictionary:
	var materials := {}
	if !data.has("materials"):
		return materials
	for m_info in data.materials:
		if !m_info.has("name"):
			continue
		var m_instance := SpatialMaterial.new()

		if "albedo" in m_info && len(m_info.albedo) == 3:
			m_instance.albedo_color = Color(m_info.albedo[0], m_info.albedo[1], m_info.albedo[2])
		elif "albedo" in m_info:
			m_instance.albedo_color = Color(m_info.albedo[0], m_info.albedo[1], m_info.albedo[2], m_info.albedo[3])
		if "roughness" in m_info:
			m_instance.roughness = m_info.roughness
		if "metallic" in m_info:
			m_instance.metallic = m_info.metallic
		if "albedo_map" in m_info:
			m_instance.albedo_texture = textures[m_info.albedo_map]
		if "albedoMap" in m_info:
			m_instance.albedo_texture = textures[m_info.albedoMap]
		if "normal_map" in m_info:
			m_instance.normal_texture = textures[m_info.normal_map]
		if "normalMap" in m_info:
			m_instance.normal_texture = textures[m_info.normalMap]
		if "emission_enabled" in m_info:
			m_instance.emission_enabled = m_info.emission_enabled
		if "emission_energy" in m_info:
			m_instance.emission_energy = m_info.emission_energy
		if "emission" in m_info:
			m_instance.emission = Color(m_info.emission[0], m_info.emission[1], m_info.emission[2])
		if "use_as_albedo" in m_info:
			m_instance.vertex_color_use_as_albedo = m_info.use_as_albedo

		materials[m_info.name] = m_instance
	return materials

func get_randomized(value, rng: RandomNumberGenerator):
	return value if typeof(value) != TYPE_ARRAY else rng.randf_range(value[0], value[1])

func get_randomized_vector3(value: Array, rng: RandomNumberGenerator) -> Vector3:
	return Vector3(
			get_randomized(value[0], rng),
			get_randomized(value[1], rng),
			get_randomized(value[2], rng)
		)

func get_planet_data(data: Dictionary) -> Dictionary:
	var planet_data := {}
	if !data.has("planet_data"):
		return planet_data
	for pd_info in data.planet_data:
		if !pd_info.has("name"):
			continue

		var rng := RandomNumberGenerator.new()
		if "seed" in pd_info:
			rng.seed = pd_info.seed
		else:
			rng.randomize()
		var count: int = pd_info.count if "count" in pd_info else 1
		planet_data[pd_info.name] = []

		for n in count:
			var pd_instance := PlanetData.new()
			for key in pd_info:
				if key == "planet_noise":
					var noise_infos: Array = pd_info[key] if typeof(pd_info[key]) == TYPE_ARRAY else [pd_info[key]]
					pd_instance[key] = []
					for noise_info in noise_infos:
						var planet_noise := PlanetNoise.new()
						var noise_map := OpenSimplexNoise.new()
						planet_noise.noise_map = noise_map
						noise_map.seed = rng.randi()
						for noise_key in noise_info:
							if noise_key in planet_noise:
								planet_noise[noise_key] = get_randomized(noise_info[noise_key], rng)
							elif noise_key in noise_map:
								noise_map[noise_key] = get_randomized(noise_info[noise_key], rng)
						pd_instance[key].push_back(planet_noise)
				elif key == "planet_color":
					var color_info: Dictionary = pd_info[key]
					var colors: PoolColorArray = []
					for i in len(color_info.colors):
						if i % 4 == 0:
							colors.append(Color(color_info.colors[i], color_info.colors[i + 1], color_info.colors[i + 2], color_info.colors[i + 3]))
					var planet_color := GradientTexture.new()
					var gradient := Gradient.new()
					gradient.set_offsets(PoolRealArray(color_info.offsets))
					gradient.set_colors(colors)
					planet_color.set_width(get_randomized(color_info.width, rng))
					planet_color.set_gradient(gradient)
					pd_instance[key] = planet_color
				elif !["name", "seed", "count"].has(key):
					pd_instance[key] = get_randomized(pd_info[key], rng)
				elif key == "name":
					pd_instance[key] = pd_info[key] + (str(n) if count > 1 else "")
			planet_data[pd_info.name].push_back(pd_instance)
	return planet_data

func create_object(object: Dictionary, geometries: Dictionary, materials: Dictionary, planet_data: Dictionary,
				   params: Array, number := 0, rng: RandomNumberGenerator = null) -> void:
	var space := get_node("/root/Main/Objects/Space")

	if rng == null:
		rng = RandomNumberGenerator.new()
		if "seed" in object:
			rng.seed = object.seed
		else:
			rng.randomize()

	var count: int = object.count if "count" in object else 1
	if count > 1 && number == 0:
		for i in count:
			create_object(object, geometries, materials, planet_data, params, i + 1, rng)
		return

	var geometry = geometries[object.geometry] if "geometry" in object else null
	var node: Node
	var mesh = null
	var colObject: CollisionObject

	if geometry is PackedScene:
		node = geometry.instance()
		mesh = node.get_child(0)
	elif geometry:
		node = MeshInstance.new()
		mesh = node
		node.set_mesh(geometry)
	else:
		node = Spatial.new()
		mesh = node

	if "with_script" in object && object.with_script && !is_editor:
		node.set_script(gdmath)

	if "is_collision_object" in object && object.is_collision_object:
		colObject = collision_object.instance()
		if "name" in object:
			colObject.name = object.name

		if "scale" in object:
			colObject.set_scale(Vector3(object.scale[0], object.scale[1], object.scale[2]))

		colObject.input_ray_pickable = true
		node.add_child(colObject)

	if "child_of" in object:
		space.find_node(object.child_of, true, false).add_child(node)
	else:
		if ("with_script" in object && object.with_script) || "centre" in object || "speed" in object || !object.has("geometry"):
			space.add_child(node)
		else:
			space.get_node("Stars").add_child(node)
	if "name" in object:
		node.name = object.name + str(number) if number > 0 else object.name
	if "scale" in object && mesh:
		mesh.set_scale( Vector3(object.scale[0], object.scale[1], object.scale[2]) )
	if "material" in object:
		mesh.set_surface_material(0, materials[object.material])
	if "planet_data" in object:
		var pd: Array = planet_data[object.planet_data]
		mesh.planet_data = pd[rng.randi_range(0, pd.size() - 1)]
	if "position" in object:
		node.transform.origin = get_randomized_vector3(object.position, rng)
	elif "centre" in object && "radius" in object && (!object.has("with_script") || !object.with_script):
		var centre := get_randomized_vector3(object.centre, rng)
		var radius: float = get_randomized(object.radius, rng)
		node.transform.origin = centre + radius * Vector3(
			cos(rng.randf_range(0, 2 * PI)),
			sin(rng.randf_range(0, 2 * PI)),
			0
		)
	if "speed" in object && (!object.has("with_script") || !object.with_script):
		node.set_script(rotate)
		node.is_editor = is_editor
		node.speed = object.speed

	for param in params:
		if param in node && param in object:
			var val = object[param]
			val = Vector3(val[0], val[1], val[2]) if val is Array else val
			node[param] = val

func create_light(light: Dictionary) -> void:
	var space := get_node("/root/Main/Objects/Space")
	var node: Light
	if "direction" in light:
		node = DirectionalLight.new()
	else:
		node = OmniLight.new()

	if "name" in light:
		node.name = light.name

	if "child_of" in light:
		space.get_node(light.child_of).add_child(node)
	else:
		space.add_child(node)

	if "enabled" in light && !light.enabled:
		node.visible = false

	if "radius" in light:
		node.set_param(Light.PARAM_RANGE, light.radius)

	if "color" in light && len(light.color) == 3:
		node.set_color(Color(light.color[0], light.color[1], light.color[2]))
	elif "color" in light:
		node.set_color(Color(light.color[0], light.color[1], light.color[2], light.color[3]))

	if "position" in light || "direction" in light:
		var pos: Array = light.position if "position" in light else light.direction
		node.transform.origin = Vector3(pos[0], pos[1], pos[2])

	if "ambient_factor" in light:
		node.set_param(Light.PARAM_ENERGY, light.ambient_factor)
	if "ambientFactor" in light:
		node.set_param(Light.PARAM_ENERGY, light.ambientFactor)

	if "attenuation" in light:
		node.set_param(Light.PARAM_ATTENUATION, light. attenuation)
