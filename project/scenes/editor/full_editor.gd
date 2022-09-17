extends VBoxContainer

onready var editor := get_node("../Editor")
onready var draw := get_node("/root/Main/HUD/Draw")
onready var camera: Camera = get_node("/root/Main/3D/Camera")

var saved_margin_bottom := self.margin_bottom
var is_loading := false

func _ready() -> void:
	for param in $Params.get_children():
		if !(param is Label):
			param.connect("text_changed", self, "_on_text_changed")

func init() -> void:
	get_node("/root/Main/HUD/Background").set_margin(MARGIN_BOTTOM, saved_margin_bottom + 40)

func not_saved() -> void:
	$Buttons/Save.set_disabled(false)

func saved() -> void:
	$Buttons/Save.set_disabled(true)

func _on_text_changed(_new_text: String) -> void:
	if !is_loading && !editor.obj.has("not_found"):
		set_params(editor.obj)
		not_saved()

func to_editor() -> void:
	self.hide()
	editor.show()
	editor.init()

func set_params(obj: Dictionary) -> void:
	var child_of: String = $Params/ChildOf.get_text()
	var geometry: String = $Params/Geometry.get_text()
	var planet_data: String = $Params/PlanetData.get_text()
	var scale := float($Params/Scale.get_text())

	obj.name = $Params/Name.get_text()
	if child_of:
		obj.child_of = child_of
	if geometry:
		obj.geometry = geometry
	if planet_data:
		obj.planet_data = planet_data
	obj.scale = [scale, scale, scale]
	obj.mass = float($Params/Mass.get_text()) / SceneDecoder.SCALE_MASS
	obj.rotationSpeed = int($Params/RotationSpeed.get_text())
	obj.position = $Params/Position.get_array()
	obj.velocity = $Params/Velocity.get_array()
	obj.orientation = $Params/Orientation.get_array()
	var new_scale := Vector3(scale, scale, scale)
	if !editor.obj.has("not_found"):
		draw.clicked_obj.get_child(0).set_scale(new_scale)
		draw.clicked_obj.transform.origin = $Params/Position.get_vector() / SceneDecoder.SCALE_POSITION

func clear() -> void:
	is_loading = true
	for param in $Params.get_children():
		if !(param is Label):
			param.clear()
			if param is LineEdit:
				param.emit_signal("text_changed", "")
	is_loading = false
	$Buttons/Create.show()
	$Buttons/Draw.hide()

func load_object() -> void:
	if "not_found" in editor.obj:
		return

	is_loading = true
	for param in $Params.get_children():
		if !(param is Label):
			var name: String = param.name.substr(0, 1).to_lower() + param.name.substr(1)
			var value = editor.obj[name] if name in editor.obj else ""
			if name == "mass":
				value *= SceneDecoder.SCALE_MASS
			if param is LineEdit:
				value = str(value) if name != "scale" else str(value[0])
				param.emit_signal("text_changed", value)
			else:
				value = Vector3(value[0], value[1], value[2])
			param.set_text(value)
			param.set_editable(true)
	is_loading = false
	$Buttons/Create.hide()
	$Buttons/Draw.show()

func create():
	if !editor.obj.has("not_found"):
		return

	var obj := {}
	obj.with_script = true
	obj.has_collision_object = true
	set_params(obj)
	editor.scene.set_object(obj)
	not_saved()
	clear()
	SceneDecoder.create_single_object(obj, editor.scene.data)
	camera.create_label(obj)
