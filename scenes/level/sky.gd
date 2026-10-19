extends Node3D

## Far-away things like the sun and the clouds. They follow the camera, a
## little slower than it moves, so they look very far away.

## How much of the camera's sideways movement the sky follows. 1 keeps the
## sky fixed on the screen; 0 keeps it fixed in the level.
@export var follow: float = 0.9

## In the headset, the sky follows this node instead of the camera, because
## the camera there is the player's head. The rig of the diorama sets it.
var anchor: Node3D
## Where the sky sits from the anchor, and how big it is, when it has one.
var anchor_offset := Vector3.ZERO
var anchor_scale := 1.0


func _process(_delta: float) -> void:
	if is_instance_valid(anchor):
		global_position = anchor.global_position + anchor_offset
		scale = Vector3.ONE * anchor_scale
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	position.x = camera.global_position.x * follow
	position.y = camera.global_position.y
