extends HBoxContainer
signal text_changed

func _ready() -> void:
	var _err
	_err = $X.connect("gui_input", self, "_on_gui_input")
	_err = $Y.connect("gui_input", self, "_on_gui_input")
	_err = $Z.connect("gui_input", self, "_on_gui_input")
	_err = $X.connect("text_changed", self, "_on_text_changed")
	_err = $Y.connect("text_changed", self, "_on_text_changed")
	_err = $Z.connect("text_changed", self, "_on_text_changed")

func _on_gui_input(event: InputEvent) -> void:
	emit_signal("gui_input", event)

func _on_text_changed(new_text: String) -> void:
	emit_signal("text_changed", new_text)

func get_text() -> Vector3:
	return get_vector()

func get_vector() -> Vector3:
	return Vector3(float($X.get_text()), float($Y.get_text()), float($Z.get_text()))

func get_array() -> Array:
	var vec := get_text()
	return [vec.x, vec.y, vec.z]

func set_text(vec: Vector3) -> void:
	$X.set_text(str(vec.x))
	$Y.set_text(str(vec.y))
	$Z.set_text(str(vec.z))

func clear() -> void:
	$X.set_text("")
	$Y.set_text("")
	$Z.set_text("")

func set_editable(editable: bool) -> void:
	$X.set_editable(editable)
	$Y.set_editable(editable)
	$Z.set_editable(editable)
