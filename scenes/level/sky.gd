extends Node3D

## Far-away things like the sun and the clouds. They follow the camera, a
## little slower than it moves, so they look very far away.

## How much of the camera's sideways movement the sky follows. 1 keeps the
## sky fixed on the screen; 0 keeps it fixed in the level.
@export var follow: float = 0.9


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	position.x = camera.global_position.x * follow
	position.y = camera.global_position.y
