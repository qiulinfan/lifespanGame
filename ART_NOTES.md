# Art notes

The game intentionally uses only two generated illustrations. Both were made
with the built-in OpenAI image-generation tool, then downscaled with macOS
`sips` for a small PocketEngine runtime footprint.

## Runtime assets

- `images/room.png`: 480×270 shared room background, displayed at 2× scale.
- `images/alex_ages.png`: 768×384, one row and three columns for ages 4, 9,
  and 15.
- `images/panel.png`: reusable 1×1 texture used to draw every UI panel, button,
  and status bar.

The larger `*_source.png` files are retained only as editable source material.
They are not loaded by the game.

## Background prompt

> Use case: illustration-story. Asset type: reusable 2D game background for a
> psychology course mini-game. Create a cozy family activity room that can
> plausibly support a preschool block-building scene, a school poster homework
> scene, and a teenage music-practice scene across time. Include a low wooden
> table, bookshelf, potted plant, corkboard, simple toys and art supplies, and a
> guitar near the right wall. Leave the central lower half calm and open. Use
> deliberately low-detail 16-bit pixel art with crisp hard pixel clusters, a
> fixed straight-on 16:9 view, gentle afternoon light, and a warm cream, sage,
> amber, terracotta, and blue-gray palette. No people, text, logos, watermark,
> photorealism, collage, or high-frequency detail.

## Character prompt

> Use case: illustration-story. Asset type: three-cell character portrait
> sprite sheet. Show the same gender-neutral child Alex at age 4, age 9, and
> age 15 in three equal vertical cells. Alex has warm medium skin, short dark
> wavy hair, expressive dark eyes, and sage-green clothing. Age 4 holds a
> wooden block, age 9 holds a pencil and poster, and age 15 holds a guitar pick.
> Use deliberately low-detail 16-bit pixel art, consistent proportions and
> palette, identical camera distance, and one centered waist-up figure per
> cell. Use the same flat muted cream background in every cell. No text,
> borders, gradients, logos, watermark, photorealism, or extra people.

## Font

The bundled Noto Sans font is licensed under the SIL Open Font License 1.1.
The license text is included at `fonts/OFL.txt`.
