extends Spatial

export(float) var speed = 1.0 # angle / sec
export(bool) var is_editor = false

func _process(delta) -> void:
	if !is_editor:
		rotate_z(speed * delta)

func slower() -> void:
	speed *= 0.5

func faster() -> void:
	speed *= 2
