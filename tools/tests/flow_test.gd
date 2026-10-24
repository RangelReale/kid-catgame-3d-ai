extends SceneTree

## Checks the way through the game: the title with levels playing by
## themselves, the first level after a button, and the credits after the last
## level. Run it with:
##   godot_console --headless --path . -s tools/tests/flow_test.gd
## It prints each check and quits with code 1 when any check fails.

const MainScene := preload("res://scenes/main.tscn")

var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_start_events()
	await _test_flow()
	# The audio server lets go of the sounds that were playing a moment later.
	for frame in 20:
		await process_frame
	print("FAILED: %d check(s)" % _failures if _failures > 0 else "ALL PASSED")
	quit(1 if _failures > 0 else 0)


## Keys that type something, Enter, a touch and a click start the game;
## special keys do not.
func _test_start_events() -> void:
	_check("a letter starts", TitleScreen.is_start_event(_key(KEY_A, 97)), null)
	_check("Enter starts", TitleScreen.is_start_event(_key(KEY_ENTER, 0)), null)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	_check("a touch starts", TitleScreen.is_start_event(touch), null)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_check("a click starts", TitleScreen.is_start_event(click), null)
	_check("Shift does not start", not TitleScreen.is_start_event(_key(KEY_SHIFT, 0)), null)
	_check("F5 does not start", not TitleScreen.is_start_event(_key(KEY_F5, 0)), null)
	_check("the volume key does not start",
			not TitleScreen.is_start_event(_key(KEY_VOLUMEUP, 0)), null)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	_check("the mouse wheel does not start", not TitleScreen.is_start_event(wheel), null)


func _test_flow() -> void:
	var sounds := AudioServer.get_bus_index("Sounds")
	var main := MainScene.instantiate()
	root.add_child(main)
	await _frames(5)
	var title: TitleScreen = main.get_node("TitleScreen")
	_check("the game opens on the title", title.visible and main._state == main.State.TITLE,
			main._state)
	_check("a level plays behind the title", main._level != null, main._level)
	_check("the game sounds are off on the title", AudioServer.is_bus_mute(sounds), null)
	_check("the cat walks by itself", Input.is_action_pressed("move_right"), null)

	title.press()
	await _frames(5)
	_check("a button starts the first level",
			main._state == main.State.PLAYING and main._level_index == 0, main._level_index)
	_check("the title hides", not title.visible, null)
	_check("the game sounds are on", not AudioServer.is_bus_mute(sounds), null)
	_check("the cat stops walking by itself", not Input.is_action_pressed("move_right"), null)

	main._load_level(main.levels.size() - 2)
	main._on_goal_reached()
	await _frames(5)
	_check("a flag goes to the next level", main._level_index == main.levels.size() - 1,
			main._level_index)

	var ending: CanvasLayer = main.get_node("Ending")
	main._on_goal_reached()
	await _frames(5)
	_check("the last flag shows the ending", ending.visible and main._state == main.State.ENDING,
			main._state)
	_check("the level stops", main._level.process_mode == Node.PROCESS_MODE_DISABLED, null)
	ending.press()
	_check("a button does nothing before the credits stop", ending.visible, null)
	await ending.credits_done
	ending.press()
	await _frames(5)
	_check("a button after the credits goes back to the title",
			title.visible and not ending.visible and main._state == main.State.TITLE, main._state)
	main.free()
	Input.action_release("move_right")
	Input.action_release("jump")


func _key(keycode: Key, unicode: int) -> InputEventKey:
	var key := InputEventKey.new()
	key.keycode = keycode
	key.unicode = unicode
	key.pressed = true
	return key


func _frames(count: int) -> void:
	for frame in count:
		await process_frame


func _check(name: String, ok: bool, value: Variant) -> void:
	print("%s  %s  (%s)" % ["PASS" if ok else "FAIL", name, value])
	if not ok:
		_failures += 1
