extends Node

## Emitted after a level is loaded and added, so the diorama rig of the
## headset can take it over.
signal level_loaded(level: Node)

## TITLE shows the game's name over levels that play by themselves, PLAYING is
## the real game and ENDING shows "you won" and the credits.
enum State { TITLE, PLAYING, ENDING }

## The levels, in the order they are played. After the last one, the ending
## shows up.
@export var levels: Array[PackedScene] = []
## The levels that play by themselves behind the title, as positions in
## `levels`: 0 is the first level.
@export var demo_levels: Array[int] = []
## Seconds each level plays behind the title before the next one.
@export var demo_duration: float = 8.0
## Seconds between the jumps of the cat behind the title.
@export var demo_jump_interval: float = 1.0
## Starts with the title. The tests turn it off, and so does `--level`.
@export var show_title: bool = true
## Shows the level as a diorama box, like in the headset, on a computer
## screen. `godot --path . -- --xr-preview` turns it on too.
@export var xr_preview: bool = false

var _state: State = State.TITLE
var _level_index: int = 0
var _level: Node
var _demo_index: int = 0
var _demo_time: float = 0.0
var _demo_jump_time: float = 0.0

@onready var _hud: CanvasLayer = $HUD
@onready var _title_screen: TitleScreen = $TitleScreen
@onready var _ending: CanvasLayer = $Ending


## The game opens on the title. `godot --path . -- --level 3` skips it and
## starts at the third level, to test it quickly.
func _ready() -> void:
	_title_screen.start_requested.connect(_start_game)
	_ending.finished.connect(_show_title)
	var args := OS.get_cmdline_user_args()
	if _start_headset():
		_add_xr_rig(false)
	elif xr_preview or args.has("--xr-preview"):
		_add_xr_rig(true)
	if levels.is_empty():
		return
	var start := 0
	var level_arg := args.find("--level")
	if level_arg >= 0 and level_arg + 1 < args.size():
		start = clampi(args[level_arg + 1].to_int() - 1, 0, levels.size() - 1)
		show_title = false
	if show_title:
		_show_title()
	else:
		_title_screen.hide()
		_state = State.PLAYING
		_load_level(start)


func _physics_process(delta: float) -> void:
	if _state != State.TITLE:
		return
	# Behind the title, the cat walks right and jumps now and then, as if
	# someone were playing.
	Input.action_press("move_right")
	if Input.is_action_pressed("jump"):
		Input.action_release("jump")
	_demo_jump_time += delta
	if _demo_jump_time >= demo_jump_interval:
		_demo_jump_time = 0.0
		Input.action_press("jump")
	_demo_time += delta
	if _demo_time >= demo_duration:
		_next_demo_level()


## Shows the title, with the levels playing by themselves in the back.
func _show_title() -> void:
	_state = State.TITLE
	_hud.hide()
	_title_screen.show()
	# The cat's "boing" would play by itself, so the game sounds stay off.
	# The title music plays on another bus.
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), true)
	_demo_index = -1
	_next_demo_level()


func _next_demo_level() -> void:
	if demo_levels.is_empty():
		return
	_demo_index = (_demo_index + 1) % demo_levels.size()
	_demo_time = 0.0
	_demo_jump_time = 0.0
	_load_level.call_deferred(demo_levels[_demo_index])


func _start_game() -> void:
	_release_demo_actions()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Sounds"), false)
	_title_screen.hide()
	_hud.show()
	_state = State.PLAYING
	_load_level.call_deferred(0)


func _release_demo_actions() -> void:
	Input.action_release("move_right")
	Input.action_release("jump")


## The last level is done: the picture stops, turns brown and the credits
## roll.
func _show_ending() -> void:
	_state = State.ENDING
	_level.process_mode = Node.PROCESS_MODE_DISABLED
	_hud.hide()
	_ending.play()


## The number keys jump straight to a level, to test levels quickly: 1 is the
## first level and 0 is the tenth. With Ctrl held, 1 is the eleventh and 0 is
## the twentieth. Plus and minus go to the next and the previous level.
func _unhandled_input(event: InputEvent) -> void:
	if _state != State.PLAYING:
		return
	if event.is_action_pressed("go_to_next_level"):
		_load_level.call_deferred((_level_index + 1) % levels.size())
		return
	if event.is_action_pressed("go_to_previous_level"):
		_load_level.call_deferred(posmod(_level_index - 1, levels.size()))
		return
	for index in mini(levels.size(), 20):
		if event.is_action_pressed("go_to_level_%d" % (index + 1), false, true):
			_load_level.call_deferred(index)
			return


func _load_level(index: int) -> void:
	if _level != null:
		remove_child(_level)
		_level.queue_free()
	_level_index = index
	_level = levels[index].instantiate()
	add_child(_level)
	for goal in get_tree().get_nodes_in_group("goal"):
		if _level.is_ancestor_of(goal):
			goal.reached.connect(_on_goal_reached)
	for catcher in get_tree().get_nodes_in_group("catcher"):
		if _level.is_ancestor_of(catcher):
			catcher.caught.connect(_on_caught)
	level_loaded.emit(_level)


## In the Quest build (or with `--xr-mode on` on a computer with an OpenXR
## runtime), OpenXR is running: draw to the headset and show the real room
## behind the game. Returns false on a normal screen.
func _start_headset() -> bool:
	var xr := XRServer.find_interface("OpenXR")
	if xr == null or not xr.is_initialized():
		return false
	var viewport := get_viewport()
	viewport.use_xr = true
	viewport.transparent_bg = true
	if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in xr.get_supported_environment_blend_modes():
		xr.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
	# The headset sets its own pace; physics follows its refresh rate so the
	# cat moves smoothly.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	xr.session_begun.connect(func() -> void:
		if xr.display_refresh_rate > 0.0:
			Engine.physics_ticks_per_second = roundi(xr.display_refresh_rate))
	return true


func _add_xr_rig(preview: bool) -> void:
	var rig: Node = load("res://scenes/xr/xr_rig.tscn").instantiate()
	rig.preview = preview
	add_child(rig)
	level_loaded.connect(rig.attach_level)


func _on_goal_reached() -> void:
	if _state == State.TITLE:
		_next_demo_level()
	elif _level_index == levels.size() - 1:
		_show_ending.call_deferred()
	else:
		_load_level.call_deferred(_level_index + 1)


## Something caught the cat, like the angry man: the level starts over.
## Behind the title, the next level plays instead.
func _on_caught() -> void:
	if _state == State.TITLE:
		_next_demo_level()
	else:
		_load_level.call_deferred(_level_index)
