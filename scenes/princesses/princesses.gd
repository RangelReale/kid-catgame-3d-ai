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
	if get_viewport().use_xr:
		_flash_headset()
		return
	var layer := CanvasLayer.new()
	layer.layer = 10
	var white := ColorRect.new()
	white.color = Color.WHITE
	white.set_anchors_preset(Control.PRESET_FULL_RECT)
	white.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(white)
	add_child(layer)
	create_tween().tween_property(white, "modulate:a", 0.0, flash_duration)


## A headset does not show 2D layers, so the flash is a small white ball
## around the player's head that fades away.
func _flash_headset() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color.WHITE
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.material = material
	var ball := MeshInstance3D.new()
	ball.mesh = sphere
	camera.add_child(ball)
	var tween := create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, flash_duration)
	tween.tween_callback(ball.queue_free)
