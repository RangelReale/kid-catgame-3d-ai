class_name Player
extends CharacterBody3D

## Speeds and sizes are in units; 1 unit is 32 pixels of the 2D game, so the
## cat moves and jumps exactly as it did there. Up is positive y.

## Horizontal speed, in units per second.
@export var speed: float = 3.75
## Upward speed at the start of a jump, in units per second.
@export var jump_speed: float = 9.375
## Downward acceleration, in units per second squared.
@export var gravity: float = 28.125
## Extra jumps the cat can do in the air with its wings, before landing.
@export var air_jumps: int = 3
## Upward speed at the start of each wing flap, in units per second.
@export var flap_speed: float = 7.8125
## Upward speed after landing on a monster, in units per second.
@export var bounce_speed: float = 6.875
## Time the somersault takes during a jump, in seconds.
@export var flip_duration: float = 0.5
## When true, the cat has a mermaid tail instead of legs and cat tail.
@export var mermaid: bool = false
## When true, the cat flies freely with its wings, like the mermaid swims.
@export var flying: bool = false
## Mermaid or flying only: up and down speed, in units per second.
@export var swim_speed: float = 4.0625
## Mermaid or flying only: how fast the cat starts and stops going up or down,
## in units per second squared.
@export var swim_acceleration: float = 21.875

## Point the somersault turns around: the middle of the cat.
const FLIP_PIVOT := Vector2(0, 0.25)

## Seconds since the somersault started; negative when not flipping.
var _flip_time: float = -1.0
## Wing flaps left before the cat touches the floor again.
var _air_jumps_left: int = 0

@onready var _visual: Node3D = $Visual
@onready var _jump_sound: AudioStreamPlayer = $JumpSound


func _ready() -> void:
	add_to_group("player")
	for part: Node3D in [$Visual/LegBackLeft, $Visual/LegBackRight, $Visual/LegFrontLeft, $Visual/LegFrontRight, $Visual/Tail]:
		part.visible = not mermaid
	$Visual/MermaidTail.visible = mermaid


func _physics_process(delta: float) -> void:
	if mermaid or flying:
		_swim(delta)
	else:
		_walk_and_jump(delta)

	velocity.x = Input.get_axis("move_left", "move_right") * speed

	move_and_slide()
	_update_flip(delta)


## Jump makes the mermaid or flying cat go up and move_down makes it go down.
## With neither, it stays at the same height.
func _swim(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_play_jump_sound(1.0)
	var direction := Input.get_axis("move_down", "jump")
	velocity.y = move_toward(velocity.y, direction * swim_speed, swim_acceleration * delta)


func _walk_and_jump(delta: float) -> void:
	if is_on_floor():
		_air_jumps_left = air_jumps
	else:
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed
			_flip_time = 0.0
			_play_jump_sound(1.0)
		elif _air_jumps_left > 0:
			velocity.y = flap_speed
			_air_jumps_left -= 1
			_play_jump_sound(1.0 + 0.15 * (air_jumps - _air_jumps_left))


## Plays the "boing"; each wing flap sounds a little higher.
func _play_jump_sound(pitch: float) -> void:
	_jump_sound.pitch_scale = pitch
	_jump_sound.play()


## Makes the cat hop up, as when it lands on a monster.
## Pass a speed to bounce higher or lower, like on a trampoline.
func bounce(speed_up: float = 0.0) -> void:
	velocity.y = speed_up if speed_up > 0.0 else bounce_speed
	_flip_time = 0.0


## Puts the cat back at a spot in the level, standing still.
func respawn(spot: Vector3) -> void:
	global_position = spot
	velocity = Vector3.ZERO
	_flip_time = -1.0


## The somersault turns the cat forward, which is clockwise seen from the
## camera, around the middle of its body.
func _update_flip(delta: float) -> void:
	var angle := 0.0
	if _flip_time >= 0.0:
		_flip_time += delta
		var progress := _flip_time / flip_duration
		if progress >= 1.0 or is_on_floor():
			_flip_time = -1.0
		else:
			angle = -TAU * progress
	_visual.rotation.z = angle
	var offset := FLIP_PIVOT - FLIP_PIVOT.rotated(angle)
	_visual.position = Vector3(offset.x, offset.y, 0)
