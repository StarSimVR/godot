class_name Space
extends Spatial


var _curr_object := 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_cur_object():
	var _objects = self.get_children()
	if(_objects.size() == 0): return null
	return _objects[_curr_object]

func set_cur_object(object):
	var parent_name = object.get_parent().name
	var _objects = self.get_children()
	for i in range(len(_objects)):
		if(parent_name == _objects[i].name):
			_curr_object = i
			return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass_curr_object -= 1

