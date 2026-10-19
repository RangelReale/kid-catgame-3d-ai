extends Node3D

## A ferris wheel. The wheel turns behind the cat, and the cabins hang
## straight down in front of it, on the plane where the cat walks. The cat
## can jump into a cabin from below and ride it.

## Distance from the middle of the wheel to each cabin, in units.
@export var radius: float = 2.5
## How fast the wheel turns, in turns per second.
@export var turns_per_second: float = 0.05

var _angle: float = 0.0

@onready var _wheel: Node3D = $Visual/Wheel
@onready var _cabins: Array[Node] = $Cabins.get_children()


func _ready() -> void:
	_place_cabins()


func _physics_process(delta: float) -> void:
	_angle += TAU * turns_per_second * delta
	_wheel.rotation.z = -_angle
	_place_cabins()


## Puts the cabins around the wheel, always hanging straight down. The wheel
## turns clockwise, as seen from the camera.
func _place_cabins() -> void:
	for i in _cabins.size():
		var cabin := _cabins[i] as Node3D
		var cabin_angle := _angle + TAU * i / _cabins.size()
		cabin.position = Vector3(cos(cabin_angle), -sin(cabin_angle), 0) * radius
