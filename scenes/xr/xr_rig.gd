extends Node3D

## Shows the level as a diorama box in the headset. The box stays still in
## the room; the level slides through it so the cat stays near the middle,
## like the flat camera does on a screen.
##
## The rig's position is the middle of the box window on the plane where the
## cat moves. It follows what the level's own camera follows (the cat, or the
## airplane in level 11) and stops at that camera's limits.

## How fast the level slides to keep up with the cat; higher is faster.
@export var smoothing: float = 5.0
## Level units per real metre. 16 makes the 16-unit window 1 m wide.
@export var world_scale: float = 16.0
## When true, a normal camera stands where a head would be, to look at the
## diorama on a computer screen without a headset.
@export var preview: bool = false
## Where the box goes in front of the player: how far the head is from the
## cat's plane, in metres.
@export var head_distance: float = 0.9
## How far the head is above the base of the box, in metres. About right for
## a child sitting at a table.
@export var head_height: float = 0.45
## Seconds to hold a grip button to bring the box back in front of the head.
@export var recenter_hold: float = 1.0

## Where the sun and clouds go: just in front of the painted sky, smaller,
## so they fit in the box.
const SKY_OFFSET := Vector3(0, 1.8, -8.5)
const SKY_SCALE := 0.35

var _target: Node3D
var _limit_low := Vector2(-10000, -10000)
var _limit_high := Vector2(10000, 10000)

## True once the box has been put in front of the head in the headset.
var _placed: bool = false
var _grip_time: float = 0.0

## The 3D words of the title and the ending.
@onready var captions: Node3D = $Captions
## Turns the controllers into the game's actions.
@onready var controls: Node = $Input
@onready var _stage: Node3D = $Stage
@onready var _preview_camera: Camera3D = $PreviewCamera
@onready var _origin: XROrigin3D = $XROrigin3D
@onready var _xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var _hands: Array[XRController3D] = [$XROrigin3D/LeftHand, $XROrigin3D/RightHand]


func _ready() -> void:
	_stage.preview = preview
	_preview_camera.visible = preview
	if preview:
		_preview_camera.transform = _head_spot().looking_at(Vector3(0, -1, 0), Vector3.UP)
		_preview_camera.make_current()
		_origin.process_mode = Node.PROCESS_MODE_DISABLED
		return
	_origin.world_scale = world_scale
	_origin.current = true
	_xr_camera.make_current()
	var xr := XRServer.find_interface("OpenXR")
	if xr != null:
		# The player held the Meta button to recenter: move the box too.
		xr.pose_recentered.connect(func() -> void: _placed = false)


## Where the head should be, in the rig: in front of the box and a little
## above its base, looking straight ahead.
func _head_spot() -> Transform3D:
	var half: Vector2 = _stage.window_size / 2.0
	var base: float = -half.y - _stage.base_height
	return Transform3D(Basis(), Vector3(0, base + head_height * world_scale,
			head_distance * world_scale))


## Where to put the XR origin so the box is in front of a head that is at
## `head` in the origin's space. Only the head's turn to the sides counts;
## its tilt up or down does not.
func origin_for_head(head: Transform3D) -> Transform3D:
	var forward := -head.basis.z
	var turn := atan2(-forward.x, -forward.z)
	var flat_head := Transform3D(Basis(Vector3.UP, turn), head.origin)
	return _head_spot() * flat_head.affine_inverse()


## In the headset: puts the box in front of the head when tracking starts,
## and again when a grip button is held.
func _update_headset(delta: float) -> void:
	var gripping := false
	for hand in _hands:
		if hand.get_is_active() and hand.is_button_pressed("grip_click"):
			gripping = true
	_grip_time = _grip_time + delta if gripping else 0.0
	if _grip_time >= recenter_hold:
		_grip_time = -INF
		_placed = false
	if not _placed and _xr_camera.position != Vector3.ZERO:
		_origin.transform = origin_for_head(_xr_camera.transform)
		_placed = true


## Takes over a freshly loaded level: switches off its flat camera, reads
## what that camera followed and its limits, and moves the sky into the box.
func attach_level(level: Node) -> void:
	var camera := level.get_node_or_null("Camera") as Camera3D
	if camera != null:
		_target = camera.get("target")
		_limit_low = Vector2(camera.get("limit_left"), camera.get("limit_bottom"))
		_limit_high = Vector2(camera.get("limit_right"), camera.get("limit_top"))
		camera.current = false
		camera.process_mode = Node.PROCESS_MODE_DISABLED
	var sky := level.get_node_or_null("Sky")
	if sky != null and "anchor" in sky:
		sky.anchor = self
		sky.anchor_offset = SKY_OFFSET
		sky.anchor_scale = SKY_SCALE
	var environment := level.get_node_or_null("Environment")
	var floor_block := _find_floor(level)
	if floor_block != null:
		_stage.ground_color = floor_block.color
	if environment != null and "sky_color" in environment:
		_stage.sky_color = environment.sky_color
		environment.passthrough = true
		environment.passthrough_color = _stage.room_color if preview else Color(0, 0, 0, 0)
	if preview:
		_preview_camera.make_current()
	else:
		_xr_camera.make_current()
	_snap()


## The level's floor: the widest solid block. Its colour paints the ground
## of the box.
func _find_floor(level: Node) -> Block:
	var widest: Block = null
	for child in level.get_children():
		var block := child as Block
		if block != null and block.show_mesh and not block.one_way 				and (widest == null or block.size.x > widest.size.x):
			widest = block
	return widest


func _process(delta: float) -> void:
	if not preview:
		_update_headset(delta)
	if not is_instance_valid(_target):
		return
	var goal := focus_for(_target.global_position)
	var current := Vector2(global_position.x, global_position.y)
	var next := current.lerp(goal, 1.0 - exp(-smoothing * delta))
	global_position = Vector3(next.x, next.y, 0)


func _snap() -> void:
	if is_instance_valid(_target):
		var goal := focus_for(_target.global_position)
		global_position = Vector3(goal.x, goal.y, 0)


## The middle of the window for a target position: the target itself, moved
## so the window stays inside the limits. When the level is smaller than the
## window, the window stays in the middle of the level.
func focus_for(target_position: Vector3) -> Vector2:
	var half: Vector2 = _stage.window_size / 2.0
	var low := _limit_low + half
	var high := _limit_high - half
	var focus := Vector2(target_position.x, target_position.y)
	focus.x = clampf(focus.x, low.x, high.x) if low.x <= high.x else (low.x + high.x) / 2.0
	focus.y = clampf(focus.y, low.y, high.y) if low.y <= high.y else (low.y + high.y) / 2.0
	return focus
