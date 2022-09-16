extends VBoxContainer

const noise_params := ["amplitude", "octaves", "period", "persistence", "lacunarity"]

onready var editor := get_node("../Editor")
var last_line_of_params: HBoxContainer

var saved_margin_bottom := self.margin_bottom

func _ready() -> void:
	var planet_data: Array = editor.scene.get_all_planet_data()
	for pd in planet_data:
		$Params/Edit.add_item(pd.name)

func init() -> void:
	get_node("/root/Main/HUD/Background").set_margin(MARGIN_BOTTOM, saved_margin_bottom + 40)

func to_editor() -> void:
	self.hide()
	editor.show()
	editor.init()

func _on_picker_created() -> void:
	var color_picker: ColorPicker = $Params/Color.get_picker()
	var color_params: VBoxContainer = color_picker.get_child(4)
	last_line_of_params = color_params.get_child(4)
	color_picker.edit_alpha = false

func _on_Color_pressed() -> void:
	last_line_of_params.call_deferred("add_constant_override", "separation", 0)

func _on_Color_popup_closed() -> void:
	last_line_of_params.add_constant_override("separation", 10)
	var presets: PoolColorArray = $Params/Color.get_picker().get_presets()
	$Params/Color.color = presets[0] if presets.size() > 0 else Color.black

func clear() -> void:
	for param in $Params.get_children():
		if param is ColorPickerButton:
			param.color = Color.black
			param.get_picker().color = Color.black
		elif !(param is Label or param is OptionButton):
			param.clear()
			if param is LineEdit:
				param.emit_signal("text_changed", "")

func load_pd(pd_name: String) -> void:
	var pd: Dictionary = editor.scene.get_planet_data(pd_name)

	for param in $Params.get_children():
		if param is ColorPickerButton:
			var picker: ColorPicker = param.get_picker()
			var colors: Array = pd.planet_color.colors
			for color in picker.get_presets():
				picker.erase_preset(color)
			for i in colors.size() / 4.0:
				var color := Color(colors[i*4], colors[i*4+1], colors[i*4+2], colors[i*4+3])
				picker.add_preset(color)
				if i == 0:
					param.color = color
		elif !(param is Label or param is OptionButton):
			var name: String = param.name.substr(0, 1).to_lower() + param.name.substr(1)
			var value = pd.planet_noise[name] if name in noise_params else pd[name]
			if param is LineEdit:
				value = str(value)
				param.emit_signal("text_changed", value)
			else:
				value = value if typeof(value) == TYPE_ARRAY else [value, value]
			param.set_text(value)

func pd_name_changed(index: int) -> void:
	if index == 0:
		clear()
		return

	var pd_name: String = $Params/Edit.get_item_text(index)
	load_pd(pd_name)

func save() -> void:
	var index: int = $Params/Edit.get_selected_id()
	var pd := {
		"planet_noise": {"min_height": 0, "use_first_layer_as_mask": false},
		"planet_color": {"width": 128}
	}
	if index > 0:
		var pd_name: String = $Params/Edit.get_item_text(index)
		pd = editor.scene.get_planet_data(pd_name)

	for param in $Params.get_children():
		if param is ColorPickerButton:
			var colors: PoolColorArray = param.get_picker().get_presets()
			pd.planet_color.colors = []
			pd.planet_color.offsets = []
			var i := 0.0
			for color in colors:
				pd.planet_color.colors.append(color.r)
				pd.planet_color.colors.append(color.g)
				pd.planet_color.colors.append(color.b)
				pd.planet_color.colors.append(color.a)
				pd.planet_color.offsets.append(i / max(colors.size() - 1, 1))
				i += 1
		elif !(param is Label or param is OptionButton):
			var name: String = param.name.substr(0, 1).to_lower() + param.name.substr(1)
			var value = param.get_num() if param.has_method("get_num") else param.get_text()
			if typeof(value) == TYPE_ARRAY && value[0] == value[1]:
				value = value[0]
			if name in noise_params:
				pd.planet_noise[name] = value
			else:
				pd[name] = value

	if index == 0:
		editor.scene.set_planet_data(pd)
		$Params/Edit.add_item(pd.name)
	editor.save()
	to_editor()
