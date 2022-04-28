extends Node

var collision_object := preload("collision_object.tscn")
var gdmath := preload("res://gdmath.gdns")
var planet_scene := preload("res://Planet/Planet.tscn")

func create(scene_name: String) -> void:
	var file := File.new()
	var _err := file.open("res://encoded_scenes/" + scene_name + ".json", File.READ)
	var content := file.get_as_text()
	file.close()
	var json_result := JSON.parse(content)
	if json_result.error:
		print("Error parsing JSON in " + scene_name)
		return
	var data: Dictionary = json_result.result

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
	var texture_dir: String = data.config.textureDir if "config" in data && "textureDir" in data.config else ""
	texture_dir = "res://" + texture_dir
	var textures := {}
	if !data.has("textures"):
		return textures

	for texture in data.textures:
		if "name" in texture && "path" in texture:
			textures[texture.name] = load(texture_dir + texture.path)
			if "loadLinear" in texture && texture.loadLinear:
				textures[texture.name].set_flags(Texture.FLAG_FILTER | Texture.FLAG_CONVERT_TO_LINEAR)

	return textures

func get_geometries(data: Dictionary) -> Dictionary:
	var model_dir: String = data.config.modelDir if "config" in data && "modelDir" in data.config else ""
	model_dir = "res://" + model_dir
	var geometries := {"planet": planet_scene}
	if !data.has("geometries"):
		return geometries
	for geometry in data.geometries:
		if "name" in geometry && "path" in geometry && "type" in geometry && geometry.type == "mesh":
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
		if "albedoMap" in m_info:
			m_instance.albedo_texture = textures[m_info.albedoMap]
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

func get_planet_data(data: Dictionary) -> Dictionary:
	var planet_data := {}
	if !data.has("planet_data"):
		return planet_data
	for pd_info in data.planet_data:
		if !pd_info.has("name"):
			continue

		var pd_instance := PlanetData.new()
		for key in pd_info:
			if key == "planet_noise":
				var noise_infos: Array = pd_info[key] if typeof(pd_info[key]) == TYPE_ARRAY else [pd_info[key]]
				pd_instance[key] = []
				for noise_info in noise_infos:
					var planet_noise := PlanetNoise.new()
					var noise_map := OpenSimplexNoise.new()
					planet_noise.noise_map = noise_map
					for noise_key in noise_info:
						if noise_key in planet_noise:
							planet_noise[noise_key] = noise_info[noise_key]
						elif noise_key in noise_map:
							noise_map[noise_key] = noise_info[noise_key]
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
				planet_color.set_width(color_info.width)
				planet_color.set_gradient(gradient)
				pd_instance[key] = planet_color
			elif key != "name":
				pd_instance[key] = pd_info[key]
		planet_data[pd_info.name] = pd_instance
	return planet_data

func create_object(object: Dictionary, geometries: Dictionary, materials: Dictionary, planet_data: Dictionary, params: Array) -> void:
	var space := get_node("/root/Main/Objects/Space")
	var geometry = geometries[object.geometry] if "geometry" in object else null
	var node: Node
	var mesh = null
	var colObject: CollisionObject

	if geometry is PackedScene:
		node = geometry.instance()
		mesh = node.get_child(0)
	else:
		node = MeshInstance.new()
		mesh = node
		if geometry:
			node.set_mesh(geometry)

	if "withScript" in object && object.withScript:
			node.set_script(gdmath)

	if "isCollisionObject" in object && object.isCollisionObject:
		colObject = collision_object.instance()
		if "name" in object:
			colObject.name = object.name

		if "scale" in object:
			colObject.set_scale(Vector3(object.scale[0], object.scale[1], object.scale[2]))

		colObject.input_ray_pickable = true
		node.add_child(colObject)

	if "childOf" in object:
		space.get_node(object.childOf).add_child(node)
	else:
		if "withScript" in object && object.withScript:
			space.add_child(node)
		else:
			space.get_node("Stars").add_child(node)
	if "name" in object:
		node.name = object.name
	if "scale" in object && mesh:
		mesh.set_scale( Vector3(object.scale[0], object.scale[1], object.scale[2]) )
	if "material" in object:
		mesh.set_surface_material(0, materials[object.material])
	if "planet_data" in object:
		mesh.planet_data = planet_data[object.planet_data]
	if "position" in object:
		node.transform.origin = Vector3(object.position[0], object.position[1], object.position[2])

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

	if "childOf" in light:
		space.get_node(light.childOf).add_child(node)
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

	if "ambientFactor" in light:
		node.set_param(Light.PARAM_ENERGY, light.ambientFactor)

	if "attenuation" in light:
		node.set_param(Light.PARAM_ATTENUATION, light. attenuation)
