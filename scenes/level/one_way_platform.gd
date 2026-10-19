class_name OneWayPlatform
extends AnimatableBody3D

## A moving platform the cat can jump up through from below and stand on, like
## a ride seat. It works like a one-way block (see block.gd): the collision is
## on only when the cat's feet are at or above the top and the cat is not
## rising. The ride that owns it moves it in _physics_process, and the cat
## standing on it moves along.

## Height of the top of the platform, measured from this body's origin, in
## units.
@export var top: float = 0.0

## How far below the top the cat's feet can be and still land, in units.
const MARGIN := 0.15


func _init() -> void:
	# Decide before the ride and the cat move in this physics frame.
	process_physics_priority = -10


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	var solid := player.velocity.y <= 0.0 \
			and player.global_position.y >= global_position.y + top - MARGIN
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = not solid
