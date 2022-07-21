class_name Space
extends Spatial


var _curr_object := 1
var first_draw := true


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
				
func _process(delta):
	return
	if first_draw:
		first_draw = false
		init()
	iter()
	update_position()
			
			
func iter():
	return 
	var children = self.get_children()
	for child in children:
		child.updateInfluence()
			
			
func update_position():
	return 
	var children = self.get_children()
	for child in children:
		child.updatePosition()
			
			
func init():
	return
	var children = self.get_children()
	for child in children:
		child.init(self.get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass_curr_object -= 1

