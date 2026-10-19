extends Node

## Emitted after a level is loaded and added, so the diorama rig of the
## headset can take it over.
signal level_loaded(level: Node)

## The levels, in the order they are played. After the last one, the game
## goes back to the first.
@export var levels: Array[PackedScene] = []
## Shows the level as a diorama box, like in the headset, on a computer
## screen. `godot --path . -- --xr-preview` turns it on too.
@export var xr_preview: bool = false

var _level_index: int = 0
var _level: Node


## `godot --path . -- --level 3` starts at the third level, to test it quickly.
func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if xr_preview or args.has("--xr-preview"):
		_add_xr_rig(true)
	if levels.is_empty():
		return
	var start := 0
	var level_arg := args.find("--level")
	if level_arg >= 0 and level_arg + 1 < args.size():
		start = clampi(args[level_arg + 1].to_int() - 1, 0, levels.size() - 1)
	_load_level(start)


## The number keys jump straight to a level, to test levels quickly: 1 is the
## first level and 0 is the tenth. With Ctrl held, 1 is the eleventh and 0 is
## the twentieth. Plus and minus go to the next and the previous level.
func _unhandled_input(event: InputEvent) -> void:
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


func _add_xr_rig(preview: bool) -> void:
	var rig: Node = load("res://scenes/xr/xr_rig.tscn").instantiate()
	rig.preview = preview
	add_child(rig)
	level_loaded.connect(rig.attach_level)


func _on_goal_reached() -> void:
	_load_level.call_deferred((_level_index + 1) % levels.size())


## Something caught the cat, like the angry man: the level starts over.
func _on_caught() -> void:
	_load_level.call_deferred(_level_index)
