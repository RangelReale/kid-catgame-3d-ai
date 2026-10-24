extends Node3D

## The words of the title and the ending, in 3D inside the diorama box. In the
## headset, the flat words of the screen do not show, so these take their
## place. The origin is the middle of the box window, like the rig's.
##
## Each group of words sits on a wooden board. In the headset, the room shows
## through wherever nothing solid is behind the words, which hid them there.

## Seconds the "press a button" words take to fade out and back in.
@export var blink_duration: float = 1.2
## Height where the credits start, at the bottom of the window, in units.
@export var credits_start_y: float = -4.0
## Height where the credits stop, just below "you won", in units.
@export var credits_end_y: float = 1.2

var _blink_tween: Tween
var _ending_tween: Tween

@onready var _title: Node3D = $Visual/Title
@onready var _press_start: Label3D = $Visual/Title/Press
@onready var _ending: Node3D = $Visual/Ending
@onready var _won: Label3D = $Visual/Ending/Won
@onready var _credits: Node3D = $Visual/Ending/Credits
@onready var _press_back: Label3D = $Visual/Ending/Press


func _ready() -> void:
	hide_all()


## Shows "Jogo do gato" and blinks "press a button to start".
func show_title() -> void:
	hide_all()
	_title.show()
	_blink(_press_start)


## Shows "you won" after the picture would turn brown, then raises the
## credits. The timing matches the screen ending.
func play_ending(wait: float, scroll_duration: float) -> void:
	hide_all()
	_ending.show()
	_won.transparency = 1.0
	_press_back.hide()
	_credits.position.y = credits_start_y
	_ending_tween = create_tween()
	_ending_tween.tween_interval(wait)
	_ending_tween.tween_property(_won, "transparency", 0.0, 0.5)
	_ending_tween.tween_property(_credits, "position:y", credits_end_y, scroll_duration)


## Blinks "press a button to go back" under the credits.
func show_press_back() -> void:
	_press_back.show()
	_blink(_press_back)


func hide_all() -> void:
	for tween in [_blink_tween, _ending_tween]:
		if tween != null:
			tween.kill()
	_title.hide()
	_ending.hide()


func _blink(label: Label3D) -> void:
	label.transparency = 0.0
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(label, "transparency", 0.8, blink_duration / 2.0)
	_blink_tween.tween_property(label, "transparency", 0.0, blink_duration / 2.0)
