extends HBoxContainer

func _ready() -> void:
	var _errX := $X.connect("gui_input", self, "_on_gui_input")
	var _errY := $Y.connect("gui_input", self, "_on_gui_input")
	var _errZ := $Z.connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event: InputEvent) -> void:
	emit_signal("gui_input", event)

func get_text() -> Vector3:
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
