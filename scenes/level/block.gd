@tool
class_name Block
extends StaticBody3D

## A solid box of the level: the floor, a box, a step, a platform or an
## invisible wall. The position is the middle of the box.

## Width, height and depth, in units (1 unit is 32 pixels of the 2D game).
@export var size: Vector3 = Vector3(1, 1, 2):
	set(value):
		size = value
		_update()
## Colour of the box.
@export var color: Color = Color(0.8, 0.8, 0.8):
	set(value):
		color = value
		_update()
## When false, the box is invisible, like the walls at the level edges.
@export var show_mesh: bool = true:
	set(value):
		show_mesh = value
		_update()
## When true, the cat can jump up through the box from below and land on it.
@export var one_way: bool = false

## How far below the top the cat's feet can be and still land on a one-way
## box, in units. A falling cat moves up to about this much in one frame.
const ONE_WAY_MARGIN := 0.15

var _mesh_instance := MeshInstance3D.new()
var _shape := CollisionShape3D.new()


func _init() -> void:
	add_child(_mesh_instance, false, INTERNAL_MODE_FRONT)
	add_child(_shape, false, INTERNAL_MODE_FRONT)
	_mesh_instance.mesh = BoxMesh.new()
	_mesh_instance.mesh.material = StandardMaterial3D.new()
	_shape.shape = BoxShape3D.new()
	_update()
	# Run before the cat moves, so a one-way box is on or off in time.
	process_physics_priority = -10


func _update() -> void:
	_mesh_instance.mesh.size = size
	_mesh_instance.mesh.material.albedo_color = color
	_mesh_instance.visible = show_mesh
	_shape.shape.size = size


func _physics_process(_delta: float) -> void:
	if not one_way or Engine.is_editor_hint():
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	var top := global_position.y + size.y / 2.0
	var solid := player.velocity.y <= 0.0 \
			and player.global_position.y >= top - ONE_WAY_MARGIN
	_shape.disabled = not solid
