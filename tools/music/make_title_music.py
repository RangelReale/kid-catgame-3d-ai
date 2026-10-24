"""Writes assets/music/title.wav: a short, cheerful tune for the title screen.

The sound imitates the beeper of an old PC: one square wave, one note at a
time. Run it from the repository root: python tools/music/make_title_music.py
"""

import math
import struct
import wave

SAMPLE_RATE = 22050
BEATS_PER_MINUTE = 160
VOLUME = 0.22
# Part of each note that sounds; the rest is a tiny silence between notes.
GATE = 0.85
# Seconds the start and the end of each note take to fade, to avoid clicks.
FADE = 0.004

NOTE_STEPS = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}

# Each pair is a note and its length in eighth notes. "R" is a rest.
MELODY = [
    ("C5", 1), ("E5", 1), ("G5", 1), ("E5", 1), ("C6", 2), ("G5", 2),
    ("A5", 1), ("G5", 1), ("F5", 1), ("E5", 1), ("D5", 2), ("G4", 2),
    ("B4", 1), ("D5", 1), ("F5", 1), ("D5", 1), ("B5", 2), ("G5", 2),
    ("A5", 1), ("G5", 1), ("F5", 1), ("D5", 1), ("C5", 2), ("R", 2),
    ("E5", 1), ("E5", 1), ("F5", 1), ("G5", 1), ("A5", 2), ("A5", 2),
    ("G5", 1), ("F5", 1), ("E5", 1), ("D5", 1), ("E5", 2), ("C5", 2),
    ("D5", 1), ("D5", 1), ("E5", 1), ("F5", 1), ("G5", 1), ("A5", 1), ("B5", 1), ("D6", 1),
    ("C6", 2), ("G5", 1), ("E5", 1), ("C5", 4),
]


def frequency(note: str) -> float:
    steps = NOTE_STEPS[note[0]] + 12 * (int(note[1]) - 4)
    return 440.0 * 2.0 ** (steps / 12.0)


def main() -> None:
    eighth = 60.0 / BEATS_PER_MINUTE / 2.0
    samples: list[float] = []
    for note, length in MELODY:
        count = int(length * eighth * SAMPLE_RATE)
        if note == "R":
            samples.extend([0.0] * count)
            continue
        hertz = frequency(note)
        sounding = int(count * GATE)
        fade = int(FADE * SAMPLE_RATE)
        for i in range(count):
            if i >= sounding:
                samples.append(0.0)
                continue
            level = min(1.0, i / fade, (sounding - i) / fade)
            square = 1.0 if math.sin(2.0 * math.pi * hertz * i / SAMPLE_RATE) >= 0.0 else -1.0
            samples.append(square * VOLUME * level)
    with wave.open("assets/music/title.wav", "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        out.writeframes(b"".join(struct.pack("<h", int(s * 32767)) for s in samples))


if __name__ == "__main__":
    main()
