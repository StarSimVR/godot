extends Spatial

export(float) var speed = 1.0 # angle / sec

func _process(delta) -> void:
	rotate_z(speed * delta)

func slower() -> void:
	speed *= 0.5

func faster() -> void:
	speed *= 2
