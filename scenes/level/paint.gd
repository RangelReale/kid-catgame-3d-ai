@tool
extends Node3D

## Paints some parts of a decoration with one colour, so one scene can come
## in many colours, like the leaves of a tree or a balloon.

## The colour of the painted parts.
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		_update()
## The MeshInstance3D nodes to paint.
@export var parts: Array[NodePath] = []:
	set(value):
		parts = value
		_update()

var _material := StandardMaterial3D.new()


func _ready() -> void:
	_update()


func _update() -> void:
	_material.albedo_color = color
	if not is_inside_tree():
		return
	for path in parts:
		var part := get_node_or_null(path) as MeshInstance3D
		if part != null:
			part.material_override = _material
