extends SceneTree

## Checks the pieces of levels 8 to 11: birds, suitcases, cloud platforms and
## the airplane. Run it with:
##   godot_console --headless --path . -s tools/tests/group_b_test.gd
## It prints each check and quits with code 1 when any check fails.

const PlayerScene := preload("res://scenes/player/player.tscn")
const BirdScene := preload("res://scenes/bird/bird.tscn")
const SuitcaseScene := preload("res://scenes/suitcase/suitcase.tscn")
const AirplaneScene := preload("res://scenes/airplane/airplane.tscn")
const BlockScript := preload("res://scenes/level/block.gd")
const CloudPlatformScript := preload("res://scenes/cloud_platform/cloud_platform.gd")

var _failures: int = 0
var _world: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_bird()
	await _test_bird_moves()
	await _test_suitcase()
	await _test_cloud_step()
	await _test_airplane()
	print("FAILED: %d check(s)" % _failures if _failures > 0 else "ALL PASSED")
	quit(1 if _failures > 0 else 0)


func _test_bird() -> void:
	var player := await _new_world()
	var bird := BirdScene.instantiate()
	bird.travel = Vector3.ZERO
	var caught := [0]
	bird.caught.connect(func() -> void: caught[0] += 1)
	_add(bird, Vector3(2, 0.25, 0))
	Input.action_press("move_right")
	await _wait(60)
	Input.action_release("move_right")
	_check("a bird touching the cat catches it once", caught[0] == 1, caught[0])
	_check("birds are catchers", bird.is_in_group("catcher"), null)


func _test_bird_moves() -> void:
	await _new_world()
	var bird := BirdScene.instantiate()
	bird.travel = Vector3(0, 2, 0)
	bird.trips_per_second = 0.25
	# The bird remembers where it starts when it enters the world.
	bird.position = Vector3(-10, 3, 0)
	_world.add_child(bird)
	# A quarter of a trip after the start, the bird is at the top.
	await _wait(60)
	_check("a bird flies up and down along its travel",
			absf(bird.position.y - 5.0) < 0.05, bird.position.y)


func _test_suitcase() -> void:
	var player := await _new_world()
	var suitcase := SuitcaseScene.instantiate()
	var caught := [0]
	suitcase.caught.connect(func() -> void: caught[0] += 1)
	_add(suitcase, Vector3(2, 0, 0))
	Input.action_press("move_right")
	await _wait(60)
	Input.action_release("move_right")
	_check("bumping a suitcase catches the cat once", caught[0] == 1, caught[0])


func _test_cloud_step() -> void:
	var player := await _new_world()
	var cloud := StaticBody3D.new()
	cloud.set_script(CloudPlatformScript)
	cloud.size = Vector3(2.5, 0.25, 1.5)
	cloud.one_way = true
	_add(cloud, Vector3(0, 2, 0))
	player.global_position = Vector3(0, 4, 0)
	await _wait(60)
	_check("the cat lands on a cloud step from above",
			player.is_on_floor() and absf(player.global_position.y - 2.125) < 0.05,
			player.global_position.y)


func _test_airplane() -> void:
	await _new_world()
	var airplane := AirplaneScene.instantiate()
	var man := Node3D.new()
	_world.add_child(man)
	airplane.show_on_landing = man
	# Faster than in the game, so the test does not take half a minute.
	airplane.speed = 40.0
	airplane.wait_after_landing = 0.5
	var reached := [0]
	airplane.reached.connect(func() -> void: reached[0] += 1)
	_add(airplane, Vector3(3.75, 0, 0))
	_check("the person waiting is hidden at the start", not man.visible, null)
	var highest := 0.0
	for frame in 600:
		await process_frame
		highest = maxf(highest, airplane.position.y)
		if reached[0] > 0:
			break
	_check("the plane flies at cruise height", absf(highest - 4.0625) < 0.05, highest)
	_check("the plane stops on the runway", absf(airplane.position.x - 96.875) < 0.001 \
			and absf(airplane.position.y) < 0.001 and airplane.rotation.z == 0.0,
			airplane.position)
	_check("the person shows up when the plane stops", man.visible, null)
	_check("the cat leaves the window", not airplane.get_node("Visual/Window3/Cat").visible, null)
	_check("the plane finishes the level once", reached[0] == 1, reached[0])
	_check("the plane works like a flag", airplane.is_in_group("goal"), null)


## Makes a fresh world with a floor and the cat standing at x 0.
func _new_world() -> Player:
	if _world != null:
		_world.queue_free()
		await process_frame
	_world = Node3D.new()
	root.add_child(_world)
	_block(Vector3(0, -0.5, 0), Vector3(40, 1, 4))
	var player: Player = PlayerScene.instantiate()
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


func _wait(frames: int) -> void:
	for frame in frames:
		await physics_frame


func _check(name: String, ok: bool, value: Variant) -> void:
	print("%s  %s  (%s)" % ["PASS" if ok else "FAIL", name, value])
	if not ok:
		_failures += 1
