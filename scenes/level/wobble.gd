extends Node3D

## Gently moves a decoration: water goes up and down, seaweed sways.

## How far it goes up and down from where it starts, in units.
@export var bob_height: float = 0.0
## How far it tips to each side, in degrees.
@export var sway_degrees: float = 0.0
## Back-and-forth moves per second.
@export var speed: float = 0.5
## Where in the movement it starts, from 0 to 1, so neighbours differ.
@export var phase: float = 0.0

var _start_y: float
var _time: float = 0.0


func _ready() -> void:
	_start_y = position.y


func _process(delta: float) -> void:
	_time += delta
	var wave := sin(TAU * (_time * speed + phase))
	position.y = _start_y + bob_height * wave
	rotation.z = deg_to_rad(sway_degrees) * wave
