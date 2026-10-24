class_name LanguageFlag
extends Control

## Emitted when someone clicks or touches the flag.
signal pressed

## The language this flag stands for: "pt_BR" shows Brazil's flag and "en"
## the flag of the United States.
@export var locale: String = "pt_BR"
## How see-through the flag is while its language is not in use.
@export var unselected_alpha: float = 0.45

var selected: bool = false:
	set(value):
		selected = value
		if _visual == null:
			return
		_visual.modulate.a = 1.0 if selected else unselected_alpha
		_visual.queue_redraw()

@onready var _visual: Control = $Visual


func _ready() -> void:
	_visual.draw.connect(_draw_flag)
	selected = selected


func _gui_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		pressed.emit()


func _draw_flag() -> void:
	var rect := Rect2(Vector2.ZERO, _visual.size)
	if locale == "pt_BR":
		_draw_brazil(rect)
	else:
		_draw_united_states(rect)
	if selected:
		_visual.draw_rect(rect.grow(1.0), Color.WHITE, false, 2.0)


func _draw_brazil(rect: Rect2) -> void:
	_visual.draw_rect(rect, Color(0.0, 0.61, 0.23))
	var center := rect.get_center()
	var half := rect.size * Vector2(0.42, 0.38)
	_visual.draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, -half.y), center + Vector2(half.x, 0),
			center + Vector2(0, half.y), center + Vector2(-half.x, 0)]),
			Color(1.0, 0.87, 0.0))
	_visual.draw_circle(center, rect.size.y * 0.22, Color(0.0, 0.15, 0.46))


func _draw_united_states(rect: Rect2) -> void:
	const STRIPES := 7
	var stripe_height := rect.size.y / STRIPES
	for index in STRIPES:
		var color := Color(0.75, 0.1, 0.2) if index % 2 == 0 else Color.WHITE
		_visual.draw_rect(Rect2(rect.position.x, rect.position.y + index * stripe_height,
				rect.size.x, stripe_height), color)
	var canton := Rect2(rect.position, Vector2(rect.size.x * 0.42, stripe_height * 4))
	_visual.draw_rect(canton, Color(0.2, 0.2, 0.45))
	# A few white dots stand for the stars.
	for row in 3:
		for column in 3:
			var dot := canton.position + canton.size * Vector2((column + 0.5) / 3.0, (row + 0.5) / 3.0)
			_visual.draw_circle(dot, 0.9, Color.WHITE)
