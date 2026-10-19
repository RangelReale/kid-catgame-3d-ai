extends Area3D

## Emitted once, when the bird touches the cat.
signal caught

## How far the bird flies from where it starts, and in which direction, in
## units. It goes back and forth between -travel and +travel.
@export var travel: Vector3 = Vector3(0, 1.875, 0)
## Back-and-forth trips per second.
@export var trips_per_second: float = 0.3
## Where in its trip the bird starts, from 0 to 1.
@export_range(0.0, 1.0) var phase: float = 0.0
## Wing flaps per second.
@export var flaps_per_second: float = 4.0

var _start: Vector3
var _time: float = 0.0
var _caught: bool = false

@onready var _visual: Node3D = $Visual
@onready var _wing_left: Node3D = $Visual/WingLeft
@onready var _wing_right: Node3D = $Visual/WingRight


func _ready() -> void:
	add_to_group("catcher")
	_start = position
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_time += delta
	var angle := TAU * (_time * trips_per_second + phase)
	var previous_x := position.x
	position = _start + travel * sin(angle)
	# The bird looks left; it turns around when it flies to the right.
	if position.x != previous_x:
		_visual.rotation.y = 0.0 if position.x < previous_x else PI
	var flap := 0.6 * sin(TAU * _time * flaps_per_second)
	_wing_left.rotation.x = -flap
	_wing_right.rotation.x = flap


func _on_body_entered(body: Node3D) -> void:
	if body is Player and not _caught:
		_caught = true
		caught.emit()
