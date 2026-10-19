extends Node3D

## How fast the cloud drifts to the right, in units per second.
@export var speed: float = 0.6
## Half the width of the strip of sky the cloud crosses, in units. When the
## cloud leaves it on the right, it comes back on the left.
@export var wrap_half_width: float = 32.0

## Half the cloud's width, so it leaves the strip fully before coming back.
const HALF_WIDTH := 2.0


func _process(delta: float) -> void:
	position.x += speed * scale.x * delta
	if position.x - HALF_WIDTH * scale.x > wrap_half_width:
		position.x = -wrap_half_width - HALF_WIDTH * scale.x
