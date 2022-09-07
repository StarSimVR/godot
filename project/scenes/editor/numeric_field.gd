extends "./release_focus.gd"

var old_text := "0"
export var is_integer := false

func _ready():
	var _err = connect("text_changed", self, "_on_text_changed")

func _on_text_changed(new_text: String):
	var is_valid := new_text.is_valid_integer() if is_integer else new_text.is_valid_float()
	if new_text.empty() || is_valid:
		old_text = new_text
	else:
		var old_position := get_cursor_position()
		var cursor_position := int(clamp(old_position - 1, 0, len(old_text)))
		text = old_text
		print("return old_text ", old_text, " from ", new_text)
		set_cursor_position(cursor_position)
