# 8-bit mood music

All five background loops are original procedural compositions created for
Room to Grow. They use square-wave melody, triangle-wave bass, and short noise
percussion, rendered as compact 8-bit unsigned mono WAV files at 22.05 kHz.

| Track | Mood | Tempo | Loop length |
| --- | --- | ---: | ---: |
| `mind_curious.wav` | Neutral curiosity and observation | 112 BPM | 17.14 s |
| `mind_supported.wav` | Feeling heard and appropriately supported | 96 BPM | 20.00 s |
| `mind_anxious.wav` | Stress, pressure, or emotional distance | 132 BPM | 14.55 s |
| `mind_uncertain.wav` | Reduced confidence or over-direction | 88 BPM | 21.82 s |
| `mind_confident.wav` | Competence and growing independence | 124 BPM | 15.48 s |

## Runtime selection

During feedback, the selected action's support style has priority:

- `responsive` plays `mind_supported`.
- `fixer` plays `mind_uncertain`.
- `distant` plays `mind_anxious`.

At other moments, high stress selects anxious music; low confidence or low
independence selects uncertain music; combined high confidence and independence
selects confident music. Other states use the curious loop. Endings use the
loop matching the final support pattern.

Music volume is set to 46 out of 128 so it remains behind dialogue and teaching
text. Each file starts and ends on the digital zero value, preventing a click at
the loop boundary.

## Regeneration

The source generator is committed with the project. It uses only Python's
standard library:

```sh
python3 tools/generate_8bit_music.py
```

Running it deterministically replaces the five files in `audio/`.

## UI sound

`block_click.ogg` is Kenney's original `impactWood_light_000.ogg`, renamed
without editing the recording. It is a natural, light wooden impact and plays
on channel 1 for mouse and keyboard selections without interrupting the music
stream.

Source: Kenney, *Impact Sounds* 1.0
<https://www.kenney.nl/assets/impact-sounds>

License: Creative Commons Zero (CC0). The original license text is included at
`audio/LICENSE-KENNEY-IMPACT-SOUNDS.txt`.
