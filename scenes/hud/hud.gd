extends CanvasLayer

## How see-through a touch button is while nobody touches it.
@export var idle_alpha: float = 0.6

@onready var _touch_buttons: Control = $TouchButtons


func _ready() -> void:
	# `godot --path . -- --touch` shows the buttons on a computer and lets the
	# mouse press them, to test them without a phone.
	if OS.get_cmdline_user_args().has("--touch"):
		Input.emulate_touch_from_mouse = true
	for node in _touch_buttons.find_children("*", "TouchScreenButton"):
		var button := node as TouchScreenButton
		var visual: Node2D = button.get_node("Visual")
		visual.modulate.a = idle_alpha
		button.pressed.connect(func() -> void: visual.modulate.a = 1.0)
		button.released.connect(func() -> void: visual.modulate.a = idle_alpha)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_visibility()


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_visibility()


## Shows the touch buttons only on a touch screen with no controller.
func _update_visibility() -> void:
	var has_touch := DisplayServer.is_touchscreen_available() \
			or Input.emulate_touch_from_mouse
	_touch_buttons.visible = has_touch and Input.get_connected_joypads().is_empty()
