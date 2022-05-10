extends Spatial

export(float) var speed = 1.0 # angle / sec

func _process(delta):
	rotate_z(speed * delta)
