extends ARVRCamera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func updatePosition(_newPosition):
	self.look_at_from_position(self.transform.origin + _newPosition, Vector3(0,0,0), Vector3(0,1,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
