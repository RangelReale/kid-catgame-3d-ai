extends Node

## Turns the headset controllers into the game's actions, so the cat is played
## exactly as with a keyboard or a gamepad: either thumbstick walks left and
## right and swims down, and A or a trigger jumps. X jumps too, but when the
## cat swims or flies, X goes down instead, like a button for each way.

## How far the thumbstick must be pushed to count, like the dead zone of the
## actions in project.godot.
const DEAD_ZONE := 0.5
## Controller buttons, by their names in the OpenXR action map, that jump.
const JUMP_BUTTONS: Array[String] = ["trigger_click"]
## The A button on the right controller and the X button on the left one.
const FACE_BUTTON := "ax_button"

## Emitted when a jump button, A, X or a trigger goes down. The title and
## the ending listen to it, since pressed actions send no input events.
signal button_pressed

@export var controllers: Array[XRController3D] = []

## Actions this node is holding down, so it only lets go of its own and the
## keyboard still works at the same time.
var _held := {}
## True while any button of `button_pressed` is down.
var _any_button: bool = false


func _process(_delta: float) -> void:
	var stick := Vector2.ZERO
	var jump := false
	var x_button := false
	for controller in controllers:
		if controller == null or not controller.get_is_active():
			continue
		var push := controller.get_vector2("primary")
		if push.length() > stick.length():
			stick = push
		for button in JUMP_BUTTONS:
			if controller.is_button_pressed(button):
				jump = true
		if controller.is_button_pressed(FACE_BUTTON):
			if controller.tracker == &"left_hand":
				x_button = true
			else:
				jump = true
	var any_button := jump or x_button
	if any_button and not _any_button:
		button_pressed.emit()
	_any_button = any_button
	apply(stick, jump, x_button, _player_swims())


## Presses or lets go of the actions for a thumbstick position and the
## buttons. On the Quest thumbstick, down is positive y. When the cat swims or
## flies, the X button goes down; otherwise it jumps.
func apply(stick: Vector2, jump: bool, x_button: bool = false, swims: bool = false) -> void:
	_hold("move_left", stick.x < -DEAD_ZONE)
	_hold("move_right", stick.x > DEAD_ZONE)
	_hold("move_down", stick.y > DEAD_ZONE or (x_button and swims))
	_hold("jump", jump or (x_button and not swims))


## True when the cat of the current level is a mermaid or flies freely.
func _player_swims() -> bool:
	var player := get_tree().get_first_node_in_group("player") as Player
	return player != null and (player.mermaid or player.flying)


func _hold(action: String, down: bool) -> void:
	if down and not _held.get(action, false):
		Input.action_press(action)
		_held[action] = true
	elif not down and _held.get(action, false):
		Input.action_release(action)
		_held[action] = false
