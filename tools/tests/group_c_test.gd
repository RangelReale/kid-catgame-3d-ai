extends SceneTree

## Checks the park pieces of levels 12 to 16: the trampoline, the rides that
## carry the cat, the princesses and the fish. Run it with:
##   godot_console --headless --path . -s tools/tests/group_c_test.gd
## It prints each check and quits with code 1 when any check fails.

const PlayerScene := preload("res://scenes/player/player.tscn")
const TrampolineScene := preload("res://scenes/trampoline/trampoline.tscn")
const DropTowerScene := preload("res://scenes/drop_tower/drop_tower.tscn")
const PrincessesScene := preload("res://scenes/princesses/princesses.tscn")
const FishScene := preload("res://scenes/fish/fish.tscn")
const BlockScript := preload("res://scenes/level/block.gd")
const OneWayPlatformScript := preload("res://scenes/level/one_way_platform.gd")

var _failures: int = 0
var _world: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_trampoline()
	await _test_moving_platform_carries()
	await _test_moving_platform_one_way()
	await _test_drop_tower_lifts()
	await _test_princesses()
	await _test_fish()
	print("FAILED: %d check(s)" % _failures if _failures > 0 else "ALL PASSED")
	quit(1 if _failures > 0 else 0)


func _test_trampoline() -> void:
	var player := await _new_world()
	var trampoline := _add(TrampolineScene.instantiate(), Vector3.ZERO)
	trampoline.bounce_speed = 15.0
	player.global_position = Vector3(0, 1.5, 0)
	var fastest := 0.0
	for frame in 40:
		await physics_frame
		fastest = maxf(fastest, player.velocity.y)
	_check("the trampoline bounces the cat at its speed", absf(fastest - 15.0) < 0.01, fastest)


func _test_moving_platform_carries() -> void:
	var player := await _new_world()
	var platform := _platform(Vector3(0, 1.0, 0))
	player.global_position = Vector3(0, 1.25, 0)
	await _wait(10)
	var start_x := player.global_position.x
	for frame in 60:
		platform.position.x += 0.05
		await physics_frame
	var moved := player.global_position.x - start_x
	_check("a cat standing on a moving one-way seat is carried along",
			absf(moved - 3.0) < 0.2 and player.global_position.y > 1.1, moved)


func _test_moving_platform_one_way() -> void:
	var player := await _new_world()
	_platform(Vector3(0, 1.0, 0))
	await _wait(2)
	await _press("jump")
	await _wait(60)
	_check("the cat jumps up through a moving one-way seat and lands on it",
			player.is_on_floor() and absf(player.global_position.y - 1.125) < 0.05,
			player.global_position.y)


func _test_drop_tower_lifts() -> void:
	var player := await _new_world()
	var tower := _add(DropTowerScene.instantiate(), Vector3.ZERO)
	player.global_position = Vector3(0, 0.8, 0)
	var highest := 0.0
	for frame in 360:
		await physics_frame
		highest = maxf(highest, player.global_position.y)
	_check("the drop tower lifts the cat to the top", highest > 5.75, highest)
	await _wait(180)
	_check("the drop tower brings the cat back down",
			player.global_position.y < 1.0 and tower != null, player.global_position.y)


func _test_princesses() -> void:
	var player := await _new_world()
	var princesses := _add(PrincessesScene.instantiate(), Vector3(2, 0, 0))
	princesses.wait_after_pickup = 0.5
	var reached_at := [-1]
	var frames := [0]
	princesses.reached.connect(func() -> void: reached_at[0] = frames[0])
	Input.action_press("move_right")
	var picked_at := -1
	for frame in 120:
		await physics_frame
		frames[0] = frame
		if picked_at < 0 and not player.visible:
			picked_at = frame
	Input.action_release("move_right")
	_check("touching the princesses picks up the cat", picked_at >= 0, picked_at)
	var waited: float = (reached_at[0] - picked_at) / 60.0
	_check("the princesses finish the level after the wait",
			reached_at[0] >= 0 and absf(waited - 0.5) < 0.1, waited)


func _test_fish() -> void:
	var player := await _new_world()
	var fish := _add(FishScene.instantiate(), Vector3(1.5, 0.25, 0))
	fish.speed = 0.0
	fish.respawn_time = 0.5
	Input.action_press("move_right")
	await _wait(30)
	Input.action_release("move_right")
	_check("touching a fish makes it jump away", not fish.get_node("Visual").visible, null)
	player.global_position = Vector3(-5, 0, 0)
	await _wait(40)
	_check("the fish comes back", fish.get_node("Visual").visible, null)


## Makes a fresh world with a floor and the cat standing at x 0.
func _new_world() -> Player:
	if _world != null:
		_world.queue_free()
		await process_frame
	_world = Node3D.new()
	root.add_child(_world)
	var floor_block := StaticBody3D.new()
	floor_block.set_script(BlockScript)
	floor_block.size = Vector3(40, 1, 4)
	_add(floor_block, Vector3(0, -0.5, 0))
	var player: Player = PlayerScene.instantiate()
	_add(player, Vector3.ZERO)
	await _wait(5)
	return player


## A one-way seat like the rides use, 2 units wide, with its top at y + 0.125.
func _platform(at: Vector3) -> AnimatableBody3D:
	var platform := AnimatableBody3D.new()
	platform.set_script(OneWayPlatformScript)
	platform.top = 0.125
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(2, 0.25, 1)
	platform.add_child(shape)
	_add(platform, at)
	return platform


func _add(node: Node3D, at: Vector3) -> Node3D:
	_world.add_child(node)
	node.global_position = at
	return node


## Presses an action like a quick tap and waits until the cat has seen it.
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
