@tool
extends Block

## A desk with a computer. The cat can jump up through the desk top and
## stand on it.

## Colour of the picture on the computer screen.
@export var screen_color: Color = Color(0.3, 0.6, 1):
	set(value):
		screen_color = value
		_update_screen()


func _ready() -> void:
	_update_screen()


func _update_screen() -> void:
	var screen := get_node_or_null("Visual/Screen") as MeshInstance3D
	if screen == null:
		return
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = screen_color
	screen.material_override = material
