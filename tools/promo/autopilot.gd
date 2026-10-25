extends SceneTree
## Plays the game by itself for the promo video. It shows a few seconds of
## many levels, one after the other: it loads each level, puts the cat (or
## the plane) at an interesting spot and plays from there.
## Prints what it does, so a run without recording shows if the plan works.
## See README.md next to this file.

const START_DELAY := 1.2  # seconds standing still under the title

## The clips, in order. "level" is the index in main.tscn, "seconds" is how
## long the clip lasts and "x" is where the cat starts, in units. "plane_x"
## moves the plane instead. "ride" puts the cat on a ride: on the leftmost
## child of that node, or on the node itself if it has no children, so the
## cat goes up. "mode" is how the cat plays: "walk" (the default), "swim",
## "fly" or "still".
const CLIPS: Array[Dictionary] = [
	{"level": 0, "seconds": 9.0, "show_off": true},
	{"level": 2, "seconds": 3.0, "x": 35.9},
	{"level": 3, "seconds": 3.5, "x": 7.8, "mode": "swim"},
	{"level": 6, "seconds": 3.5, "x": 29.7},
	{"level": 7, "seconds": 3.5, "x": 7.8, "mode": "fly"},
	{"level": 10, "seconds": 4.5, "plane_x": 82.8},
	{"level": 12, "seconds": 3.0, "x": 18.75},
	{"level": 14, "seconds": 4.0, "x": 20.3},
	{"level": 15, "seconds": 4.0, "ride": "FerrisWheel/Cabins"},
	{"level": 15, "seconds": 4.5, "ride": "RollerCoaster/Cart"},
	{"level": 0, "seconds": 4.0, "mode": "still"},  # under the end card
]

var _main: Node
var _tick := 0
var _clip := -1
var _clip_start_tick := 0
var _clip_end_tick := 0
var _jump_ticks: Array[int] = []  # ticks when "jump" gets pressed
var _release_tick := -1
var _last_level: Node
var _show_off_done := false
var _popped_seen := {}  # monsters already reported as popped


func _initialize() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)
	# Skip the title screen, as if someone pressed a button.
	# Deferred, because main.tscn is not ready yet.
	_main.call_deferred("_start_game")


func _level() -> Node:
	return _main.get("_level")


func _seconds() -> float:
	return _tick / 60.0


func _schedule_jump(delay_s: float) -> void:
	_jump_ticks.append(_tick + int(delay_s * 60.0))


func _clip_info() -> Dictionary:
	return CLIPS[_clip]


func _physics_process(_delta: float) -> bool:
	if _tick >= _clip_end_tick:
		_clip += 1
		if _clip >= CLIPS.size():
			print("%.2f end" % _seconds())
			return true
		_clip_end_tick = _tick + int(_clip_info().seconds * 60.0)
		if _clip > 0:
			_main._load_level(_clip_info().level)
	_tick += 1

	var level := _level()
	if level == null:  # the first level loads on the next frame
		return false
	if level != _last_level:
		_last_level = level
		_start_clip(level)

	var mode: String = _clip_info().get("mode", "still" if _clip_info().has("ride") else "walk")
	var player := level.get_node_or_null("Player") as CharacterBody3D
	# The rides place their seats on their first frames, so wait a little.
	if _clip_info().has("ride") and _tick == _clip_start_tick + 5:
		_get_on_ride(level, player)
	if player == null or mode == "still":
		return false

	if _tick == _release_tick:
		Input.action_release("jump")
	if _seconds() >= START_DELAY:
		Input.action_press("move_right")

	if mode == "swim":
		_swim()
	elif mode == "fly":
		_fly(level, player)
	elif player.is_on_floor() and _jump_ticks.is_empty() and _tick > _release_tick + 2:
		_plan(level, player)

	if _tick in _jump_ticks:
		_jump_ticks.erase(_tick)
		Input.action_release("jump")
		Input.action_press("jump")
		_release_tick = _tick + 2

	for monster in level.get_children():
		if monster.has_method("_pop") and monster.get("_popped") \
				and not _popped_seen.has(monster):
			_popped_seen[monster] = true
			print("%.2f POP %s" % [_seconds(), monster.name])
	return false


## Runs when a level starts, by a clip or because something caught the cat.
func _start_clip(level: Node) -> void:
	_jump_ticks.clear()
	for action in ["jump", "move_right", "move_down"]:
		Input.action_release(action)
	var info := _clip_info()
	var player := level.get_node_or_null("Player") as Node3D
	if player != null and info.has("x"):
		player.position.x = info.x
		_snap_camera(level)
	var plane := level.get_node_or_null("Airplane") as Node3D
	if plane != null and info.has("plane_x"):
		plane.position.x = info.plane_x
		_snap_camera(level)
	print("%.2f clip %d: %s" % [_seconds(), _clip, level.name])
	_clip_start_tick = _tick


## Puts the cat a little above the leftmost seat of the ride, so it lands on
## the seat and goes up with it.
func _get_on_ride(level: Node, player: Node3D) -> void:
	var ride := level.get_node(_clip_info().ride) as Node3D
	var seat := ride
	for child in ride.get_children():
		if child is PhysicsBody3D \
				and (seat == ride or child.global_position.x < seat.global_position.x):
			seat = child
	player.global_position = seat.global_position + Vector3(0.0, 0.94, 0.0)
	_snap_camera(level)
	print("%.2f ride %s" % [_seconds(), seat.name])


## After a jump to another spot, the camera would glide there in a fast
## scroll, so it jumps straight to the new spot instead.
func _snap_camera(level: Node) -> void:
	level.get_node("Camera").snap()


## Mermaid: swims up and down in waves.
func _swim() -> void:
	var up := int(_seconds() / 0.7) % 2 == 0
	if up:
		Input.action_release("move_down")
		Input.action_press("jump")
	else:
		Input.action_release("jump")
		Input.action_press("move_down")


## Flying: goes to the height that is farthest from the birds ahead.
func _fly(level: Node, player: CharacterBody3D) -> void:
	var best_y := player.position.y
	var best_room := -1.0
	for step in 14:  # below the titles
		var y := 0.25 + step * 0.3125
		var room := 1000.0
		for bird in level.get_children():
			if bird.is_in_group("catcher"):
				var dx: float = bird.position.x - player.position.x
				if dx > -0.94 and dx < 5.6:
					room = minf(room, absf(bird.position.y - y))
		# Prefer to stay near the current height when two heights are as good.
		room -= absf(y - player.position.y) * 0.05
		if room > best_room:
			best_room = room
			best_y = y
	Input.action_release("jump")
	Input.action_release("move_down")
	if best_y > player.position.y + 0.19:
		Input.action_press("jump")
	elif best_y < player.position.y - 0.19:
		Input.action_press("move_down")


func _plan(level: Node, player: CharacterBody3D) -> void:
	var x := player.position.x
	# Show off: one big triple flap in the first level, in open space.
	if _clip_info().get("show_off", false) and x > 9.4 and not _show_off_done:
		_show_off_done = true
		_schedule_jump(0.0)
		for i in 3:
			_schedule_jump(0.35 + 0.2 * i)
		print("%.2f show off at x=%.1f" % [_seconds(), x])
		return
	# Hop on a monster that is a little ahead. The big rat and the giant
	# monster have health instead of popping.
	for monster in level.get_children():
		var small: bool = monster.has_method("_pop") and not monster.get("_popped")
		var big: bool = monster.has_method("_hit") and not monster.get("_beaten")
		if small or big:
			var dx: float = monster.position.x - x
			var dir: float = monster.get("_direction")
			# Jump when the monster will be under the cat as it falls, about
			# 0.6 s after take-off.
			var closing_speed: float = player.get("speed") - monster.get("speed") * dir
			var lead := closing_speed * 0.6
			# The big ones are wide and can turn around, so any spot a little
			# short of the lead is fine.
			var slack := 0.94 if big else 0.19
			if dx > lead - slack and dx < lead + 0.19:
				_schedule_jump(0.0)
				print("%.2f hop at monster %s dx=%.2f" % [_seconds(), monster.name, dx])
				return
	# Blocked by a box: jump and flap over it.
	if _seconds() > START_DELAY + 0.3 and absf(player.velocity.x) < 0.03:
		_schedule_jump(0.0)
		_schedule_jump(0.3)
		print("%.2f over obstacle at x=%.1f" % [_seconds(), x])
