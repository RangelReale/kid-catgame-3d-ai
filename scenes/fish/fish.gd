extends Area3D

## Swimming speed, in units per second.
@export var speed: float = 0.625
## How far the fish swims to each side of where it starts, in units.
@export var swim_distance: float = 0.9375
## Seconds before a caught fish comes back to the water.
@export var respawn_time: float = 3.0
## Colour of the fish's body.
@export var color: Color = Color(1, 0.65, 0.2)

var _start_x: float
var _direction: float = 1.0
var _caught: bool = false

@onready var _visual: Node3D = $Visual
@onready var _sparkles: CPUParticles3D = $Sparkles


func _ready() -> void:
	_start_x = position.x
	body_entered.connect(_on_body_entered)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	$Visual/Body.material_override = material


func _physics_process(delta: float) -> void:
	if _caught:
		return
	position.x += speed * _direction * delta
	if absf(position.x - _start_x) >= swim_distance:
		position.x = _start_x + swim_distance * _direction
		_direction = -_direction
	_visual.rotation.y = 0.0 if _direction > 0.0 else PI


## The cat caught the fish: it jumps out in sparkles and comes back later.
func _on_body_entered(body: Node3D) -> void:
	if not body is Player or _caught:
		return
	_caught = true
	_visual.hide()
	_sparkles.restart()
	get_tree().create_timer(respawn_time).timeout.connect(_come_back)


func _come_back() -> void:
	_caught = false
	_visual.show()
	# Lets a cat that is still touching the fish catch it again.
	for body in get_overlapping_bodies():
		_on_body_entered(body)
