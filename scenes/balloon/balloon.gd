extends "res://scenes/level/wobble.gd"

## A party balloon on a string that bobs gently. Only for looks.

## Colour of the balloon.
@export var color: Color = Color(1, 0.4, 0.5)


func _ready() -> void:
	super._ready()
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	$Visual/Ball.material_override = material
