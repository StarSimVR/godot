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
				
func _physics_process(delta):
	if SceneDecoder.is_editor:
		return
		
	if first_draw:
		first_draw = false
		init()
	iter()
	update_position(delta)

func iter():
	var children = self.get_children()
	for child in children:
		child.updateInfluence()
			
			
func update_position(delta):
	var children = self.get_children()
	for child in children:
		child.updatePosition(delta)



func init():
	# Since the force from A to B is the same as from B to A, just with the opposite direction,
	# we can use this to only do the calculation once and act on both bodies.
	# Hence adding the objects in the following pattern: (n-1) -> (n-2) -> ... -> 1 -> 0
	var children = self.get_children()
	var index = 0
	for child in children:
		index += 1
		for i in children.size():
			if i < index:
				continue
			child.addObject(children[i])


