class_name TitleScreen
extends CanvasLayer

## The game's name over levels that play by themselves, with a beeping tune.
## Any key or button starts the game.

## Emitted when someone presses any key or button, or touches the screen.
signal start_requested

## Seconds the "press a button" words take to fade out and back in.
@export var blink_duration: float = 1.2

## Actions whose keys count as a start, besides the keys that type something.
const START_ACTIONS: Array[StringName] = [&"jump", &"move_left", &"move_right", &"move_down"]

## Whether the brown picture and the words show on the screen. In the headset
## they do not, and the diorama shows its own 3D words; the tune still plays.
var overlay_visible: bool = true:
	set(value):
		overlay_visible = value
		if is_node_ready():
			_update_overlay()

@onready var _sepia: ColorRect = $Sepia
@onready var _visual: Control = $Visual
@onready var _press_label: Label = $Visual/Press
@onready var _music: AudioStreamPlayer = $Music


func _ready() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_press_label, "modulate:a", 0.2, blink_duration / 2.0)
	tween.tween_property(_press_label, "modulate:a", 1.0, blink_duration / 2.0)
	# The tune starts over each time it ends, while the title shows.
	_music.finished.connect(_music.play)
	visibility_changed.connect(_update_music)
	_update_music()
	_update_overlay()


func _update_music() -> void:
	if visible:
		_music.play()
	else:
		_music.stop()


## Lets go of the tune before the game closes, so it is not left in use.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_music):
			_music.stop()


func _update_overlay() -> void:
	_sepia.visible = overlay_visible
	_visual.visible = overlay_visible


func _unhandled_input(event: InputEvent) -> void:
	if visible and is_start_event(event):
		get_viewport().set_input_as_handled()
		press()


## Someone pressed a button: starts the game. The headset calls it for its
## controller buttons.
func press() -> void:
	if visible:
		start_requested.emit()


## True for a real press of a key, a controller button, the mouse or a finger.
## Special keys, like volume, media, Shift, Ctrl or the F keys, and the
## controller's home button do not count.
static func is_start_event(event: InputEvent) -> bool:
	if not event.is_pressed() or event.is_echo():
		return false
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.unicode != 0 or key.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			return true
		return START_ACTIONS.any(func(action: StringName) -> bool:
				return event.is_action(action, true))
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).button_index != JOY_BUTTON_GUIDE
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	return event is InputEventScreenTouch
