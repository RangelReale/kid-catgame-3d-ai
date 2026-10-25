# Architecture

## Overview

The game is 2.5D: everything is 3D, but the cat, the little monsters and the
flag stay on the plane where z is 0. The cat moves sideways (x) and up and down
(y), as in the 2D game. Depth (z) is only for looks: boxes with volume, hills
in the background and shadows.

## Folders

```
project.godot          settings: window, input actions, renderer
scenes/
  main.tscn            the scene the game opens; it holds the level list and the buttons.
                       main.gd goes through three states: title screen (demo
                       levels that play by themselves), game and ending
  hud/                 touch buttons (2D, copied from the 2D game)
  title_screen/        title screen, with the music (2D, drawn over the 3D)
  language/            the current language and the saved choice (from the 2D game)
  language_flag/       the flags that switch the language on the title screen
  ending/              "You won!" and the credits (2D, drawn over the 3D)
  sepia/               shader that tints the screen brown, like an old photo
  xr/                  the headset version: the diorama (rig), the box and the controllers
  camera/              the camera that follows the cat
  level/               level pieces: block, one-way moving platform,
                       light and sky, distant sky, wobble, painting
  levels/              one scene per level
  player/              the cat
  monster/             the little monster
  goal/                the finish flag
  sun/, cloud/         the sun and the clouds in the sky
assets/                icon, sounds, music and translated text. Effects play on the
                       `Sounds` bus, muted on the title screen; music plays on `Master`
tools/sounds/, tools/music/  Python scripts that generate the sounds and the music
tools/tests/           automated tests and the auto-drive that records frames
tools/promo/           autopilot and ffmpeg filters for the promo videos
tools/install_xr_plugin.sh  downloads the OpenXR Vendors plugin (outside Git)
addons/                OpenXR Vendors plugin, downloaded by the script above
docs-en/, docs-pt-br/  these documents, in English and in Portuguese (Godot
                       ignores the folders)
```

## Measurements

One 3D unit equals 32 pixels of the 2D game. The ground is at y = 0, and y
grows upward (in 2D, y grows downward). To convert a position from 2D to 3D:

- 3D x = 2D x ÷ 32
- 3D y = (238 − 2D y) ÷ 32, because the 2D ground was at y = 238

The cat's numbers are the 2D ones divided by 32:

| Value | 2D (pixels) | 3D (units) |
| --- | --- | --- |
| Speed | 120 | 3.75 |
| Jump | 300 | 9.375 |
| Gravity | 900 | 28.125 |
| Wing flap | 250 | 7.8125 |
| Bounce on a monster | 220 | 6.875 |
| Swimming (mermaid and flying) | 130 | 4.0625 |
| Monster: speed, distance | 25, 60 | 0.78125, 1.875 |

The jump rises 1.64 units, which is 52.5 pixels, the same as in the 2D game.

## Level pieces

- **Block** (`scenes/level/block.gd`): a solid box. Its position is the center
  of the box. It has a size, a color and two options: `show_mesh` (off for
  invisible walls) and `one_way` (a platform the cat passes through from
  below). Godot 3D has no one-way platform, so the block turns its collision
  on only when the cat's feet are above it and the cat is not rising.
- **Light and sky** (`scenes/level/level_environment.gd`): the sky color, the
  ambient light, the sun with shadows and the fog. On the Retroid, `shadows`
  can be turned off if the game runs slowly.
- **Distant sky** (`scenes/level/sky.gd`): holds the sun and the clouds, far
  from the cat (z = −30). It follows the camera a little slower than the camera
  moves, so it looks far away.
- **Wobble** (`scenes/level/wobble.gd`): makes the water rise and fall and the
  seaweed sway.

## Camera

The camera (`scenes/camera/follow_camera.gd`) follows the cat smoothly. It sits
a little above (`pitch_degrees`, 8 degrees) and a little to the left
(`yaw_degrees`, 6 degrees), to show the top and the side of the boxes. With both
at 0, the view is straight, as in 2D.

Each level sets the camera limits on the z = 0 plane (`limit_left`,
`limit_right`, `limit_bottom`, `limit_top`). Because of the tilt, the visible
area is a trapezoid, not a rectangle. The camera uses the largest rectangle
that fits inside it, so a little of the outside can show in the corners. This
is why the ground of each level is wider than the level.

## How to port a level from 2D to 3D

1. Copy a finished level, such as `level_01.tscn`.
2. Convert each position and size with the formulas in "Measurements". Blocks
   use the center of the box, like the `StaticBody2D` nodes of the 2D game.
3. The ground has a depth of 10 and sits at z = −3, so it spans from z = −8 to
   z = 2. Boxes and platforms have a depth between 1.5 and 2.
4. Put the sun and the clouds inside the `Sky` node, at z = −30.
5. Put decoration in the background (negative z) to add depth.
6. Add the level to the `levels` list in `scenes/main.tscn`.

## Languages

The game speaks Brazilian Portuguese and English, like the 2D game. The
on-screen text lives in `assets/translations/strings.csv`, one row per text,
with a key (`TITLE`) and one column per language. In the scenes, each `Label`
and each `Label3D` stores the key, and Godot replaces it with the phrase in the
current language. Godot generates the `.translation` files on import; they stay
out of Git.

The first time, the game uses the device language. If the device is in neither
Portuguese nor English, it uses English. The `Language` class
(`scenes/language/language.gd`) switches the language and saves the choice in
`user://settings.cfg`. In the 2D game it is an autoload. Here it only has
static functions, because the tests compile the game scripts before Godot
creates the autoloads. When the language changes, Godot notifies every node
with `NOTIFICATION_TRANSLATION_CHANGED`.

On the title screen, two flags in the top corner (Brazil and the United
States) show the current language. Tapping or clicking a flag switches the
language. The `change_language` action (the L key or the gamepad back button)
moves to the next language. Neither of them starts the game. On the headset,
B or Y do the same.

After creating a new class (`class_name`), run the import once. Without it,
the tests do not find the class.

## Headset version

Details in [04-virtual-reality.md](04-virtual-reality.md). In short:

- `scenes/main.gd` checks whether OpenXR is on. If it is, or if the game starts
  with `-- --xr-preview`, it adds the rig `scenes/xr/xr_rig.tscn` and tells
  the rig about each new level (the `level_loaded` signal).
- The rig turns off the level camera but uses its target and limits. This is
  why the levels do not change for the headset.
- The box (`scenes/xr/stage.gd`) has panels with the
  `scenes/xr/holdout.gdshader` shader, which make everything behind them
  transparent. On the headset, the transparent parts show the room.
- The sky (`scenes/level/sky.gd`) and the light
  (`scenes/level/level_environment.gd`) have a headset mode, which the rig
  turns on.

## Tests

- `godot_console --headless --path . -s tools/tests/movement_test.gd` tests the
  jump, the wings, the little monster, the flag, the one-way platform and the
  mermaid. `group_a_test.gd`, `group_b_test.gd` and `group_c_test.gd` test the
  pieces of levels 5 to 16: angry man, bosses, birds, suitcases, airplane,
  trampoline, rides that carry the cat, princesses and fish.
- `tools/tests/xr_test.gd` tests the headset diorama through the preview: the
  window follows the cat and stops at the limits, the level camera turns off,
  the sky moves to the back of the box, the controllers press the actions and
  the box appears in front of the head.
- `tools/tests/flow_test.gd` tests the title screen, the ending and the
  language switch. It restores the saved language to what it was before.
- `tools/tests/demo_drive.gd` plays by itself for a few seconds. With Godot's
  movie writer (`--write-movie`), it records frames to see the game without
  playing. The command is at the top of the file.
