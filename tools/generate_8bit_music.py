#!/usr/bin/env python3
"""Generate seamless, original 8-bit mood loops for Room to Grow."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 22050
BEATS_PER_BAR = 4
BAR_COUNT = 8
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "audio"

NOTE_OFFSETS = {
    "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3,
    "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8,
    "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11,
}


def frequency(note: str) -> float:
    name = note[:-1]
    octave = int(note[-1])
    midi = (octave + 1) * 12 + NOTE_OFFSETS[name]
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))


def oscillator(kind: str, phase: float, duty: float = 0.5) -> float:
    position = phase % 1.0
    if kind == "square":
        return 1.0 if position < duty else -1.0
    if kind == "triangle":
        return 1.0 - 4.0 * abs(position - 0.5)
    if kind == "sine":
        return math.sin(phase * math.tau)
    raise ValueError(f"Unknown oscillator: {kind}")


class Loop:
    def __init__(self, bpm: int):
        self.bpm = bpm
        self.seconds_per_beat = 60.0 / bpm
        self.duration = BAR_COUNT * BEATS_PER_BAR * self.seconds_per_beat
        self.sample_count = round(self.duration * SAMPLE_RATE)
        self.samples = [0.0] * self.sample_count
        self.random = random.Random(206 + bpm)

    def note(
        self,
        beat: float,
        length: float,
        pitch: str,
        kind: str,
        volume: float,
        duty: float = 0.5,
        gate: float = 0.84,
    ) -> None:
        start = round(beat * self.seconds_per_beat * SAMPLE_RATE)
        duration = max(1, round(length * self.seconds_per_beat * SAMPLE_RATE))
        sounding = max(1, round(duration * gate))
        attack = max(1, min(round(0.006 * SAMPLE_RATE), sounding // 4))
        release = max(1, min(round(0.022 * SAMPLE_RATE), sounding // 3))
        pitch_hz = frequency(pitch)
        for local_index in range(sounding):
            target = start + local_index
            if target >= self.sample_count:
                break
            envelope = 1.0
            if local_index < attack:
                envelope = local_index / attack
            elif local_index >= sounding - release:
                envelope = (sounding - local_index - 1) / release
            phase = local_index * pitch_hz / SAMPLE_RATE
            self.samples[target] += (
                oscillator(kind, phase, duty) * volume * max(0.0, envelope)
            )

    def kick(self, beat: float, volume: float = 0.16) -> None:
        start = round(beat * self.seconds_per_beat * SAMPLE_RATE)
        duration = round(0.115 * SAMPLE_RATE)
        attack = max(1, round(0.004 * SAMPLE_RATE))
        phase = 0.0
        for local_index in range(duration):
            target = start + local_index
            if target >= self.sample_count:
                break
            progress = local_index / duration
            pitch_hz = 105.0 - 58.0 * progress
            phase += pitch_hz / SAMPLE_RATE
            envelope = min(1.0, local_index / attack) * (1.0 - progress) ** 2
            self.samples[target] += oscillator("triangle", phase) * volume * envelope

    def noise(self, beat: float, volume: float = 0.055, length: float = 0.045) -> None:
        start = round(beat * self.seconds_per_beat * SAMPLE_RATE)
        duration = round(length * SAMPLE_RATE)
        held = 0.0
        for local_index in range(duration):
            target = start + local_index
            if target >= self.sample_count:
                break
            if local_index % 5 == 0:
                held = self.random.choice((-1.0, 1.0))
            progress = local_index / duration
            self.samples[target] += held * volume * (1.0 - progress)

    def drums(self, energy: float = 1.0, sparse: bool = False) -> None:
        total_beats = BAR_COUNT * BEATS_PER_BAR
        for beat in range(total_beats):
            if beat % 4 in (0, 2):
                self.kick(beat, 0.13 * energy)
            if beat % 4 in (1, 3):
                self.noise(beat, 0.065 * energy, 0.075)
            if not sparse:
                self.noise(beat + 0.5, 0.035 * energy, 0.035)

    def save(self, filename: str) -> None:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        peak = max(max(abs(value) for value in self.samples), 0.001)
        gain = min(0.92 / peak, 1.35)
        encoded = bytearray()
        for value in self.samples:
            compressed = math.tanh(value * gain * 1.15)
            quantized = round(compressed * 112.0)
            encoded.extend(struct.pack("B", max(0, min(255, 128 + quantized))))
        with wave.open(str(OUTPUT_DIR / filename), "wb") as output:
            output.setnchannels(1)
            output.setsampwidth(1)
            output.setframerate(SAMPLE_RATE)
            output.writeframes(encoded)


def repeat_pattern(loop: Loop, pattern, bars: int = BAR_COUNT) -> None:
    for bar in range(bars):
        for offset, length, pitch, kind, volume, duty in pattern[bar % len(pattern)]:
            loop.note(bar * 4 + offset, length, pitch, kind, volume, duty)


def curious() -> Loop:
    loop = Loop(112)
    melody = [
        [(0, .5, "E5", "square", .12, .25), (.5, .5, "G5", "square", .12, .25),
         (1, 1, "A5", "square", .13, .25), (2, .5, "G5", "square", .11, .25),
         (2.5, .5, "E5", "square", .11, .25), (3, 1, "D5", "square", .12, .25)],
        [(0, .5, "C5", "square", .11, .25), (.5, .5, "D5", "square", .11, .25),
         (1, 1, "E5", "square", .13, .25), (2, .5, "G5", "square", .11, .25),
         (2.5, .5, "E5", "square", .11, .25), (3, 1, "C5", "square", .12, .25)],
        [(0, .5, "F5", "square", .11, .25), (.5, .5, "A5", "square", .12, .25),
         (1, 1, "G5", "square", .13, .25), (2, .5, "E5", "square", .11, .25),
         (2.5, .5, "D5", "square", .11, .25), (3, 1, "G5", "square", .12, .25)],
        [(0, .5, "E5", "square", .12, .25), (.5, .5, "D5", "square", .11, .25),
         (1, 1, "C5", "square", .13, .25), (2, .5, "D5", "square", .10, .25),
         (2.5, .5, "E5", "square", .10, .25), (3, .75, "C5", "square", .12, .25)],
    ]
    repeat_pattern(loop, melody)
    roots = ["C3", "A2", "F2", "G2", "C3", "A2", "F2", "G2"]
    fifths = ["G3", "E3", "C3", "D3", "G3", "E3", "C3", "D3"]
    for bar, (root, fifth) in enumerate(zip(roots, fifths)):
        loop.note(bar * 4, 2, root, "triangle", .13)
        loop.note(bar * 4 + 2, 2, fifth, "triangle", .11)
    loop.drums(.72)
    return loop


def supported() -> Loop:
    loop = Loop(96)
    melody = [
        [(0, 1, "C5", "square", .09, .5), (1, 1, "E5", "square", .10, .5),
         (2, 2, "G5", "square", .11, .5)],
        [(0, 1, "A5", "square", .10, .5), (1, 1, "G5", "square", .09, .5),
         (2, 2, "E5", "square", .11, .5)],
        [(0, 1, "F5", "square", .09, .5), (1, 1, "A5", "square", .10, .5),
         (2, 1, "G5", "square", .09, .5), (3, 1, "E5", "square", .10, .5)],
        [(0, 1, "D5", "square", .09, .5), (1, 1, "E5", "square", .09, .5),
         (2, 2, "C5", "square", .11, .5)],
    ]
    repeat_pattern(loop, melody)
    chords = [
        ("C3", "E3", "G3"), ("A2", "C3", "E3"),
        ("F2", "C3", "A3"), ("G2", "D3", "B3"),
    ]
    for bar in range(BAR_COUNT):
        chord = chords[bar % len(chords)]
        for offset, pitch in enumerate(chord):
            loop.note(bar * 4 + offset, 1.25, pitch, "triangle", .075)
        loop.note(bar * 4 + 3, 1, chord[1], "triangle", .065)
    loop.drums(.46, sparse=True)
    return loop


def anxious() -> Loop:
    loop = Loop(132)
    melody = [
        [(0, .5, "D5", "square", .13, .125), (.5, .5, "Eb5", "square", .12, .125),
         (1, .5, "A4", "square", .13, .125), (1.5, .5, "Bb4", "square", .12, .125),
         (2, 1, "D5", "square", .14, .125), (3, .5, "C#5", "square", .13, .125),
         (3.5, .5, "A4", "square", .12, .125)],
        [(0, .5, "F5", "square", .13, .125), (.5, .5, "E5", "square", .12, .125),
         (1, 1, "C#5", "square", .14, .125), (2, .5, "D5", "square", .12, .125),
         (2.5, .5, "Ab4", "square", .13, .125), (3, 1, "A4", "square", .14, .125)],
    ]
    repeat_pattern(loop, melody)
    bass = ["D2", "D2", "Eb2", "C#2", "D2", "F2", "Eb2", "C#2"]
    for bar, root in enumerate(bass):
        for offset in (0, 1.5, 2, 3.5):
            loop.note(bar * 4 + offset, .5, root, "square", .11, .25)
    loop.drums(1.15)
    for beat in range(BAR_COUNT * BEATS_PER_BAR):
        loop.noise(beat + .25, .022, .025)
    return loop


def uncertain() -> Loop:
    loop = Loop(88)
    melody = [
        [(0, 1, "E5", "square", .085, .25), (1.5, .5, "D5", "square", .075, .25),
         (2.5, 1, "C5", "square", .085, .25)],
        [(0, .75, "A4", "square", .08, .25), (1.5, .5, "C5", "square", .075, .25),
         (2.5, 1, "B4", "square", .08, .25)],
        [(0, 1, "F5", "square", .08, .25), (1.5, .5, "E5", "square", .075, .25),
         (2.5, 1, "C5", "square", .08, .25)],
        [(0, .75, "D5", "square", .08, .25), (1.5, .5, "B4", "square", .07, .25),
         (2.5, .75, "A4", "square", .08, .25)],
    ]
    repeat_pattern(loop, melody)
    roots = ["A2", "A2", "F2", "E2", "A2", "C3", "F2", "E2"]
    for bar, root in enumerate(roots):
        loop.note(bar * 4, 2.5, root, "triangle", .10)
        loop.note(bar * 4 + 3, .75, root, "triangle", .07)
    loop.drums(.30, sparse=True)
    return loop


def confident() -> Loop:
    loop = Loop(124)
    melody = [
        [(0, .5, "G4", "square", .11, .25), (.5, .5, "B4", "square", .11, .25),
         (1, .5, "D5", "square", .12, .25), (1.5, .5, "G5", "square", .13, .25),
         (2, 1, "A5", "square", .13, .25), (3, 1, "G5", "square", .12, .25)],
        [(0, .5, "E5", "square", .11, .25), (.5, .5, "G5", "square", .12, .25),
         (1, 1, "B5", "square", .13, .25), (2, .5, "A5", "square", .12, .25),
         (2.5, .5, "G5", "square", .11, .25), (3, 1, "E5", "square", .12, .25)],
        [(0, .5, "C5", "square", .11, .25), (.5, .5, "E5", "square", .11, .25),
         (1, .5, "G5", "square", .12, .25), (1.5, .5, "C6", "square", .13, .25),
         (2, 1, "B5", "square", .13, .25), (3, 1, "G5", "square", .12, .25)],
        [(0, .5, "D5", "square", .11, .25), (.5, .5, "G5", "square", .12, .25),
         (1, 1, "A5", "square", .13, .25), (2, .5, "B5", "square", .12, .25),
         (2.5, .5, "A5", "square", .11, .25), (3, .75, "G5", "square", .13, .25)],
    ]
    repeat_pattern(loop, melody)
    roots = ["G2", "E2", "C3", "D3", "G2", "E2", "C3", "D3"]
    fifths = ["D3", "B2", "G3", "A3", "D3", "B2", "G3", "A3"]
    for bar, (root, fifth) in enumerate(zip(roots, fifths)):
        for offset, pitch in ((0, root), (1, fifth), (2, root), (3, fifth)):
            loop.note(bar * 4 + offset, .9, pitch, "triangle", .115)
    loop.drums(.92)
    return loop


def main() -> None:
    tracks = {
        "mind_curious.wav": curious(),
        "mind_supported.wav": supported(),
        "mind_anxious.wav": anxious(),
        "mind_uncertain.wav": uncertain(),
        "mind_confident.wav": confident(),
    }
    for filename, track in tracks.items():
        track.save(filename)
        print(f"{filename}: {track.bpm} BPM, {track.duration:.2f}s")


if __name__ == "__main__":
    main()
