extends HBoxContainer
signal text_changed

export var is_integer := false

func _ready() -> void:
	var _err
	_err = $Min.connect("gui_input", self, "_on_gui_input")
	_err = $Max.connect("gui_input", self, "_on_gui_input")
	_err = $Min.connect("text_changed", self, "_on_text_changed")
	_err = $Max.connect("text_changed", self, "_on_text_changed")
	$Min.is_integer = is_integer
	$Max.is_integer = is_integer

func _on_gui_input(event: InputEvent) -> void:
	emit_signal("gui_input", event)

func _on_text_changed(new_text: String) -> void:
	emit_signal("text_changed", new_text)

func get_text() -> Array:
	return [$Min.get_num(), $Max.get_num() if $Max.get_text() else $Min.get_num()]

func set_text(values: Array) -> void:
	$Min.set_text(str(values[0]))
	$Max.set_text(str(values[1]))
	emit_text_changed()

func clear() -> void:
	$Min.set_text("")
	$Max.set_text("")
	emit_text_changed()

func set_editable(editable: bool) -> void:
	$Min.set_editable(editable)
	$Max.set_editable(editable)

func emit_text_changed() -> void:
	$Min.emit_signal("text_changed", $Min.get_text())
	$Max.emit_signal("text_changed", $Max.get_text())
