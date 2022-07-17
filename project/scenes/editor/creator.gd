extends VBoxContainer

var saved_margin_bottom := self.margin_bottom
onready var editor := get_node("../Editor")

func to_editor():
	self.hide()
	clear()
	editor.show()
	editor.init()

func create():
	var obj := {}
	obj.with_script = true
	obj.name = $Params/Name.get_text()
	obj.geometry = $Params/Geometry.get_text()
	var scale := float($Params/Scale.get_text())
	obj.scale = [scale, scale, scale]
	obj.mass = float($Params/Mass.get_text())
	obj.radius = float($Params/Radius.get_text())
	obj.speed = float($Params/Speed.get_text())
	obj.eccentricity = float($Params/Eccentricity.get_text())
	obj.has_collision_object = true
	editor.scene.set_object(obj)
	editor.save()
	to_editor()

func clear():
	for param in $Params.get_children():
		if param is LineEdit:
			param.set_text("")
			param.emit_signal("text_changed", "")

func init():
	get_node("/root/Main/HUD/Background").set_margin(MARGIN_BOTTOM, saved_margin_bottom + 40)
