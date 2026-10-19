@tool
extends Node3D

## The diorama box that shows a level in the headset, like a toy theatre: a
## wooden base, two pillars and a beam at the front, and a painted sky at the
## back. Invisible "holdout" panels around it cut off any part of the level
## outside the box, so the real room shows there.
##
## The origin is the middle of the window on the plane where the cat moves
## (z = 0). Sizes are in level units; the rig makes 16 units 1 metre.

const HOLDOUT_SHADER := preload("res://scenes/xr/holdout.gdshader")
## Size of the holdout panels, big enough to cover the whole level.
const FAR := 400.0

## Width and height of the window, in units.
@export var window_size: Vector2 = Vector2(16, 9.5):
	set(value):
		window_size = value
		_update()
## How far behind the cat's plane the painted sky is, in units.
@export var back_depth: float = 20.0:
	set(value):
		back_depth = value
		_update()
## How far in front of the cat's plane the box ends, in units.
@export var front_depth: float = 4.5:
	set(value):
		front_depth = value
		_update()
@export var base_height: float = 1.2:
	set(value):
		base_height = value
		_update()
@export var wood_color: Color = Color(0.55, 0.38, 0.25):
	set(value):
		wood_color = value
		_update()
## Colour of the top of the base, behind and around the level's floor; the
## rig copies it from the level's floor.
@export var ground_color: Color = Color(0.36, 0.7, 0.33):
	set(value):
		ground_color = value
		_update()
## Colour of the painted sky at the back; the rig copies it from the level.
@export var sky_color: Color = Color(0.53, 0.81, 0.92):
	set(value):
		sky_color = value
		_update()
## On a computer screen there is no real room to show, so the holdouts are
## painted in this colour instead, which matches the background.
@export var preview: bool = false:
	set(value):
		preview = value
		_update()
@export var room_color: Color = Color(0.32, 0.31, 0.3):
	set(value):
		room_color = value
		_update()

var _wood := StandardMaterial3D.new()
var _ground := StandardMaterial3D.new()
var _sky := StandardMaterial3D.new()
var _holdout := ShaderMaterial.new()
var _room := StandardMaterial3D.new()
var _base := _add_mesh()
var _ground_top := _add_mesh()
var _pillar_left := _add_mesh()
var _pillar_right := _add_mesh()
var _beam := _add_mesh()
var _backdrop := _add_mesh()
var _holdouts: Array[MeshInstance3D] = []


func _init() -> void:
	_holdout.shader = HOLDOUT_SHADER
	# Fog belongs to the level (underwater), not to the box around it.
	for material in [_wood, _ground, _sky, _room]:
		material.disable_fog = true
	_holdout.render_priority = Material.RENDER_PRIORITY_MAX
	_sky.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_room.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_room.cull_mode = BaseMaterial3D.CULL_DISABLED
	for part in 8:
		_holdouts.append(_add_mesh())
	_update()


func _add_mesh() -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	add_child(mesh_instance, false, INTERNAL_MODE_FRONT)
	return mesh_instance


func _update() -> void:
	if _holdouts.size() < 8:
		return
	var half := window_size / 2.0
	var depth := back_depth + front_depth
	var middle_z := (front_depth - back_depth) / 2.0
	var bottom := -half.y - base_height
	_wood.albedo_color = wood_color
	_ground.albedo_color = ground_color
	_sky.albedo_color = sky_color
	_room.albedo_color = room_color

	_place(_base, Vector3(window_size.x, base_height, depth),
			Vector3(0, -half.y - base_height / 2.0, middle_z), _wood)
	# A thin layer of ground on the base, a hair below the level's floor.
	_place(_ground_top, Vector3(window_size.x - 0.02, 0.02, depth - 0.02),
			Vector3(0, -half.y - 0.005, middle_z), _ground)
	_place(_pillar_left, Vector3(0.3, window_size.y, 0.3),
			Vector3(-half.x + 0.15, 0, front_depth - 0.15), _wood)
	_place(_pillar_right, Vector3(0.3, window_size.y, 0.3),
			Vector3(half.x - 0.15, 0, front_depth - 0.15), _wood)
	_place(_beam, Vector3(window_size.x, 0.3, 0.3),
			Vector3(0, half.y - 0.15, front_depth - 0.15), _wood)
	_place(_backdrop, Vector3(window_size.x, window_size.y, 0.2),
			Vector3(0, 0, -back_depth), _sky)

	# A frame around the front opening of the box, then the four inner sides.
	var hole_middle := (half.y + bottom) / 2.0
	var cut: Material = _room if preview else _holdout
	_place(_holdouts[0], Vector3(FAR, FAR, 0.001), Vector3(-half.x - FAR / 2.0, 0, front_depth), cut)
	_place(_holdouts[1], Vector3(FAR, FAR, 0.001), Vector3(half.x + FAR / 2.0, 0, front_depth), cut)
	_place(_holdouts[2], Vector3(window_size.x, FAR, 0.001), Vector3(0, half.y + FAR / 2.0, front_depth), cut)
	_place(_holdouts[3], Vector3(window_size.x, FAR, 0.001), Vector3(0, bottom - FAR / 2.0, front_depth), cut)
	_place(_holdouts[4], Vector3(0.001, FAR, depth), Vector3(-half.x, hole_middle, middle_z), cut)
	_place(_holdouts[5], Vector3(0.001, FAR, depth), Vector3(half.x, hole_middle, middle_z), cut)
	_place(_holdouts[6], Vector3(window_size.x, 0.001, depth), Vector3(0, half.y, middle_z), cut)
	_place(_holdouts[7], Vector3(window_size.x, 0.001, depth), Vector3(0, bottom, middle_z), cut)
	for holdout in _holdouts:
		holdout.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _place(mesh_instance: MeshInstance3D, size: Vector3, at: Vector3, material: Material) -> void:
	var box: BoxMesh = mesh_instance.mesh
	box.size = size
	box.material = material
	mesh_instance.position = at
