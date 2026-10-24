# Virtual reality on the Meta Quest 3

The game has a version for the Meta Quest 3 headset. The level appears as a
diorama, a wooden box 1 m wide that floats in the real room, in front of the
child. The version has already run on a real Quest 3 (see
[Headset test](#headset-test)).

![Level 16 as a diorama: a wooden box with the amusement park inside and the sky painted on the back](images/diorama.png)

## How it works

- **Mixed reality.** The headset shows the real room through its cameras
  (passthrough). Only the diorama is virtual.
- **The diorama stays still; the level slides.** The box does not move in the
  room. The level passes through it, and the cat stays near the middle, as
  with the screen camera. The child does not need to walk or turn their head.
  In level 9, the level slides up and down; in level 11, the diorama follows
  the airplane.
- **Size.** 16 game units equal 1 m. The box window is 1 m by 0.6 m. The cat
  is about 5 cm.
- **Place in the room.** When the game starts, the box appears 0.9 m from the
  head, with its base 0.45 m below the eyes, roughly at table height for a
  seated child. Holding the grip button of a controller for 1 second brings
  the box back in front of the head. The Quest's own recenter (holding the
  Meta button) does the same.
- **Controllers.** The thumbstick of either controller walks sideways and
  swims down. A or a trigger jump. X also jumps, but when the cat swims or
  flies freely (levels 4 and 8), X goes down. They press the same actions as
  the keyboard, so no game rule changed.
- **Changing levels.** A click on the right controller thumbstick turns level
  change mode on and off. In this mode, right and left on the thumbstick go to
  the next and the previous level, like the + and - keys, and the cat does not
  walk. While the mode is on, the front of the base shows "<  Level N  >" (or
  "Fase N", in Portuguese) with the level number. Another click returns to
  normal.
- **Clipping at the edges.** The ground and the hills of the levels are wider
  than the box. Invisible panels around the box erase what is outside it, and
  the room shows there.
- **Sky.** The back of the box is painted with the level's sky color, with the
  sun and the clouds in front.
- **Depth.** The box is about 0.9 m deep (14.5 units), so it does not go into
  the room walls. The levels were made with decoration up to 20 units behind
  the cat. So, on the headset only, the hills, trees and other decoration the
  cat does not touch get half their depth.
- **Title screen and ending.** The text of the title screen and the credits
  is drawn over the computer screen and does not appear on the headset. So
  the diorama shows the same words in 3D (`scenes/xr/captions.tscn`). "Cat Game",
  "You won!" and the credits sit on wooden signs, because without
  something solid behind them the room shows in place of the letters. "Press a
  button to start" sits on the front of the base, so it does not cover the cat. The
  sepia tone comes from the color adjustment of the level environment and
  also tints the words. Trigger, A or X start the game and return from the
  credits. The music and the sounds play the same.
- **Language.** On the title screen, B or Y switch between Portuguese and
  English, like the L key. The diorama words change at once. The flags of the
  computer screen do not appear on the headset.

## Viewing on the computer, without a headset

`godot --path . -- --xr-preview` shows the diorama on the screen, seen from
where the head would be. The gray around it stands in for the room. It works
with `--level N` and with the level keys.

With an OpenXR runtime on the computer and a headset connected to it (for
example, Quest Link or Virtual Desktop), `godot --path . --xr-mode on` runs the
headset version straight from the computer. Without a headset, the game falls
back to the screen.

## Building the Quest version

1. Download the plugin once: `sh tools/install_xr_plugin.sh`. It goes into
   `addons/godotopenxrvendors/`, outside Git, because it is about 80 MB.
2. Export:
   `godot --headless --path . --install-android-build-template --export-debug "Quest" build/quest/catgame3d-quest.apk`.
   The first time is slow, because Gradle downloads what it needs.
3. Install with the headset on the USB cable and developer mode active:
   `adb install -r build/quest/catgame3d-quest.apk`.

The "Quest" preset turns on the `quest` feature. Only with it does OpenXR turn
on (`xr/openxr/enabled.quest` in `project.godot`). The screen game, the Retroid
and the iPad stay without OpenXR.

## Headset test

The first test was on 2026-10-19, on a Quest 3 with Android 14, connected
through adb over Wi-Fi.

- The game opens straight in headset mode, and OpenXR uses the Oculus runtime.
- Passthrough stays on: the room appears around the diorama.
- Clipping at the edges works. The ground and hills that go past the box do
  not appear in the room.
- The game runs at 72 frames per second. The GPU uses about 42%, so there is
  still headroom and the shadows can stay on.
- Godot warns that foveation was turned off because the game uses features
  that do not work with it. The game works normally.

To see what the headset shows:
`adb shell screencap -p /sdcard/q.png` and then `adb pull /sdcard/q.png`.
To see the game log: `adb logcat -s godot`. The `VrApi FPS=` line of
`adb logcat` shows the frames per second.

## What is left to test on the headset

- Comfort: the speed at which the level slides, and the distance and height
  of the box.
- Thumbstick down and X going down in the water (level 4) and in flight
  (level 8).
- The speed in the heaviest levels, such as 16.
- The size and position of the words on the title screen and the credits.
- The photo flash of the princesses (level 14), which on the headset is a
  white sphere around the head.
- On the Retroid, whether the screen game opens without errors. The "Android"
  export does not include the headset plugin, but Godot's extension list
  still mentions its file. The expected result is a single error message at
  startup, with no effect.

## Care for the child

- Meta recommends the Quest for ages 10 and up. The daughter is 6. The parents
  decide whether and how much she uses it.
- Short sessions. The box stays still in the room to avoid motion sickness.
