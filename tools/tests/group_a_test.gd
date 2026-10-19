extends SceneTree

## Checks the angry man and the bosses of levels 6, 7 and 15. Run it with:
##   godot_console --headless --path . -s tools/tests/group_a_test.gd
## It prints each check and quits with code 1 when any check fails.

const PlayerScene := preload("res://scenes/player/player.tscn")
const AngryManScene := preload("res://scenes/angry_man/angry_man.tscn")
const BigRatScene := preload("res://scenes/big_rat/big_rat.tscn")
const GiantMonsterScene := preload("res://scenes/giant_monster/giant_monster.tscn")
const GoalScene := preload("res://scenes/goal/goal.tscn")
const BlockScript := preload("res://scenes/level/block.gd")

var _failures: int = 0
var _world: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_angry_man()
	await _test_boss_beaten(BigRatScene, 3)
	await _test_boss_beaten(GiantMonsterScene, 5)
	await _test_side_touch()
	print("FAILED: %d check(s)" % _failures if _failures > 0 else "ALL PASSED")
	quit(1 if _failures > 0 else 0)


func _test_angry_man() -> void:
	var player := await _new_world()
	player.global_position = Vector3(3, 0, 0)
	var man := _add(AngryManScene.instantiate(), Vector3(0, 0, 0))
	var caught := [0]
	man.caught.connect(func() -> void: caught[0] += 1)
	await _wait(60)
	_check("the angry man waits before walking", caught[0] == 0 and man.global_position.x < 0.6,
			man.global_position.x)
	await _wait(120)
	_check("the angry man catches a cat that stands still", caught[0] == 1, caught[0])


## Drops the cat on a boss that does not walk. The cat bounces and lands on it
## again by itself, until the boss is beaten.
func _test_boss_beaten(scene: PackedScene, lives: int) -> void:
	var player := await _new_world()
	var goal := _add(GoalScene.instantiate(), Vector3(8, 0, 0))
	goal.locked = true
	# The goal hides itself in _ready, which already ran; hide it again as a
	# level would.
	goal.hide()
	goal.monitoring = false
	var boss := scene.instantiate()
	boss.speed = 0.0
	boss.goal = goal
	_add(boss, Vector3(0, 0, 0))
	player.global_position = Vector3(0, 3, 0)
	var lowest_health := lives
	for frame in 600:
		await physics_frame
		if not is_instance_valid(boss):
			lowest_health = 0
			break
		lowest_health = mini(lowest_health, boss.get_health())
		if lowest_health == 0:
			break
	_check("%d stomps beat the %s" % [lives, scene.resource_path.get_file()], lowest_health == 0,
			lowest_health)
	await _wait(2)
	_check("beating the %s shows the flag" % scene.resource_path.get_file(),
			goal.visible and goal.monitoring, goal.visible)


func _test_side_touch() -> void:
	var player := await _new_world()
	var rat := BigRatScene.instantiate()
	rat.speed = 0.0
	rat.respawn_position = Vector3(-6, 0, 0)
	_add(rat, Vector3(2, 0, 0))
	await _wait(2)
	rat._health = 1
	Input.action_press("move_right")
	var sent_back := false
	for frame in 90:
		await physics_frame
		if player.global_position.x < -5.0:
			sent_back = true
			break
	Input.action_release("move_right")
	_check("touching the rat from the side sends the cat back", sent_back,
			player.global_position.x)
	_check("touching the rat from the side gives it all its life back",
			rat.get_health() == 3, rat.get_health())


## Makes a fresh world with a floor and the cat standing at x 0.
func _new_world() -> Player:
	if _world != null:
		_world.queue_free()
		await process_frame
	_world = Node3D.new()
	root.add_child(_world)
	var floor := StaticBody3D.new()
	floor.set_script(BlockScript)
	floor.size = Vector3(40, 1, 4)
	_add(floor, Vector3(0, -0.5, 0))
	var player: Player = PlayerScene.instantiate()
	_add(player, Vector3(-3, 0, 0))
	await _wait(5)
	return player


func _add(node: Node3D, at: Vector3) -> Node3D:
	_world.add_child(node)
	node.global_position = at
	return node


func _wait(frames: int) -> void:
	for frame in frames:
		await physics_frame


func _check(name: String, ok: bool, value: Variant) -> void:
	print("%s  %s  (%s)" % ["PASS" if ok else "FAIL", name, value])
	if not ok:
		_failures += 1
