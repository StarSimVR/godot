extends Node

const DEFAULT_SCENE := "solar_system"
const DEFAULT_SEED := 1234
const SCALE_POSITION := 1e11
const SCALE_VELOCITY := 5e7
const SCALE_MASS := 6.72006e23
const DEFAULT_ASTEROID_PATH := "/root/Main/Objects/Space/MultiMeshObjects"
const STARS_SCENE := "res://encoded_scenes/stars.json"

const collision_object := preload("collision_object.tscn")
const gdmath := preload("res://gdmath.gdns")
const rotate := preload("res://scenes/rotate.gd")
const planet_scene := preload("res://Planet/Planet.tscn")
const planet_material := preload("res://Planet/PlanetMaterial.tres")

var is_editor := false
var opened_scene := DEFAULT_SCENE

func get_scene_path(scene_name: String) -> String:
	var dir = Directory.new()
	if scene_name == STARS_SCENE:
		return STARS_SCENE
	elif dir.dir_exists("./encoded_scenes/"):
		return "./encoded_scenes/" + scene_name + ".json"
	else:
		return "./scenes/" + scene_name + ".json"

func load_scene(scene_name: String) -> Dictionary:
	var file := File.new()
	var _err := file.open(get_scene_path(scene_name), File.READ)
	var content := file.get_as_text()
	file.close()
	var json_result := JSON.parse(content)
	if json_result.error:
		print("Error parsing JSON in " + scene_name)
		return {"error": true}
	var data: Dictionary = json_result.result
	return data

func get_all_data(data: Dictionary) -> Dictionary:
	var i := {}
	i.textures = get_textures(data)
	i.pd_count = get_pd_count(data)
	i.planet_data = get_planet_data(data)
	i.planet_count = get_planet_count(data, i.planet_data, i.pd_count)
	i.geometries = get_geometries(data, i.planet_data)
	i.materials = get_materials(data, i.textures)
	i.params = data.config.params if "config" in data && "params" in data.config else []
	return i

func create(scene_name: String) -> void:
	var data := load_scene(scene_name)
	if "error" in data:
		return

	if data.has("objects"):
		var i := get_all_data(data)

		#create MultiMesh if stars are loaded
		if "config" in data && "starFile" in data.config && data.config.starFile:
			var multiStar := get_node("/root/Main/Objects/Space/MultiMeshObjects/Star")
			multiStar.multimesh.instance_count = data.objects.size()
			var index = 0
			for star in data.objects:
				create_star(star, i.materials, index)
				index+=1
			multiStar.multimesh.visible_instance_count = -1
			return
		init_multimesh_asteroids(DEFAULT_ASTEROID_PATH, i.pd_count, i.planet_data, i.planet_count, i.geometries)

		for object in data.objects:
			create_object(object, i.geometries, i.materials, i.pd_count, i.params, i.planet_data, i.planet_count)
	if data.has("lights"):
		for light in data.lights:
			create_light(light)

func create_star(object: Dictionary, materials: Dictionary, index) -> void:
	var multiStar := get_node("/root/Main/Objects/Space/MultiMeshObjects/Star")
	#Set the position of the star
	var position = Transform()
	position = position.translated(Vector3(object.position[0], object.position[1], object.position[2]))
	multiStar.multimesh.set_instance_transform(index, position)

	#Set the material of the star
	#+++Currently not working+++
	multiStar.multimesh.set_instance_custom_data(index, materials[object.material].emission)

func init_multimesh_asteroids(path: String, pd_count: Dictionary, planet_data: Dictionary, planet_count:Dictionary,
								geometries:Dictionary):
	var asteroids = get_node(path)
	if asteroids == null:
		print("An invalid path has been entered")
		return
	for i in pd_count["asteroid"]:
		var index_name = "asteroid" + str(i)
		var multi = MultiMeshInstance.new()
		multi.name = index_name
		multi.multimesh = MultiMesh.new()
		multi.multimesh.visible_instance_count = 1
		multi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multi.multimesh.color_format = MultiMesh.COLOR_FLOAT
		multi.multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_FLOAT
		multi.multimesh.mesh = geometries[planet_data[index_name].name]
		multi.multimesh.instance_count = int(planet_count[index_name])
		set_planet_material(multi, planet_data[index_name])
		multi.set_script(rotate)
		multi.is_editor = is_editor
		asteroids.add_child(multi)

func set_planet_material(mesh: GeometryInstance, planet_data: PlanetData) -> void:
	mesh.material_override = planet_material
	mesh.material_override.set_shader_param("min_height", planet_data.min_height)
	mesh.material_override.set_shader_param("max_height", planet_data.max_height)
	mesh.material_override.set_shader_param("height_color", planet_data.planet_color)

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

func get_geometries(data: Dictionary, planet_data: Dictionary) -> Dictionary:
	var model_dir := "res://"
	if "config" in data && ("modelDir" in data.config || "model_dir" in data.config):
		model_dir += data.config.modelDir if "modelDir" in data.config else data.config.model_dir

	var geometries := {}
	for planet_name in planet_data:
		var planet_instance := planet_scene.instance()
		var planet_spatial := planet_instance.get_child(0)
		planet_spatial.set_planet_data(planet_data[planet_name])
		var planet_mesh: ArrayMesh = planet_spatial.get_child(0).get_mesh()
		geometries[planet_name] = planet_mesh
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
		if "albedo_map" in m_info:
			m_instance.albedo_texture = textures[m_info.albedo_map]
		if "albedoMap" in m_info:
			m_instance.albedo_texture = textures[m_info.albedoMap]
		if "normal_map" in m_info:
			m_instance.normal_texture = textures[m_info.normal_map]
		if "normalMap" in m_info:
			m_instance.normal_texture = textures[m_info.normalMap]
		if "use_as_albedo" in m_info:
			m_instance.vertex_color_use_as_albedo = m_info.use_as_albedo
		if "flags_unshaded" in m_info:
			m_instance.flags_unshaded = m_info.flags_unshaded
		if "emission_enabled" in m_info:
			m_instance.emission_enabled = m_info.emission_enabled
		if "emission_energy" in m_info:
			m_instance.emission_energy = m_info.emission_energy
		if "emission" in m_info:
			m_instance.emission = Color(m_info.emission[0], m_info.emission[1], m_info.emission[2])
		if "emission_operator" in m_info:
			match str(m_info.emission_operator):
				"0":
					m_instance.emission_operator = SpatialMaterial.EMISSION_OP_ADD
				"1":
					m_instance.emission_operator = SpatialMaterial.EMISSION_OP_MULTIPLY
				_:
					print("Unknown emission operator " + str(m_info.emission_operator))
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

func get_pd_count(data: Dictionary) -> Dictionary:
	var pd_count := {}
	if !data.has("planet_data"):
		return pd_count
	for pd_info in data.planet_data:
		if !pd_info.has("name"):
			continue

		var count: int = pd_info.count if "count" in pd_info else 1
		pd_count[pd_info.name] = count
	return pd_count

func get_planet_count(data: Dictionary, planet_data: Dictionary, pd_count: Dictionary) -> Dictionary:
	var planet_count := {}
	if !data.has("planet_data"):
		return planet_count
	for planet_name in planet_data:
		planet_count[planet_name] = 0
	for object in data.objects:
		if !object.has("planet_data"):
			continue
		var rng := RandomNumberGenerator.new()
		rng.seed = object.seed if "seed" in object else DEFAULT_SEED
		var count: int = object.count if "count" in object else 1
		var planet_name: String = object.planet_data
		var max_num: int = pd_count[planet_name] - 1
		for i in count:
			var pd_name := planet_name + str(rng.randi_range(0, max_num))
			planet_count[pd_name] += 1

	return planet_count

func get_planet_data(data: Dictionary) -> Dictionary:
	var planet_data := {}
	if !data.has("planet_data"):
		return planet_data
	for pd_info in data.planet_data:
		if !pd_info.has("name"):
			continue

		var rng := RandomNumberGenerator.new()
		rng.seed = pd_info.seed if "seed" in pd_info else DEFAULT_SEED
		var count: int = pd_info.count if "count" in pd_info else 1

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
					pd_instance[key] = pd_info[key] + str(n)
			planet_data[pd_instance.name] = pd_instance
	return planet_data

func create_object(object: Dictionary, geometries: Dictionary, materials: Dictionary, pd_count: Dictionary,
				   params: Array, planet_data: Dictionary, planet_count: Dictionary,
					number := 0, rng: RandomNumberGenerator = null) -> void:
	var space := get_node("/root/Main/Objects/Space")
	var math_objects := get_node("/root/Main/Objects/Space/MathObjects")

	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = object.seed if "seed" in object else DEFAULT_SEED

	var count: int = object.count if "count" in object else 1
	if count > 1 && number == 0:
		var path = ""
		if  "child_of" in object:
			path = math_objects.find_node(object.child_of, true, false).get_path()
		if get_node(path) == null:
			path = DEFAULT_ASTEROID_PATH
		if !has_multimesh(path):
			init_multimesh_asteroids(path, pd_count, planet_data, planet_count, geometries)
		for i in count:
			create_auto_generated(path, object, pd_count, rng)
			#create_object(object, geometries, materials, pd_count, params, i + 1, rng)
		return

	var geometry = geometries[object.geometry] if "geometry" in object else null
	var pd_name: String
	var node: Spatial
	var mesh = null
	var colObject: CollisionObject

	if "planet_data" in object:
		pd_name = object.planet_data + str(rng.randi_range(0, pd_count[object.planet_data] - 1))
		geometry = geometries[pd_name]
	if geometry is PackedScene:
		node = geometry.instance()
		mesh = node.get_child(0)
	elif geometry:
		node = Spatial.new()
		mesh = MeshInstance.new()
		mesh.set_mesh(geometry)
		node.add_child(mesh)
		if "planet_data" in object:
			set_planet_material(mesh, planet_data[pd_name])
	else:
		node = Spatial.new()
		mesh = node

	if object.name != "sun":
		var label := Label3D.new()
		label.name = "Label"
		label.text = object.name
		label.pixel_size = 0.001
		label.render_priority = 1
		label.billboard = SpatialMaterial.BILLBOARD_ENABLED
		label.fixed_size = true
		label.no_depth_test = true
		#label.transform.origin = Vector3(0, 0, 0.02)
		node.add_child(label)

	if "with_script" in object && object.with_script && !is_editor:
		node.set_script(gdmath)

	if "has_collision_object" in object && object.has_collision_object:
		colObject = collision_object.instance()
		colObject.name = "CollisionObject"

		if "scale" in object:
			var scaling = 1.0
			if object.scale[0] < 0.3:
				scaling = 1.0 / (6.0 * object.scale[0])
			colObject.set_scale(Vector3(object.scale[0] * scaling, object.scale[1] * scaling, object.scale[2] * scaling))

		colObject.input_ray_pickable = true
		node.add_child(colObject)

	if "child_of" in object:
		math_objects.find_node(object.child_of, true, false).add_child(node)
	else:
		if ("with_script" in object && object.with_script) || "centre" in object || "speed" in object || !object.has("geometry"):
			math_objects.add_child(node)
		else:
			space.get_node("Stars").add_child(node)
	if "name" in object:
		node.name = object.name + str(number) if number > 0 else object.name
	if "scale" in object && mesh:
		mesh.set_scale( Vector3(object.scale[0], object.scale[1], object.scale[2]) )
	if "material" in object:
		mesh.set_surface_material(0, materials[object.material])
	if "position" in object:
		node.transform.origin = get_randomized_vector3(object.position, rng) / SCALE_POSITION
	if "speed" in object && (!object.has("with_script") || !object.with_script):
		node.set_script(rotate)
		node.is_editor = is_editor
		node.speed = object.speed

	for param in params:
		if param in node && param in object:
			var val = object[param]
			val = Vector3(val[0], val[1], val[2]) if val is Array else val
			node[param] = val

func create_single_object(object: Dictionary, data: Dictionary) -> void:
	var i := get_all_data(data)
	create_object(object, i.geometries, i.materials, i.pd_count, i.params, i.planet_data, i.planet_count)

func create_auto_generated(path: String, object: Dictionary, pd_count: Dictionary, rng: RandomNumberGenerator = null):
	var asteroids := get_node(path)
	var pd_name: String = object.planet_data + str(rng.randi_range(0, pd_count[object.planet_data] - 1))
	for i in asteroids.get_child_count():
		var cur_child = asteroids.get_child(i)
		if cur_child.name == pd_name:
			if cur_child.multimesh.visible_instance_count > cur_child.multimesh.instance_count:
				continue
			var position = Transform()
			position = position.translated(calculate_asteroid_position(object))
			cur_child.multimesh.set_instance_transform(cur_child.multimesh.visible_instance_count - 1, position)
			cur_child.multimesh.visible_instance_count += 1
			break


func has_multimesh(path: String):
	var node = get_node(path)
	var children = node.get_children()
	for child in children:
		if child.get_class() == "MultiMeshInstance":
			return true

	return false

func calculate_asteroid_position(object: Dictionary):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var centre := get_randomized_vector3(object.centre, rng)
	var axis := -1
	for i in 3:
		if typeof(object.centre[i]) == TYPE_ARRAY:
			axis = i
	var min_radius: float = object.radius if typeof(object.radius) != TYPE_ARRAY else object.radius[0]
	var max_radius: float = object.radius if typeof(object.radius) != TYPE_ARRAY else object.radius[1]
	var k: float
	if axis >= 0:
		var min_coord: float = object.centre[axis][0]
		var max_coord: float = object.centre[axis][1]
		var coord := centre[axis]
		var t := (coord - min_coord) / (max_coord - min_coord)
		k = 4 * (-pow(t, 2) + t)
	else:
		k = 1
	var radius = min_radius + k * rng.randf_range(0, max_radius - min_radius)
	var phi := float(rng.randf_range(0, 2 * PI))
	return centre + radius * Vector3(cos(phi), sin(phi), 0)


func create_light(light: Dictionary) -> void:
	var space := get_node("/root/Main/Objects/Space")
	var math_objects := get_node("/root/Main/Objects/Space/MathObjects")
	var node: Light
	if "direction" in light:
		node = DirectionalLight.new()
	else:
		node = OmniLight.new()

	if "name" in light:
		node.name = light.name

	if "child_of" in light:
		math_objects.get_node(light.child_of).add_child(node)
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
