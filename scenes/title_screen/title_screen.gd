class_name TitleScreen
extends CanvasLayer

## The game's name over levels that play by themselves, with a beeping tune.
## Any key or button starts the game. Two flags in the top corner change the
## language, and so does the `change_language` action.

## Emitted when someone presses any key or button, or touches the screen.
signal start_requested

## Seconds the "press a button" words take to fade out and back in.
@export var blink_duration: float = 1.2

## Actions whose keys count as a start, besides the keys that type something.
const START_ACTIONS: Array[StringName] = [&"jump", &"move_left", &"move_right", &"move_down"]

## On the web, the browser mutes all sound until the first key or click.
static var _audio_unlocked: bool = not OS.has_feature("web")

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
@onready var _flags: Array[Node] = $Visual/Languages.get_children()


func _ready() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_press_label, "modulate:a", 0.2, blink_duration / 2.0)
	tween.tween_property(_press_label, "modulate:a", 1.0, blink_duration / 2.0)
	# The tune starts over each time it ends, while the title shows.
	_music.finished.connect(_music.play)
	visibility_changed.connect(_update_music)
	_update_music()
	_update_overlay()
	for flag: LanguageFlag in _flags:
		flag.pressed.connect(Language.choose.bind(flag.locale))
		flag.pressed.connect(_unlock_audio)
	_update_flags()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_update_flags()


func _update_flags() -> void:
	for flag: LanguageFlag in _flags:
		flag.selected = flag.locale == Language.current()


func _update_music() -> void:
	if visible:
		_music.play()
	else:
		_music.stop()


func _update_overlay() -> void:
	_sepia.visible = overlay_visible
	_visual.visible = overlay_visible


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("change_language"):
		get_viewport().set_input_as_handled()
		_unlock_audio()
		Language.choose_next()
		return
	if is_start_event(event) and not _is_on_flag(event):
		get_viewport().set_input_as_handled()
		press()


## True when a finger touches a language flag. The flag itself takes care of
## it, so the game does not start.
func _is_on_flag(event: InputEvent) -> bool:
	if not overlay_visible or not event is InputEventScreenTouch:
		return false
	var position := (event as InputEventScreenTouch).position
	return _flags.any(func(flag: Node) -> bool:
			return (flag as Control).get_global_rect().has_point(position))


## Someone pressed a button: starts the game. The headset calls it for its
## controller buttons. On the web, the first press only turns the tune on.
func press() -> void:
	if visible and not _unlock_audio():
		start_requested.emit()


## Starts the tune over the first time someone presses something on the web,
## because the browser kept it silent until then. Returns true when it did.
func _unlock_audio() -> bool:
	if _audio_unlocked:
		return false
	_audio_unlocked = true
	if visible:
		_music.play()
	return true


## True for a real press of a key, a controller button, the mouse or a finger.
## Special keys, like volume, media, Shift, Ctrl or the F keys, and the
## controller's home button do not count.
static func is_start_event(event: InputEvent) -> bool:
	if not event.is_pressed() or event.is_echo():
		return false
	if event.is_action(&"change_language"):
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
