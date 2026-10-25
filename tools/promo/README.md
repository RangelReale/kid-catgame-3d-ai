# Promo video

[Português](README.pt-br.md)

These files rebuild the 46-second promo video of the 3D game, in Portuguese
(`build/promo/jogo_do_gato_promo.mp4`) and in English
(`build/promo/cat_game_promo.mp4`). Both use the same gameplay. They follow
the [promo video of the 2D game](https://github.com/RangelReale/kid-catgame-ai/tree/master/tools/promo):
same clips, same titles and same music.

- `autopilot.gd`: skips the title screen and plays by itself. It shows a
  few seconds of several levels, one after the other. The `CLIPS` list says
  which level goes in, for how long and where the cat starts, in units. The
  cat walks right, jumps on the little monsters, swims as a mermaid, flies
  away from the little birds and rides the Ferris wheel and the roller
  coaster. When a clip starts, it calls `snap()` on the level camera, so
  the camera jumps straight to the cat.
- `filter.txt`: the ffmpeg filter. It cuts the video at 46.5 seconds, adds
  the titles in Portuguese and mixes the music with the game sound.
- `filter_en.txt`: the same filter, with the titles in English.

The export presets for Windows, Web and Quest leave the `tools/` folder out,
so the script does not go into those exported games.

## Requirements

- `godot` and `ffmpeg` on the `PATH`.
- The Comic Sans MS Bold font. It comes with Windows and Mac.

## Steps

Run from the root of the repository. On Windows, use `godot_console`
instead of `godot`.

1. Test the autopilot without recording. The output should show a `clip`
   line for each clip, a `POP` for each little monster and a `ride` for each
   ride:

   ```sh
   godot --headless --path . --fixed-fps 60 -s tools/promo/autopilot.gd
   ```

2. Record the gameplay. Godot opens a window and records 46.5 seconds:

   ```sh
   mkdir -p build/promo
   godot --path . --write-movie build/promo/gameplay.avi --fixed-fps 30 -s tools/promo/autopilot.gd
   ```

   In PowerShell, replace `mkdir -p build/promo` with
   `New-Item -ItemType Directory -Force build/promo`.

3. Download the music and copy the font. If you already built the video
   of the 2D game, you can copy its `build/promo/music.wav` instead of
   downloading it.

   ```sh
   curl -L -o build/promo/music.wav "https://opengameart.org/sites/default/files/Cat%20Song%201.2.wav"
   ```

   - Windows: `Copy-Item C:\Windows\Fonts\comicbd.ttf build\promo\font.ttf`
   - Mac: `cp "/System/Library/Fonts/Supplemental/Comic Sans MS Bold.ttf" build/promo/font.ttf`

4. Build the videos from `build/promo`. The filters look for `font.ttf` in
   the current folder. The first command makes the Portuguese video, and
   the second makes the English one:

   ```sh
   cd build/promo
   ffmpeg -y -i gameplay.avi -stream_loop 1 -i music.wav -/filter_complex ../../tools/promo/filter.txt -map "[v]" -map "[a]" -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart jogo_do_gato_promo.mp4
   ffmpeg -y -i gameplay.avi -stream_loop 1 -i music.wav -/filter_complex ../../tools/promo/filter_en.txt -map "[v]" -map "[a]" -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart cat_game_promo.mp4
   cd ../..
   ```

## When the game changes

The titles in `filter.txt` and `filter_en.txt` appear at fixed seconds, the
same in both files. Each title matches a clip in `CLIPS`: level 1 until
9 s, the beach, the mermaid, the big rat, the sky, the airplane, the
princesses, the giant monster, the Ferris wheel, the roller coaster and the
end at 42.5 s. If you change the `CLIPS` list, run step 1. Then adjust the
`enable='between(t,...)'` times and the end times to the new moments in the
output, in both filters.

## Music

"Cat Song", by Dan Knoflicek, is at
<https://opengameart.org/content/cat-song>. The license is CC0, so there is
no need to ask permission. The author asks for credit, which already
appears at the end of both videos. He also asks for a message or a link when
someone uses the music. The song is 27 seconds long. The `-stream_loop 1`
option plays the music twice in a row, and the filter lowers the volume in
the last 2 seconds.
