# Editing game content

The narrative content has one source of truth:

`content/game_content.xlsx`

Do not edit `component_types/GameContent.lua` directly. It is generated from
the workbook.

## Normal workflow

1. Open `content/game_content.xlsx` in Excel, Numbers, or LibreOffice Calc.
2. Edit cells without renaming the three worksheets or their column headers.
3. Save and close the workbook.
4. Double-click `Sync Game Content.command`, or run:

   ```sh
   python3 tools/sync_content.py
   ```

5. Stop and restart Play in PocketEngine so its Lua runtime reloads the data.

The sync command validates IDs, references, ordering, numeric ranges, support
styles, and the number of choices before replacing the generated Lua file. A
failed sync leaves the last working generated file untouched.

## Workbook sheets

- `Chapters`: age, chapter framing, concept text, and starting progress.
- `Moments`: Alex's speech and the prompt shown to the player.
- `Choices`: response labels, parameter changes, support style, result, and
  developmental lesson.

IDs use lowercase letters, numbers, and underscores. They should remain stable
after creation because the other sheets use them as references.

Valid support styles are `responsive`, `fixer`, and `distant`.

Each moment currently supports two to four choices because the room UI and
keyboard controls are designed for a maximum of four.

## Automated check

To validate that the workbook and generated Lua are synchronized without
changing files, run:

```sh
python3 tools/sync_content.py --check
```
