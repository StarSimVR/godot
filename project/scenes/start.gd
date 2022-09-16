extends Control

func _ready() -> void:
	var dir = Directory.new()
	if dir.dir_exists("./encoded_scenes/"):
		dir.open("./encoded_scenes/")
	elif dir.dir_exists("./scenes/"):
		dir.open("./scenes/")
	else:
		return
	dir.list_dir_begin(true)

	if dir.file_exists(SceneDecoder.DEFAULT_SCENE + ".json"):
		$Buttons/SceneList.add_item(SceneDecoder.DEFAULT_SCENE)
	var filename: String = dir.get_next()
	while filename:
		if filename.match("*.json") && filename != SceneDecoder.DEFAULT_SCENE + ".json":
			$Buttons/SceneList.add_item(filename.replace(".json", ""))
		filename = dir.get_next()

func _on_scene_selected(index: int) -> void:
	SceneDecoder.opened_scene = $Buttons/SceneList.get_item_text(index)

func _on_Start3D_pressed() -> void:
	var _err = get_tree().change_scene("res://scenes/3d/3d.tscn")

func _on_StartVR_pressed() -> void:
	var _err = get_tree().change_scene("res://scenes/vr/vr.tscn")

func _on_StartEditor_pressed() -> void:
	get_tree().set_debug_collisions_hint(true)
	var _err = get_tree().change_scene("res://scenes/editor/editor.tscn")
