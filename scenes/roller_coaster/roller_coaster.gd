extends Path3D

## A small roller coaster: a cart rides back and forth along the track and
## waits at each end, so the cat can get in. The rails and posts are made
## from the track's curve when the level starts.

## How fast the cart rides along the track, in units per second.
@export var speed: float = 3.4375
## Seconds the cart waits at each end of the track, so the cat can get in.
@export var wait_at_ends: float = 1.5
## Colour of the rails.
@export var rail_color: Color = Color(1, 0.4, 0.5)
## Colour of the posts under the track.
@export var post_color: Color = Color(0.6, 0.6, 0.68)
## Distance between the posts, in units.
@export var post_spacing: float = 2.34375

## How far each rail is from the middle of the track, towards and away from
## the camera, in units.
const RAIL_OFFSET := 0.3

var _progress: float = 0.0
var _direction: float = 1.0
var _waiting: float = 0.0

@onready var _cart: AnimatableBody3D = $Cart
@onready var _visual: Node3D = $Visual


func _ready() -> void:
	_build_track()
	_cart.position = curve.sample_baked(0.0)


## Moves the cart along the track, back and forth. The cart is moved directly,
## not through a PathFollow3D, so its collision moves with it.
func _physics_process(delta: float) -> void:
	if _waiting > 0.0:
		_waiting -= delta
		return
	var length := curve.get_baked_length()
	_progress += speed * _direction * delta
	if _progress >= length or _progress <= 0.0:
		_progress = clampf(_progress, 0.0, length)
		_direction = -_direction
		_waiting = wait_at_ends
	_cart.position = curve.sample_baked(_progress)


## Makes two rails along the curve and posts from the ground up to the track.
func _build_track() -> void:
	var rail_material := StandardMaterial3D.new()
	rail_material.albedo_color = rail_color
	var post_material := StandardMaterial3D.new()
	post_material.albedo_color = post_color
	for i in curve.point_count - 1:
		var from := curve.get_point_position(i)
		var to := curve.get_point_position(i + 1)
		var step := to - from
		for side in [-RAIL_OFFSET, RAIL_OFFSET]:
			var rail := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(step.length() + 0.02, 0.06, 0.06)
			box.material = rail_material
			rail.mesh = box
			rail.position = (from + to) / 2.0 + Vector3(0, 0, side)
			rail.rotation.z = atan2(step.y, step.x)
			_visual.add_child(rail)
	var end_x := curve.get_point_position(curve.point_count - 1).x
	var x := post_spacing / 2.0
	while x < end_x:
		var height := _height_at(x)
		if height > 0.1:
			for side in [-RAIL_OFFSET, RAIL_OFFSET]:
				var post := MeshInstance3D.new()
				var box := BoxMesh.new()
				box.size = Vector3(0.1, height, 0.1)
				box.material = post_material
				post.mesh = box
				post.position = Vector3(x, height / 2.0, side)
				_visual.add_child(post)
		x += post_spacing


## Height of the track at a distance x from its start, in units.
func _height_at(x: float) -> float:
	for i in curve.point_count - 1:
		var from := curve.get_point_position(i)
		var to := curve.get_point_position(i + 1)
		if x >= from.x and x <= to.x:
			return lerpf(from.y, to.y, (x - from.x) / (to.x - from.x))
	return 0.0
