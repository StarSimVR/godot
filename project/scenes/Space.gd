class_name Space
extends Spatial


onready var _objects := self.get_children()
var _curr_object := 1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func increaseCurObject():
	_curr_object += 1
	if _curr_object == _objects.size():
		_curr_object = 1
	
func decreaseCurObject():
	_curr_object -= 1
	if _curr_object == 0:
		_curr_object = _objects.size() - 1
	
func getCurObject():
	return _objects[_curr_object]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass_curr_object -= 1
	
