extends Node
class_name SceneEncoder

var data: Dictionary = {}

func _init(scene_name: String) -> void:
	data = SceneDecoder.load_scene(scene_name)

func save(scene_name: String) -> void:
	var file := File.new()
	var _err := file.open("res://encoded_scenes/" + scene_name + ".json", File.WRITE)
	file.store_string(JSON.print(data, "\t"))
	file.close()

func check_parent(object: Dictionary, parent: String) -> bool:
	return object.has("child_of") && object.child_of == parent || !object.has("child_of") && !parent

func get_object(name: String, parent := "") -> Dictionary:
	if !data.has("objects"):
		return {"not_found": true}

	for object in data.objects:
		if check_parent(object, parent) && object.name == name:
			return object
	return {"not_found": true}

func get_objects() -> Array:
	return data.objects if "objects" in data else []

func get_lights() -> Array:
	return data.lights if "lights" in data else []

func get_all_planet_data() -> Array:
	return data.planet_data if "planet_data" in data else []

func get_entry(array_name: String, name: String) -> Dictionary:
	if !data.has(array_name):
		return {"not_found": true}

	for entry in data[array_name]:
		if "name" in entry && entry.name == name:
			return entry
	return {"not_found": true}

func get_light(name: String) -> Dictionary:
	return get_entry("lights", name)

func get_geometry(name: String) -> Dictionary:
	return get_entry("geometries", name)

func get_texture(name: String) -> Dictionary:
	return get_entry("textures", name)

func get_material(name: String) -> Dictionary:
	return get_entry("materials", name)

func get_planet_data(name: String) -> Dictionary:
	return get_entry("planet_data", name)

func set_object(new_object: Dictionary, name := "", parent := "") -> void:
	if !name:
		name = new_object.name
		parent = new_object.parent if "parent" in new_object else ""
	if !data.has("objects"):
		data.objects = []

	for i in data.objects.size():
		var object: Dictionary = data.objects[i]
		if check_parent(object, parent) && object.name == name:
			data.objects[i] = new_object
			return

	data.objects.append(new_object)

func set_entry(array_name: String, new_entry: Dictionary, name: String) -> void:
	if !name:
		name = new_entry.name
	if !data.has(array_name):
		data[array_name] = []

	for i in data[array_name].size():
		var entry: Dictionary = data[array_name][i]
		if "name" in entry && entry.name == name:
			data[array_name][i] = new_entry
			return

	data[array_name].push_back(new_entry)

func set_light(new_entry: Dictionary, name := "") -> void:
	set_entry("lights", new_entry, name)

func set_geometry(new_entry: Dictionary, name := "") -> void:
	set_entry("geometries", new_entry, name)

func set_texture(new_entry: Dictionary, name := "") -> void:
	set_entry("textures", new_entry, name)

func set_material(new_entry: Dictionary, name := "") -> void:
	set_entry("materials", new_entry, name)

func set_planet_data(new_entry: Dictionary, name := "") -> void:
	set_entry("planet_data", new_entry, name)

func delete_object(name: String, parent := "") -> void:
	if !data.has("objects"):
		return

	for object in data.objects:
		if check_parent(object, parent) && object.name == name:
			data.objects.erase(object)

func delete_entry(array_name: String, name: String) -> void:
	if !data.has(array_name):
		return

	for entry in data[array_name]:
		if "name" in entry && entry.name == name:
			data[array_name].erase(entry)

func delete_light(name: String) -> void:
	delete_entry("lights", name)

func delete_geometry(name: String) -> void:
	delete_entry("geometries", name)

func delete_texture(name: String) -> void:
	delete_entry("textures", name)

func delete_material(name: String) -> void:
	delete_entry("materials", name)

func delete_planet_data(name: String) -> void:
	delete_entry("planet_data", name)
