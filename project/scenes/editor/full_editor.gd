extends VBoxContainer

onready var editor := get_node("../Editor")

var saved_margin_bottom := self.margin_bottom

func to_editor() -> void:
	self.hide()
	editor.show()
	editor.init()

func save() -> void:
	var obj := {}
	if "not_found" in editor.obj:
		obj.with_script = true
		obj.has_collision_object = true
	else:
		obj = editor.obj

	set_params(obj)
	if "not_found" in editor.obj:
		editor.scene.set_object(obj)
	editor.save()

func set_params(obj: Dictionary) -> void:
	obj.name = $Params/Name.get_text()
	obj.geometry = $Params/Geometry.get_text()
	var scale := float($Params/Scale.get_text())
	obj.scale = [scale, scale, scale]
	obj.mass = float($Params/Mass.get_text())
	obj.rotationSpeed = int($Params/RotationSpeed.get_text())
	obj.position = $Params/Position.get_array()
	obj.velocity = $Params/Velocity.get_array()
	obj.orientation = $Params/Orientation.get_array()

func clear() -> void:
	for param in $Params.get_children():
		if !(param is Label):
			param.clear()
			if param is LineEdit:
				param.emit_signal("text_changed", "")

func load_object() -> void:
	if "not_found" in editor.obj:
		return

	for param in $Params.get_children():
		if !(param is Label):
			var name: String = param.name.substr(0, 1).to_lower() + param.name.substr(1)
			var value = editor.obj[name]
			if param is LineEdit:
				value = str(value) if name != "scale" else str(value[0])
			else:
				value = Vector3(value[0], value[1], value[2])
			param.set_text(value)
		if param is LineEdit:
			param.emit_signal("text_changed", "")

func init() -> void:
	get_node("/root/Main/HUD/Background").set_margin(MARGIN_BOTTOM, saved_margin_bottom + 40)
