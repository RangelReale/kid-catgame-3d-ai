extends Node

## Turns the headset controllers into the game's actions, so the cat is played
## exactly as with a keyboard or a gamepad: either thumbstick walks left and
## right and swims down, and A, X or a trigger jumps.

## How far the thumbstick must be pushed to count, like the dead zone of the
## actions in project.godot.
const DEAD_ZONE := 0.5
## Controller buttons, by their names in the OpenXR action map, that jump.
const JUMP_BUTTONS: Array[String] = ["ax_button", "trigger_click"]

@export var controllers: Array[XRController3D] = []

## Actions this node is holding down, so it only lets go of its own and the
## keyboard still works at the same time.
var _held := {}


func _process(_delta: float) -> void:
	var stick := Vector2.ZERO
	var jump := false
	for controller in controllers:
		if controller == null or not controller.get_is_active():
			continue
		var push := controller.get_vector2("primary")
		if push.length() > stick.length():
			stick = push
		for button in JUMP_BUTTONS:
			if controller.is_button_pressed(button):
				jump = true
	apply(stick, jump)


## Presses or lets go of the actions for a thumbstick position and the jump
## buttons. On a thumbstick, up is positive y.
func apply(stick: Vector2, jump: bool) -> void:
	_hold("move_left", stick.x < -DEAD_ZONE)
	_hold("move_right", stick.x > DEAD_ZONE)
	_hold("move_down", stick.y < -DEAD_ZONE)
	_hold("jump", jump)


func _hold(action: String, down: bool) -> void:
	if down and not _held.get(action, false):
		Input.action_press(action)
		_held[action] = true
	elif not down and _held.get(action, false):
		Input.action_release(action)
		_held[action] = false
