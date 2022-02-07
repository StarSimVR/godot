class_name BaseCamera
extends Camera

onready var _objects := get_node("/root/Main/Objects/Space").get_children()
onready var _labels := get_node("/root/Main/Objects/CanvasLayer/Labels")
var _curr_object := 1

func create_labels() -> void:
	for object in _objects:
		if object.name == "sun":
			continue
		var label := Label.new()
		label.name = object.name
		label.set_text(object.name)
		_labels.add_child(label)

func render_labels() -> void:
	for object in _objects:
		if object.name == "sun":
			continue
		var label: Label = _labels.get_node(object.name)
		var object_position: Vector3 = object.global_transform.origin
		if is_position_behind(object_position):
			label.hide()
			continue

		var object_to_exclude: Node = object.get_node_or_null("CollisionObject")
		var exclude = [] if object_to_exclude == null else [object_to_exclude]
		var result := get_world().direct_space_state.intersect_ray(
			global_transform.origin, object_position, exclude, 2147483647, true, true
		)
		if result.empty():
			label.show()
			var offset := Vector2(label.get_size().x / 2, 0)
			label.rect_position = unproject_position(object_position) - offset
		else:
			label.hide()

func look_at_current_object() -> void:
	var sun: Spatial = _objects[0]
	var object: Spatial = _objects[_curr_object]
	var origin := object.transform.origin
	var sun_origin := sun.transform.origin
	var position := origin + origin.normalized() * 1
	if position != sun_origin:
		look_at_from_position(position, sun_origin, Vector3(0, 0, 1))

func prev_warp_point() -> void:
	_curr_object -= 1
	if _curr_object == 0:
		_curr_object = _objects.size() - 1

func next_warp_point() -> void:
	_curr_object += 1
	if _curr_object == _objects.size():
		_curr_object = 1
