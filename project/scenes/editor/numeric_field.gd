extends "./release_focus.gd"

var old_text := "0"
export var min_value := 0
export var max_value := 4294967295

func _ready():
	var _err = connect("text_changed", self, "_on_text_changed")

func _on_text_changed(new_text: String):
	var num := float(new_text)
	if new_text.empty() || (new_text.is_valid_float() && num >= min_value && num <= max_value):
		old_text = new_text
	else:
		var old_position := get_cursor_position()
		var cursor_position := int(clamp(old_position - 1, 0, len(old_text)))
		text = old_text
		set_cursor_position(cursor_position)
