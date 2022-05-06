extends Node
const model_dir := "geometry/solarSystem/glTF2/"
const params := ["speed", "radius", "eccentricity", "centre", "normal", "tangent"]

func save(scene_name) -> void:
	var data := encode()
	var file := File.new()
	var _err := file.open("res://encoded_scenes/" + scene_name + ".json", File.WRITE)
	file.store_string(data)
	file.close()

func encode() -> String:
	var data := {"config": {"model_dir": model_dir, "params": params}, "lights": [], "geometries": [], "objects": []}
	var space := get_node("/root/Main/Objects/Space")

	var geometries := {}
	for object in space.get_children():
		add_object(object, data, geometries)

	for geometry_name in geometries:
		data.geometries.push_back(geometries[geometry_name])

	return JSON.print(data, "\t")

func add_object(object: Spatial, data: Dictionary, geometries: Dictionary, child_of := "") -> void:
	if object is ImmediateGeometry || object is Area:
		return

	var path = get_mesh_path(object)
	var geometry_name = path.split(".")[0]
	if geometry_name && !geometries.has(geometry_name):
		geometries[geometry_name] = {"name": geometry_name, "type": "mesh", "path": path}

	var object_info = {"name": object.name}
	var is_glb = object is Spatial && object.get_child_count() > 0 && object.get_child(0) is MeshInstance

	if geometry_name:
		object_info.geometry = geometry_name
	if child_of:
		object_info.child_of = child_of
	var scale: Vector3 = object.get_child(0).get_scale() if is_glb else object.get_scale()
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
		data.lights.push_back(object_info)
	else:
		data.objects.push_back(object_info)

	if !(object is CollisionObject):
		for child in object.get_children():
			if !is_glb || !(child is MeshInstance):
				add_object(child, data, geometries, object.name)

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
