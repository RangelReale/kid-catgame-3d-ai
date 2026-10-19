extends SceneTree

## Plays the game by itself for a few seconds: walks right, jumps and flaps.
## Use it with the movie writer to look at frames without a person playing:
##   godot_console --path . --write-movie out/f.png --fixed-fps 60 \
##       --quit-after 300 -s tools/tests/demo_drive.gd -- --level 1

## Frames on which the cat jumps or flaps.
const JUMP_FRAMES := [40, 75, 95, 115, 200]


func _initialize() -> void:
	root.add_child(load("res://scenes/main.tscn").instantiate())
	_drive.call_deferred()


func _drive() -> void:
	Input.action_press("move_right")
	for frame in 100000:
		if frame in JUMP_FRAMES:
			Input.action_press("jump")
		elif frame - 2 in JUMP_FRAMES:
			Input.action_release("jump")
		await physics_frame
