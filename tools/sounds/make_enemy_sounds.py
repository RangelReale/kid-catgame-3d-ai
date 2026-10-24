"""Writes the enemy sounds in assets/sounds/.

- stomp.wav: a short "bonk" when the cat lands on an enemy that is not beaten
  yet.
- pop.wav: a soft "puf" with a little sparkle when an enemy turns into stars.

Run it from the repository root: python tools/sounds/make_enemy_sounds.py
"""

import math
import random
import struct
import wave

SAMPLE_RATE = 22050


def write(path: str, samples: list[float]) -> None:
    with wave.open(path, "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        out.writeframes(b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples))


def stomp() -> list[float]:
    """A square wave that slides down quickly and fades."""
    duration = 0.13
    count = int(duration * SAMPLE_RATE)
    samples = []
    phase = 0.0
    for i in range(count):
        t = i / count
        hertz = 520.0 * (180.0 / 520.0) ** t
        phase += hertz / SAMPLE_RATE
        square = 1.0 if phase % 1.0 < 0.5 else -1.0
        samples.append(square * 0.3 * (1.0 - t) ** 1.5)
    return samples


def pop() -> list[float]:
    """A soft noise puff, then four quick rising chimes."""
    rng = random.Random(7)
    samples = []
    puff = int(0.09 * SAMPLE_RATE)
    smooth = 0.0
    for i in range(puff):
        t = i / puff
        smooth += (rng.uniform(-1.0, 1.0) - smooth) * 0.25
        samples.append(smooth * 0.9 * (1.0 - t) ** 2)
    for hertz in (1046.5, 1318.5, 1568.0, 2093.0):
        chime = int(0.075 * SAMPLE_RATE)
        for i in range(chime):
            t = i / chime
            wave_value = math.sin(2.0 * math.pi * hertz * i / SAMPLE_RATE)
            samples.append(wave_value * 0.25 * (1.0 - t) ** 2)
    return samples


def main() -> None:
    write("assets/sounds/stomp.wav", stomp())
    write("assets/sounds/pop.wav", pop())


if __name__ == "__main__":
    main()
