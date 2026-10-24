# Technology

## Choice

The 3D game uses **Godot 4.7**, with typed GDScript and the **Compatibility**
renderer (OpenGL). It is the same engine as the 2D game.

## Why Godot

- **Already in use.** Godot 4.7.2 is already installed. The input actions, the
  touch buttons, the sound and the export presets of the 2D game work without
  changes.
- **Text scenes.** Scenes (`.tscn`) and scripts (`.gd`) are text files. Claude
  can read and write a whole level. This keeps the rule of the 2D game: each
  level is a data file.
- **Runs on the Retroid.** The Retroid Pocket 3+ has a Mali-G52 GPU, which is
  weak. Godot's Vulkan mobile renderer runs poorly on this GPU. The
  Compatibility renderer is the safe choice, and the 2D game already uses it.
  Simple shapes with one color and a single light are cheap in it.
- **Free and open source.** The license is MIT. Since Godot 4.6, the default
  3D physics engine is Jolt, which is stable.

## Other options

| Engine | Why not |
| --- | --- |
| Unity | It has good mobile tools. But scenes are hard to edit as text, and Unity requires an account and a license. For a game this size, none of that helps. |
| Unreal | It is too heavy for the Retroid. C++ and Blueprints do not fit small changes requested by voice. |
| Bevy | It has no editor, and mobile export is still immature. |
| three.js | It has no editor and is made for the web, with no export to Android or iOS. |

## Sources

- [Arm: optimizing 3D scenes in Godot on Arm GPUs](https://developer.arm.com/community/arm-community-blogs/b/mobile-graphics-and-gaming-blog/posts/optimizing-3d-scenes-in-godot-on-arm-gpus)
- [How to test your Godot game on low-end Android phones](https://bugnet.io/blog/how-to-test-your-godot-game-on-low-end-android-phones)
- [Unity vs Godot vs Unreal in 2026](https://oceanviewgames.co.uk/blog/posts/unity-vs-godot-vs-unreal-2026)
- [Open source game engines in 2026](https://app.cinevva.com/guides/open-source-game-engines-2026)
