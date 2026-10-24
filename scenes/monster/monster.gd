extends Area3D

## Walking speed, in units per second.
@export var speed: float = 0.78125
## How far the monster walks to each side of where it starts, in units.
@export var walk_distance: float = 1.875

## How far above the monster's feet the cat's feet must be to count as
## landing on top, in units (2 pixels of the 2D game). Small, so a falling cat
## has a few frames to hit; a cat standing on the floor is never above it.
const STOMP_HEIGHT := 0.0625

var _start_x: float
var _direction: float = 1.0
var _popped: bool = false

@onready var _visual: Node3D = $Visual
@onready var _poof: CPUParticles3D = $Poof
@onready var _pop_sound: AudioStreamPlayer = $PopSound


func _ready() -> void:
	_start_x = position.x
	_poof.finished.connect(queue_free)


func _physics_process(delta: float) -> void:
	if _popped:
		return

	position.x += speed * _direction * delta
	if absf(position.x - _start_x) >= walk_distance:
		position.x = _start_x + walk_distance * _direction
		_direction = -_direction
	_visual.rotation.y = 0.0 if _direction > 0.0 else PI

	for body in get_overlapping_bodies():
		if body is Player and _is_landed_on(body):
			_pop(body)
			return


func _is_landed_on(player: Player) -> bool:
	return player.velocity.y < 0.0 \
		and player.global_position.y > global_position.y + STOMP_HEIGHT


## Turns the monster into a puff of sparkles and bounces the cat up.
func _pop(player: Player) -> void:
	_popped = true
	_visual.hide()
	player.bounce()
	_poof.emitting = true
	_pop_sound.play()
