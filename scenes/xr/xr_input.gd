extends Node

## Turns the headset controllers into the game's actions, so the cat is played
## exactly as with a keyboard or a gamepad: either thumbstick walks left and
## right and swims down, and A or a trigger jumps. X jumps too, but when the
## cat swims or flies, X goes down instead, like a button for each way.
##
## A click of the right thumbstick turns the level mode on and off. In it,
## left and right on a thumbstick go to the previous and the next level, like
## the - and + keys, instead of walking.
##
## B or Y changes the language on the title, like the L key.

## How far the thumbstick must be pushed to count, like the dead zone of the
## actions in project.godot.
const DEAD_ZONE := 0.5
## Controller buttons, by their names in the OpenXR action map, that jump.
const JUMP_BUTTONS: Array[String] = ["trigger_click"]
## The A button on the right controller and the X button on the left one.
const FACE_BUTTON := "ax_button"
## The click of the thumbstick, pressed down like a button.
const STICK_CLICK := "primary_click"
## The B button on the right controller and the Y button on the left one.
const LANGUAGE_BUTTON := "by_button"

## Emitted when a jump button, A, X or a trigger goes down. The title and
## the ending listen to it, since pressed actions send no input events.
signal button_pressed
## Emitted when a click of the right thumbstick turns the level mode on or off.
signal level_mode_changed(on: bool)
## Emitted when B or Y goes down.
signal language_pressed

@export var controllers: Array[XRController3D] = []

## Actions this node is holding down, so it only lets go of its own and the
## keyboard still works at the same time.
var _held := {}
## True while any button of `button_pressed` is down.
var _any_button: bool = false
## True while the thumbstick changes levels instead of walking.
var level_mode: bool = false
## True while the right thumbstick is clicked down.
var _stick_click: bool = false
## Which way the thumbstick was pushed in level mode: -1, 0 or 1. One push
## changes one level; the stick must come back before the next one.
var _level_push: int = 0
## True while B or Y is down.
var _language_button: bool = false


func _process(_delta: float) -> void:
	var stick := Vector2.ZERO
	var jump := false
	var x_button := false
	var stick_click := false
	var language_button := false
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
		if controller.tracker == &"right_hand" and controller.is_button_pressed(STICK_CLICK):
			stick_click = true
		if controller.is_button_pressed(LANGUAGE_BUTTON):
			language_button = true
	if language_button and not _language_button:
		language_pressed.emit()
	_language_button = language_button
	if stick_click and not _stick_click:
		level_mode = not level_mode
		level_mode_changed.emit(level_mode)
	_stick_click = stick_click
	if level_mode:
		change_level(stick)
		stick = Vector2.ZERO
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


## In level mode: a push to the right goes to the next level, and a push to
## the left to the previous one.
func change_level(stick: Vector2) -> void:
	var push := 0
	if stick.x > DEAD_ZONE:
		push = 1
	elif stick.x < -DEAD_ZONE:
		push = -1
	if push != 0 and push != _level_push:
		_tap("go_to_next_level" if push > 0 else "go_to_previous_level")
	_level_push = push


## Sends a press and a release of an action as input events, so main sees
## them like the keys.
func _tap(action: String) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)


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
