extends Area3D

## Upward speed the cat gets when it lands on the trampoline, in units per
## second (480 pixels per second in the 2D game).
@export var bounce_speed: float = 15.0

## How far the mat dips when the cat lands, in units.
const DIP := 0.1

@onready var _mat: Node3D = $Visual/Mat
@onready var _mat_y: float = _mat.position.y


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is Player and body.velocity.y <= 0.0:
			body.bounce(bounce_speed)
			_mat.position.y = _mat_y - DIP
			create_tween().tween_property(_mat, "position:y", _mat_y, 0.2)
