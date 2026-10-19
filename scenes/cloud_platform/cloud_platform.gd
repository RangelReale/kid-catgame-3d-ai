@tool
extends Block

## A cloud the cat can stand on. It is a Block that looks like a row of white
## puffs instead of a box; the puffs follow the block's width.

## Size of each puff, in units.
@export var puff_radius: float = 0.3

var _puffs := Node3D.new()


func _ready() -> void:
	show_mesh = false
	add_child(_puffs, false, INTERNAL_MODE_BACK)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 1)
	var mesh := SphereMesh.new()
	mesh.radius = puff_radius
	mesh.height = puff_radius * 2.0
	mesh.material = material
	var count := maxi(2, ceili(size.x / (puff_radius * 1.4)))
	var step := (size.x - puff_radius) / float(count - 1)
	for index in count:
		var puff := MeshInstance3D.new()
		puff.mesh = mesh
		var x := -size.x / 2.0 + puff_radius / 2.0 + step * index
		# Middle puffs are a little higher and bigger, like a real cloud.
		var middle := 1.0 - absf(float(index) / float(count - 1) * 2.0 - 1.0)
		puff.scale = Vector3(1.0, 0.7 + 0.3 * middle, 1.6) * (0.8 + 0.3 * middle)
		# The puff tops sit just above the top of the block, where the cat walks.
		var top := size.y / 2.0 + 0.04 * middle
		puff.position = Vector3(x, top - puff_radius * puff.scale.y, 0)
		_puffs.add_child(puff)
