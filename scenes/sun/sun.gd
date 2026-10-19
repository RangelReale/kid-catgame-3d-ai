extends Node3D

## How fast the rays turn, in radians per second.
@export var ray_speed: float = 0.3

@onready var _rays: Node3D = $Visual/Rays


func _process(delta: float) -> void:
	_rays.rotation.z -= ray_speed * delta
