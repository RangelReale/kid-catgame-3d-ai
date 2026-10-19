extends Node3D

## A carousel with horses that go round. Each horse body (what the cat stands
## on) moves left and right on the plane where the cat walks, exactly like in
## the 2D game. Only its Visual goes round the pole in depth, so the cat can
## ride every horse while it looks like a real carousel.

## How far the horses go to each side of the middle, in units.
@export var radius: float = 1.71875
## How far the horses go towards the camera and away from it, in units.
@export var depth_radius: float = 0.8
## How fast the carousel turns, in turns per second.
@export var turns_per_second: float = 0.12
## How far each horse goes up and down while it turns, in units.
@export var bob_height: float = 0.1875

var _angle: float = 0.0

@onready var _horses: Array[Node] = $Horses.get_children()


func _ready() -> void:
	_place_horses()


func _physics_process(delta: float) -> void:
	_angle += TAU * turns_per_second * delta
	_place_horses()


## Moves the horses around the pole. The horses in front move left, the ones
## at the back move right, and each one faces the way it goes.
func _place_horses() -> void:
	for i in _horses.size():
		var horse := _horses[i] as Node3D
		var horse_angle := _angle + TAU * i / _horses.size()
		horse.position = Vector3(cos(horse_angle) * radius, -sin(horse_angle * 3.0) * bob_height, 0)
		var visual := horse.get_node("Visual") as Node3D
		visual.position.z = sin(horse_angle) * depth_radius
		var heading := Vector2(-sin(horse_angle) * radius, cos(horse_angle) * depth_radius)
		visual.rotation.y = atan2(-heading.y, heading.x)
