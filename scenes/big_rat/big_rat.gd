extends Area3D

## A big boss that walks back and forth. The cat must land on it a few times
## to win; then the flag appears.

## Walking speed, in units per second.
@export var speed: float = 1.25
## How far the boss walks to each side of where it starts, in units.
@export var walk_distance: float = 2.8125
## How many times the cat must land on the boss to win.
@export var max_health: int = 3
## Where the cat goes back to when the boss touches it from the side.
@export var respawn_position: Vector3 = Vector3.ZERO
## The flag that appears when the boss is beaten.
@export var goal: Node
## Seconds after a hit when the boss does nothing to the cat.
@export var hurt_cooldown: float = 0.6

## How far above the boss's feet the cat's feet must be to count as landing
## on top, in units (2 pixels of the 2D game).
const STOMP_HEIGHT := 0.0625
## How red the boss turns when the cat lands on it, from 0 to 1.
const HURT_TINT := 0.45

var _health: int
var _start_x: float
var _direction: float = 1.0
var _cooldown: float = 0.0
var _beaten: bool = false
## Drawn over every part of the boss to make it look red for a moment.
var _tint := StandardMaterial3D.new()

@onready var _visual: Node3D = $Visual
@onready var _health_bar: Node3D = $HealthBar
@onready var _health_fill: Node3D = $HealthBar/Fill
@onready var _poof: CPUParticles3D = $Poof
@onready var _stomp_sound: AudioStreamPlayer = $StompSound
@onready var _pop_sound: AudioStreamPlayer = $PopSound


func _ready() -> void:
	_health = max_health
	_start_x = position.x
	_poof.finished.connect(queue_free)
	_tint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_tint.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_tint.albedo_color = Color(1, 0.2, 0.2, 0)
	for node in _visual.find_children("*", "MeshInstance3D"):
		(node as MeshInstance3D).material_overlay = _tint


func _physics_process(delta: float) -> void:
	if _beaten:
		return

	position.x += speed * _direction * delta
	if absf(position.x - _start_x) >= walk_distance:
		position.x = _start_x + walk_distance * _direction
		_direction = -_direction
	_visual.scale.x = _direction

	_cooldown -= delta
	for body in get_overlapping_bodies():
		if body is Player:
			if _is_landed_on(body):
				_hit(body)
			elif _cooldown <= 0.0:
				_send_back(body)
			return


func _is_landed_on(player: Player) -> bool:
	return player.velocity.y < 0.0 \
		and player.global_position.y > global_position.y + STOMP_HEIGHT


## The cat landed on the boss: one less life, and the cat bounces up.
func _hit(player: Player) -> void:
	_health -= 1
	_cooldown = hurt_cooldown
	player.bounce()
	_update_health_bar()
	if _health <= 0:
		_beaten = true
		_visual.hide()
		_health_bar.hide()
		_poof.emitting = true
		# Only the "puf" plays on the last hit, not the "bonk".
		_pop_sound.play()
		if goal != null:
			goal.unlock()
		return
	_stomp_sound.play()
	_tint.albedo_color.a = HURT_TINT
	create_tween().tween_property(_tint, "albedo_color:a", 0.0, hurt_cooldown)


## The boss touched the cat from the side: the cat goes back a little and the
## boss gets all its life back.
func _send_back(player: Player) -> void:
	_health = max_health
	_cooldown = hurt_cooldown
	_update_health_bar()
	player.respawn(respawn_position)


## The fill starts at the left end of the bar, so scaling it keeps that end
## in place.
func _update_health_bar() -> void:
	_health_fill.scale.x = maxf(float(_health) / max_health, 0.001)


## How many lives the boss has left. Used by the tests.
func get_health() -> int:
	return _health
