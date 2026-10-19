extends Camera3D

## Follows the cat from the side, a little from above and from the left, so
## the boxes show their tops and sides. The cat always moves on the flat
## plane where z is 0; the camera never lets the view go past the limits on
## that plane.

## What the camera follows, usually the cat.
@export var target: Node3D
## How far the camera is from the point it looks at, in units.
@export var distance: float = 12.0
## How much the camera looks down, in degrees. 0 is a flat side view.
@export var pitch_degrees: float = 8.0
## How much the camera turns to look right from the left side, in degrees.
## 0 is a flat side view.
@export var yaw_degrees: float = 6.0
## Point the camera looks at, measured from the target's feet.
@export var look_offset: Vector3 = Vector3(0, 0.25, 0)
## How fast the camera catches up with the target; higher is faster.
@export var smoothing: float = 5.0
## The edges of the level on the z = 0 plane, in units.
@export var limit_left: float = -10000.0
@export var limit_right: float = 10000.0
@export var limit_bottom: float = -10000.0
@export var limit_top: float = 10000.0

var _focus: Vector3
## The visible part of the z = 0 plane, measured from the point the camera
## looks at.
var _view_min: Vector2
var _view_max: Vector2
var _view_size: Vector2


func _ready() -> void:
	if target != null:
		_focus = _clamped(target.global_position + look_offset)
	_place(_focus)


func _process(delta: float) -> void:
	if target == null:
		return
	var goal := _clamped(target.global_position + look_offset)
	_focus = _focus.lerp(goal, 1.0 - exp(-smoothing * delta))
	_place(_focus)


func _place(focus: Vector3) -> void:
	var pitch := deg_to_rad(pitch_degrees)
	var yaw := deg_to_rad(yaw_degrees)
	var back := Vector3(-sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
	global_position = focus + back * distance
	look_at(focus, Vector3.UP)


## Moves the point the camera looks at so the view stays inside the limits.
## When the level is narrower than the view, the camera stays in the middle.
func _clamped(focus: Vector3) -> Vector3:
	_measure_view()
	var low := Vector2(limit_left, limit_bottom) - _view_min
	var high := Vector2(limit_right, limit_top) - _view_max
	focus.x = clampf(focus.x, low.x, high.x) if low.x <= high.x else (low.x + high.x) / 2.0
	focus.y = clampf(focus.y, low.y, high.y) if low.y <= high.y else (low.y + high.y) / 2.0
	return focus


## Finds where the screen corners land on the z = 0 plane, with the camera
## looking at the origin. The tilt makes that shape a slanted four-sided
## shape, so this keeps the largest upright box inside it. A little of the
## level past the limits can show in the corners.
func _measure_view() -> void:
	var screen := get_viewport().get_visible_rect().size
	if screen == _view_size:
		return
	_view_size = screen
	var saved := global_transform
	_place(Vector3.ZERO)
	var top_left := _on_plane(Vector2.ZERO)
	var top_right := _on_plane(Vector2(screen.x, 0))
	var bottom_left := _on_plane(Vector2(0, screen.y))
	var bottom_right := _on_plane(screen)
	global_transform = saved
	_view_min = Vector2(maxf(top_left.x, bottom_left.x), maxf(bottom_left.y, bottom_right.y))
	_view_max = Vector2(minf(top_right.x, bottom_right.x), minf(top_left.y, top_right.y))


## Where the line from the camera through a screen point meets the z = 0 plane.
func _on_plane(screen_point: Vector2) -> Vector2:
	var origin := project_ray_origin(screen_point)
	var direction := project_ray_normal(screen_point)
	var point := origin + direction * (-origin.z / direction.z)
	return Vector2(point.x, point.y)
