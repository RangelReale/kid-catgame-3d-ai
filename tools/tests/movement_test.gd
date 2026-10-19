extends SceneTree

## Checks that the cat moves like in the 2D game, by pressing the actions in
## small test worlds. Run it with:
##   godot_console --headless --path . -s tools/tests/movement_test.gd
## It prints each check and quits with code 1 when any check fails.

const PlayerScene := preload("res://scenes/player/player.tscn")
const MonsterScene := preload("res://scenes/monster/monster.tscn")
const GoalScene := preload("res://scenes/goal/goal.tscn")
const BlockScript := preload("res://scenes/level/block.gd")

var _failures: int = 0
var _world: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_jump()
	await _test_flaps()
	await _test_stomp()
	await _test_side_touch()
	await _test_goal()
	await _test_one_way_platform()
	await _test_swim()
	print("FAILED: %d check(s)" % _failures if _failures > 0 else "ALL PASSED")
	quit(1 if _failures > 0 else 0)


func _test_jump() -> void:
	var player := await _new_world()
	await _press("jump")
	var apex := 0.0
	var apex_time := 0.0
	for frame in 60:
		await physics_frame
		if player.global_position.y > apex:
			apex = player.global_position.y
			apex_time = (frame + 1) / 60.0
	# 9.375 per second up, less 28.125 / 60 each frame: 52.5 px in the 2D game.
	_check("jump apex is about 1.64 units", absf(apex - 1.64) < 0.02, apex)
	_check("jump apex comes after about 0.33 s", absf(apex_time - 0.333) < 0.04, apex_time)
	_check("cat lands again", player.is_on_floor(), player.global_position.y)


func _test_flaps() -> void:
	var player := await _new_world()
	await _press("jump")
	await _wait(20)
	for flap in 3:
		await _press("jump")
		_check("flap %d sets the upward speed" % (flap + 1),
				player.velocity.y > 7.3 and player.velocity.y <= 7.8125, player.velocity.y)
		await _wait(10)
	var before := player.velocity.y
	await _press("jump")
	_check("a fourth flap does nothing", player.velocity.y < before, player.velocity.y)
	await _wait(120)
	_check("cat lands after flapping", player.is_on_floor(), player.global_position.y)
	await _press("jump")
	_check("landing gives the jump back", player.velocity.y > 9.0, player.velocity.y)


func _test_stomp() -> void:
	var player := await _new_world()
	var monster := _add(MonsterScene.instantiate(), Vector3(0, 0, 0))
	monster.speed = 0.0
	player.global_position = Vector3(0, 1.5, 0)
	var bounced := false
	for frame in 60:
		await physics_frame
		if player.velocity.y > 6.0:
			bounced = true
	_check("landing on a monster bounces the cat", bounced, player.velocity.y)
	_check("landing on a monster pops it", not is_instance_valid(monster) \
			or not monster.get_node("Visual").visible, null)


func _test_side_touch() -> void:
	var player := await _new_world()
	var monster := _add(MonsterScene.instantiate(), Vector3(2, 0, 0))
	monster.speed = 0.0
	Input.action_press("move_right")
	await _wait(60)
	Input.action_release("move_right")
	_check("touching a monster from the side does not pop it",
			monster.get_node("Visual").visible, player.global_position.x)


func _test_goal() -> void:
	var player := await _new_world()
	var goal := _add(GoalScene.instantiate(), Vector3(2, 0, 0))
	var reached := [false]
	goal.reached.connect(func() -> void: reached[0] = true)
	Input.action_press("move_right")
	await _wait(60)
	Input.action_release("move_right")
	_check("touching the flag finishes the level", reached[0], player.global_position.x)


func _test_one_way_platform() -> void:
	var player := await _new_world()
	var platform := _block(Vector3(0, 1.0625, 0), Vector3(2.5, 0.25, 1.5))
	platform.one_way = true
	await _wait(2)
	await _press("jump")
	await _wait(60)
	_check("the cat jumps up through a one-way platform and stands on it",
			player.is_on_floor() and absf(player.global_position.y - 1.1875) < 0.05,
			player.global_position.y)


func _test_swim() -> void:
	var player := await _new_world(true)
	player.global_position = Vector3(0, 2, 0)
	await _wait(30)
	_check("the mermaid floats in place", absf(player.global_position.y - 2.0) < 0.01,
			player.global_position.y)
	Input.action_press("jump")
	await _wait(30)
	Input.action_release("jump")
	_check("jump makes the mermaid swim up at full speed",
			absf(player.velocity.y - 4.0625) < 0.01, player.velocity.y)
	Input.action_press("move_down")
	await _wait(30)
	Input.action_release("move_down")
	_check("move_down makes the mermaid swim down", player.velocity.y < -4.0, player.velocity.y)


## Makes a fresh world with a floor and the cat standing at x 0.
func _new_world(mermaid: bool = false) -> Player:
	if _world != null:
		_world.queue_free()
		await process_frame
	_world = Node3D.new()
	root.add_child(_world)
	_block(Vector3(0, -0.5, 0), Vector3(40, 1, 4))
	var player: Player = PlayerScene.instantiate()
	player.mermaid = mermaid
	_add(player, Vector3.ZERO)
	await _wait(5)
	return player


func _add(node: Node3D, at: Vector3) -> Node3D:
	_world.add_child(node)
	node.global_position = at
	return node


func _block(at: Vector3, size: Vector3) -> StaticBody3D:
	var block := StaticBody3D.new()
	block.set_script(BlockScript)
	block.size = size
	_add(block, at)
	return block


## Presses an action like a quick tap and waits until the cat has seen it.
## The cat sees the press on the next physics frame, so its speed has had at
## most one frame of gravity when this returns.
func _press(action: String) -> void:
	Input.action_press(action)
	await physics_frame
	await physics_frame
	Input.action_release(action)


func _wait(frames: int) -> void:
	for frame in frames:
		await physics_frame


func _check(name: String, ok: bool, value: Variant) -> void:
	print("%s  %s  (%s)" % ["PASS" if ok else "FAIL", name, value])
	if not ok:
		_failures += 1
