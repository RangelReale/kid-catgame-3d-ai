extends Area3D

## Emitted once, a little after a princess picks up the cat. Works like
## reaching the flag: the next level starts.
signal reached

## Seconds the princess holds the cat before the next level.
@export var wait_after_pickup: float = 2.5
## When true, a white camera flash fills the screen when the cat is picked
## up, as if someone took a photo.
@export var photo_flash: bool = false
## Seconds the photo flash takes to fade away.
@export var flash_duration: float = 0.8

var _picked_up: bool = false

@onready var _held_cat: Node3D = $Visual/HeldCat


func _ready() -> void:
	add_to_group("goal")
	body_entered.connect(_on_body_entered)
	_held_cat.hide()


func _on_body_entered(body: Node3D) -> void:
	if body is Player and not _picked_up:
		_picked_up = true
		body.hide()
		body.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		_held_cat.show()
		if photo_flash:
			_flash()
		get_tree().create_timer(wait_after_pickup).timeout.connect(reached.emit)


## Covers the screen in white and fades it away, like a camera flash.
func _flash() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	var white := ColorRect.new()
	white.color = Color.WHITE
	white.set_anchors_preset(Control.PRESET_FULL_RECT)
	white.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(white)
	add_child(layer)
	create_tween().tween_property(white, "modulate:a", 0.0, flash_duration)
