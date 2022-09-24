extends ColorRect

func _ready():
	$Text.set_text(generate_help_text())

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("help"):
		visible = !visible

func can_use_hotkey(deadzone: float) -> bool:
	# deadzone = 1: hotkey in editor
	# deadzone = 0.5: hotkey both in 3D and in editor
	# deadzone = 0: hotkey in 3D
	if deadzone > 0.6:
		return SceneDecoder.is_editor
	elif deadzone < 0.4:
		return !SceneDecoder.is_editor
	else:
		return true

func generate_help_text():
	var help_text := ""
	var actions := InputMap.get_actions()
	for action in actions:
		var deadzone := InputMap.action_get_deadzone(action)
		if action.match("ui_*") || !can_use_hotkey(deadzone):
			continue

		var action_list := InputMap.get_action_list(action)
		var keys := PoolStringArray()
		for curr in action_list:
			if curr is InputEventKey:
				var scancode: int = curr.get_physical_scancode_with_modifiers()
				scancode = scancode if scancode > 0 else curr.get_scancode_with_modifiers()
				keys.push_back(OS.get_scancode_string(scancode))

		if action == "zoom_in" || action == "zoom_out":
			keys.push_back("mouse wheel")
		if len(keys) > 0:
			var action_name: String = action.replace("_", " ")
			action_name = action_name[0].to_upper() + action_name.substr(1)
			help_text += action_name + " - " + keys.join(", ") + "\n"
	return help_text
