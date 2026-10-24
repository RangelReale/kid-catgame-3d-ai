extends SceneTree

## Checks the diorama rig of the headset version, using its computer-screen
## preview, so no headset is needed. Run it with:
##   godot_console --headless --path . -s tools/tests/xr_test.gd
## It prints each check and quits with code 1 when any check fails.

const RigScene := preload("res://scenes/xr/xr_rig.tscn")
const MainScene := preload("res://scenes/main.tscn")
const CameraScript := preload("res://scenes/camera/follow_camera.gd")

var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_window_limits()
	await _test_level_takeover(9, "Player")
	await _test_level_takeover(11, "Airplane")
	await _test_controllers()
	await _test_box_placement()
	await _test_captions()
	await _test_level_mode()
	# The audio server lets go of the sounds that were playing a moment later.
	for frame in 20:
		await process_frame
	print("FAILED: %d check(s)" % _failures if _failures > 0 else "ALL PASSED")
	quit(1 if _failures > 0 else 0)


## The window follows the target but never shows past the level's limits.
func _test_window_limits() -> void:
	var rig := RigScene.instantiate()
	rig.preview = true
	root.add_child(rig)
	var level := _fake_level(Rect2(0, -1, 60, 10001))
	root.add_child(level)
	rig.attach_level(level)
	_check("the window follows the cat in the middle of a level",
			rig.focus_for(Vector3(30, 1, 0)).is_equal_approx(Vector2(30, 3.75)),
			rig.focus_for(Vector3(30, 1, 0)))
	_check("the window stops at the left edge",
			rig.focus_for(Vector3(2, 0, 0)).is_equal_approx(Vector2(8, 3.75)),
			rig.focus_for(Vector3(2, 0, 0)))
	_check("the window stops at the right edge",
			rig.focus_for(Vector3(59, 0, 0)).is_equal_approx(Vector2(52, 3.75)),
			rig.focus_for(Vector3(59, 0, 0)))
	level.free()
	level = _fake_level(Rect2(0, -1, 10, 10001))
	root.add_child(level)
	rig.attach_level(level)
	_check("a level narrower than the window stays in the middle",
			is_equal_approx(rig.focus_for(Vector3(1, 0, 0)).x, 5.0),
			rig.focus_for(Vector3(1, 0, 0)))
	level.free()
	level = _fake_level(Rect2(0, -1, 15, 33.75))
	root.add_child(level)
	rig.attach_level(level)
	_check("the window stops at the top of a tall level",
			is_equal_approx(rig.focus_for(Vector3(7, 31, 0)).y, 28.0),
			rig.focus_for(Vector3(7, 31, 0)))
	level.free()
	rig.free()
	await process_frame


## Loads a real level in the preview and checks that the rig took it over.
func _test_level_takeover(number: int, target_name: String) -> void:
	var main := MainScene.instantiate()
	main.xr_preview = true
	main.show_title = false
	root.add_child(main)
	main._load_level(number - 1)
	for frame in 10:
		await process_frame
	var level: Node = main._level
	var rig: Node3D = main.get_node("XRRig")
	var camera: Camera3D = level.get_node("Camera")
	var prefix := "level %d: " % number
	_check(prefix + "the flat camera is switched off",
			not camera.current and camera.process_mode == Node.PROCESS_MODE_DISABLED, camera.current)
	_check(prefix + "the preview camera shows the diorama",
			rig.get_node("PreviewCamera").current, null)
	_check(prefix + "the window follows the " + target_name,
			rig._target == level.get_node(target_name), rig._target)
	var target: Node3D = level.get_node(target_name)
	var goal: Vector2 = rig.focus_for(target.global_position)
	_check(prefix + "the window is where it should be",
			Vector2(rig.global_position.x, rig.global_position.y).distance_to(goal) < 0.5,
			[rig.global_position, goal])
	var sky := level.get_node_or_null("Sky")
	if sky != null:
		_check(prefix + "the sky sits in the box", sky.anchor == rig, sky.anchor)
	var environment := level.get_node("Environment")
	_check(prefix + "the background is the room, not the sky",
			environment.passthrough, environment.passthrough)
	main.queue_free()
	await process_frame


## The thumbstick and buttons press the same actions as the keyboard.
func _test_controllers() -> void:
	var input: Node = load("res://scenes/xr/xr_input.gd").new()
	root.add_child(input)
	input.apply(Vector2(-0.9, 0), false)
	_check("thumbstick left walks left",
			Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"), null)
	input.apply(Vector2(0.3, 0), false)
	_check("a small push does nothing",
			not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"), null)
	input.apply(Vector2(0.8, 0.8), true)
	_check("thumbstick right and down, with a button, walks right, swims down and jumps",
			Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down")
			and Input.is_action_pressed("jump"), null)
	input.apply(Vector2.ZERO, false)
	_check("letting go releases every action",
			not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_down")
			and not Input.is_action_pressed("jump"), null)
	input.apply(Vector2.ZERO, false, true, false)
	_check("X jumps when the cat walks",
			Input.is_action_pressed("jump") and not Input.is_action_pressed("move_down"), null)
	input.apply(Vector2.ZERO, false, true, true)
	_check("X goes down when the cat swims or flies",
			Input.is_action_pressed("move_down") and not Input.is_action_pressed("jump"), null)
	input.apply(Vector2.ZERO, false)
	input.free()
	await process_frame



## In the headset, the title and the ending show as 3D words in the box, and
## the controller buttons press them.
func _test_captions() -> void:
	var main := MainScene.instantiate()
	main.xr_preview = true
	root.add_child(main)
	await process_frame
	var captions: Node3D = main.get_node("XRRig/Captions")
	var title: TitleScreen = main.get_node("TitleScreen")
	_check("the flat title words are hidden", not title.get_node("Visual").visible, null)
	_check("the box shows the 3D title", captions.get_node("Visual/Title").visible, null)
	main.get_node("XRRig/Input").button_pressed.emit()
	await process_frame
	_check("a controller button starts the game", main._state == main.State.PLAYING, main._state)
	_check("the 3D title hides", not captions.get_node("Visual/Title").visible, null)
	main._load_level(main.levels.size() - 1)
	main._on_goal_reached()
	await process_frame
	_check("the box shows the 3D ending", captions.get_node("Visual/Ending").visible, null)
	_check("the flat ending words are hidden",
			not main.get_node("Ending/Visual").visible, null)
	main.queue_free()
	await process_frame
	Input.action_release("move_right")
	Input.action_release("jump")


## In level mode, a push of the thumbstick changes the level once.
func _test_level_mode() -> void:
	var main := MainScene.instantiate()
	main.xr_preview = true
	main.show_title = false
	root.add_child(main)
	await process_frame
	var input: Node = main.get_node("XRRig/Input")
	var label: Label3D = main.get_node("XRRig/Captions/Visual/LevelMode")
	# No controller is there to read: the test pushes the thumbstick itself.
	input.process_mode = Node.PROCESS_MODE_DISABLED
	input.level_mode = true
	input.level_mode_changed.emit(true)
	_check("the box shows the level mode", label.visible and label.text.contains(tr("LEVEL") % 1),
			label.text)
	input.change_level(Vector2(0.9, 0))
	await _frames(3)
	_check("right goes to the next level", main._level_index == 1, main._level_index)
	_check("the level mode shows the new level", label.text.contains(tr("LEVEL") % 2), label.text)
	input.change_level(Vector2(0.9, 0))
	await _frames(3)
	_check("holding the push does not skip more levels", main._level_index == 1,
			main._level_index)
	input.change_level(Vector2.ZERO)
	input.change_level(Vector2(-0.9, 0))
	await _frames(3)
	_check("left goes back a level", main._level_index == 0, main._level_index)
	input.level_mode = false
	input.level_mode_changed.emit(false)
	_check("the level mode hides when it turns off", not label.visible, null)
	input.change_level(Vector2.ZERO)
	main.queue_free()
	await process_frame


func _frames(count: int) -> void:
	for frame in count:
		await process_frame

## Wherever the head is when the game starts, the box ends up in front of it.
func _test_box_placement() -> void:
	var rig := RigScene.instantiate()
	rig.preview = true
	root.add_child(rig)
	var head := Transform3D(Basis(Vector3.UP, deg_to_rad(70)).rotated(Vector3.RIGHT, -0.3),
			Vector3(5, 18, -3))
	var head_in_rig: Transform3D = rig.origin_for_head(head) * head
	var spot: Transform3D = rig._head_spot()
	_check("the head ends up at the spot in front of the box",
			head_in_rig.origin.is_equal_approx(spot.origin), head_in_rig.origin)
	var forward := -head_in_rig.basis.z
	_check("the head faces the box",
			absf(forward.x) < 0.001 and forward.z < 0.0, forward)
	rig.free()
	await process_frame


## A level with only a camera that follows a cat-shaped node.
func _fake_level(limits: Rect2) -> Node3D:
	var level := Node3D.new()
	var target := Node3D.new()
	target.name = "Player"
	level.add_child(target)
	var camera := Camera3D.new()
	camera.name = "Camera"
	camera.set_script(CameraScript)
	camera.target = target
	camera.limit_left = limits.position.x
	camera.limit_bottom = limits.position.y
	camera.limit_right = limits.end.x
	camera.limit_top = limits.end.y
	level.add_child(camera)
	return level


func _check(name: String, ok: bool, value: Variant) -> void:
	print("%s  %s  (%s)" % ["PASS" if ok else "FAIL", name, value])
	if not ok:
		_failures += 1
