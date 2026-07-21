#!/usr/bin/env python3
"""Validate game_content.xlsx and generate PocketEngine Lua content data.

The XLSX reader intentionally uses only the Python standard library so the
content workflow works on a normal macOS Python installation without pip.
"""

from __future__ import annotations

import argparse
import json
import posixpath
import re
import sys
import tempfile
import zipfile
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple
from xml.etree import ElementTree as ET


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_WORKBOOK = PROJECT_ROOT / "content" / "game_content.xlsx"
DEFAULT_OUTPUT = PROJECT_ROOT / "component_types" / "GameContent.lua"

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
DOC_REL_NS = (
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
)
PACKAGE_REL_NS = (
    "http://schemas.openxmlformats.org/package/2006/relationships"
)
NS = {"main": MAIN_NS, "rel": PACKAGE_REL_NS}

SHEET_COLUMNS = {
    "Chapters": {
        "chapter_id",
        "order",
        "age",
        "title",
        "concept",
        "opening",
        "concept_text",
        "start_progress",
    },
    "Moments": {
        "moment_id",
        "chapter_id",
        "order",
        "speech",
        "prompt",
    },
    "Choices": {
        "choice_id",
        "moment_id",
        "order",
        "label",
        "progress",
        "confidence",
        "independence",
        "stress",
        "style",
        "result",
        "lesson",
    },
}

VALID_STYLES = {"responsive", "fixer", "distant"}
ID_PATTERN = re.compile(r"^[a-z][a-z0-9_]*$")


class ContentError(Exception):
    """Raised for an author-facing workbook validation error."""


def _column_index(cell_reference: str) -> int:
    letters = "".join(character for character in cell_reference if character.isalpha())
    result = 0
    for character in letters.upper():
        result = result * 26 + ord(character) - ord("A") + 1
    return result - 1


def _shared_strings(archive: zipfile.ZipFile) -> List[str]:
    path = "xl/sharedStrings.xml"
    if path not in archive.namelist():
        return []
    root = ET.fromstring(archive.read(path))
    values = []
    for item in root.findall("main:si", NS):
        values.append("".join(node.text or "" for node in item.iter(
            f"{{{MAIN_NS}}}t"
        )))
    return values


def _cell_value(cell: ET.Element, shared_strings: Sequence[str]) -> Any:
    cell_type = cell.attrib.get("t", "n")
    if cell_type == "inlineStr":
        return "".join(node.text or "" for node in cell.iter(
            f"{{{MAIN_NS}}}t"
        ))

    value_node = cell.find("main:v", NS)
    if value_node is None or value_node.text is None:
        return ""
    raw_value = value_node.text

    if cell_type == "s":
        index = int(raw_value)
        if index < 0 or index >= len(shared_strings):
            raise ContentError(f"Invalid shared-string index: {index}")
        return shared_strings[index]
    if cell_type in {"str", "e"}:
        return raw_value
    if cell_type == "b":
        return raw_value == "1"

    try:
        number = float(raw_value)
    except ValueError:
        return raw_value
    return int(number) if number.is_integer() else number


def _sheet_rows(
    archive: zipfile.ZipFile,
    sheet_path: str,
    shared_strings: Sequence[str],
) -> List[Tuple[int, List[Any]]]:
    root = ET.fromstring(archive.read(sheet_path))
    rows = []
    for row in root.findall(".//main:sheetData/main:row", NS):
        row_number = int(row.attrib.get("r", len(rows) + 1))
        values: List[Any] = []
        for cell in row.findall("main:c", NS):
            reference = cell.attrib.get("r", "")
            index = _column_index(reference) if reference else len(values)
            while len(values) <= index:
                values.append("")
            values[index] = _cell_value(cell, shared_strings)
        rows.append((row_number, values))
    return rows


def read_workbook(path: Path) -> Dict[str, List[Tuple[int, List[Any]]]]:
    if not path.exists():
        raise ContentError(f"Workbook not found: {path}")
    if not zipfile.is_zipfile(path):
        raise ContentError(f"Not a valid .xlsx workbook: {path}")

    with zipfile.ZipFile(path) as archive:
        try:
            workbook_root = ET.fromstring(archive.read("xl/workbook.xml"))
            relationships_root = ET.fromstring(
                archive.read("xl/_rels/workbook.xml.rels")
            )
        except KeyError as error:
            raise ContentError(f"Incomplete .xlsx workbook: missing {error}") from error

        relationships = {
            node.attrib["Id"]: node.attrib["Target"]
            for node in relationships_root.findall("rel:Relationship", NS)
        }
        shared_strings = _shared_strings(archive)
        result = {}
        for sheet in workbook_root.findall("main:sheets/main:sheet", NS):
            name = sheet.attrib["name"]
            relationship_id = sheet.attrib[f"{{{DOC_REL_NS}}}id"]
            target = relationships.get(relationship_id)
            if target is None:
                raise ContentError(f"Missing worksheet relationship for {name}")
            if target.startswith("/"):
                sheet_path = target.lstrip("/")
            else:
                sheet_path = posixpath.normpath(posixpath.join("xl", target))
            if sheet_path not in archive.namelist():
                raise ContentError(f"Missing worksheet data for {name}")
            result[name] = _sheet_rows(archive, sheet_path, shared_strings)
        return result


def _records(
    sheets: Dict[str, List[Tuple[int, List[Any]]]], sheet_name: str
) -> List[Dict[str, Any]]:
    if sheet_name not in sheets:
        raise ContentError(f"Missing required sheet: {sheet_name}")
    rows = sheets[sheet_name]
    header_position = next(
        (index for index, (_, values) in enumerate(rows) if any(values)), None
    )
    if header_position is None:
        raise ContentError(f"Sheet {sheet_name} is empty")

    _, header_values = rows[header_position]
    headers = [str(value).strip() for value in header_values]
    nonempty_headers = [header for header in headers if header]
    if len(nonempty_headers) != len(set(nonempty_headers)):
        raise ContentError(f"Sheet {sheet_name} contains duplicate column names")

    missing_columns = SHEET_COLUMNS[sheet_name] - set(nonempty_headers)
    if missing_columns:
        names = ", ".join(sorted(missing_columns))
        raise ContentError(f"Sheet {sheet_name} is missing columns: {names}")

    result = []
    for row_number, values in rows[header_position + 1:]:
        if not any(value != "" and value is not None for value in values):
            continue
        record = {"__row__": row_number}
        for index, header in enumerate(headers):
            if header:
                record[header] = values[index] if index < len(values) else ""
        result.append(record)
    return result


def _location(sheet: str, record: Dict[str, Any], column: str) -> str:
    return f"{sheet}!{column} (row {record['__row__']})"


def _text(
    sheet: str, record: Dict[str, Any], column: str, errors: List[str]
) -> str:
    value = record.get(column, "")
    if value is None:
        value = ""
    value = str(value).strip()
    if not value:
        errors.append(f"{_location(sheet, record, column)} cannot be blank")
    return value


def _integer(
    sheet: str,
    record: Dict[str, Any],
    column: str,
    errors: List[str],
    minimum: Optional[int] = None,
    maximum: Optional[int] = None,
) -> int:
    value = record.get(column, "")
    try:
        number = float(value)
        if not number.is_integer():
            raise ValueError
        result = int(number)
    except (TypeError, ValueError):
        errors.append(f"{_location(sheet, record, column)} must be an integer")
        return 0
    if minimum is not None and result < minimum:
        errors.append(
            f"{_location(sheet, record, column)} must be at least {minimum}"
        )
    if maximum is not None and result > maximum:
        errors.append(
            f"{_location(sheet, record, column)} must be at most {maximum}"
        )
    return result


def _identifier(
    sheet: str, record: Dict[str, Any], column: str, errors: List[str]
) -> str:
    value = _text(sheet, record, column, errors)
    if value and not ID_PATTERN.fullmatch(value):
        errors.append(
            f"{_location(sheet, record, column)} must use lowercase letters, "
            "numbers, and underscores"
        )
    return value


def _reject_duplicates(
    items: Iterable[Tuple[str, Dict[str, Any]]], label: str, errors: List[str]
) -> None:
    seen: Dict[str, Dict[str, Any]] = {}
    for identifier, record in items:
        if identifier in seen:
            errors.append(
                f"Duplicate {label} '{identifier}' at rows "
                f"{seen[identifier]['__row__']} and {record['__row__']}"
            )
        else:
            seen[identifier] = record


def build_content(sheets: Dict[str, List[Tuple[int, List[Any]]]]) -> Dict[str, Any]:
    chapter_rows = _records(sheets, "Chapters")
    moment_rows = _records(sheets, "Moments")
    choice_rows = _records(sheets, "Choices")
    errors: List[str] = []

    chapters = []
    for row in chapter_rows:
        chapters.append({
            "id": _identifier("Chapters", row, "chapter_id", errors),
            "order": _integer("Chapters", row, "order", errors, 1),
            "age": _integer("Chapters", row, "age", errors, 1),
            "title": _text("Chapters", row, "title", errors),
            "concept": _text("Chapters", row, "concept", errors),
            "opening": _text("Chapters", row, "opening", errors),
            "concept_text": _text("Chapters", row, "concept_text", errors),
            "start_progress": _integer(
                "Chapters", row, "start_progress", errors, 0, 100
            ),
            "__row__": row,
        })

    moments = []
    for row in moment_rows:
        moments.append({
            "id": _identifier("Moments", row, "moment_id", errors),
            "chapter_id": _identifier("Moments", row, "chapter_id", errors),
            "order": _integer("Moments", row, "order", errors, 1),
            "speech": _text("Moments", row, "speech", errors),
            "prompt": _text("Moments", row, "prompt", errors),
            "__row__": row,
        })

    choices = []
    for row in choice_rows:
        style = _text("Choices", row, "style", errors).lower()
        if style and style not in VALID_STYLES:
            errors.append(
                f"{_location('Choices', row, 'style')} must be one of: "
                + ", ".join(sorted(VALID_STYLES))
            )
        choices.append({
            "id": _identifier("Choices", row, "choice_id", errors),
            "moment_id": _identifier("Choices", row, "moment_id", errors),
            "order": _integer("Choices", row, "order", errors, 1),
            "label": _text("Choices", row, "label", errors),
            "progress": _integer("Choices", row, "progress", errors, -100, 100),
            "confidence": _integer(
                "Choices", row, "confidence", errors, -100, 100
            ),
            "independence": _integer(
                "Choices", row, "independence", errors, -100, 100
            ),
            "stress": _integer("Choices", row, "stress", errors, -100, 100),
            "style": style,
            "result": _text("Choices", row, "result", errors),
            "lesson": _text("Choices", row, "lesson", errors),
            "__row__": row,
        })

    _reject_duplicates(
        ((item["id"], item["__row__"]) for item in chapters),
        "chapter_id",
        errors,
    )
    _reject_duplicates(
        ((item["id"], item["__row__"]) for item in moments),
        "moment_id",
        errors,
    )
    _reject_duplicates(
        ((item["id"], item["__row__"]) for item in choices),
        "choice_id",
        errors,
    )

    chapter_ids = {item["id"] for item in chapters}
    moment_ids = {item["id"] for item in moments}
    for moment in moments:
        if moment["chapter_id"] not in chapter_ids:
            row = moment["__row__"]
            errors.append(
                f"Moments!chapter_id (row {row['__row__']}) references unknown "
                f"chapter '{moment['chapter_id']}'"
            )
    for choice in choices:
        if choice["moment_id"] not in moment_ids:
            row = choice["__row__"]
            errors.append(
                f"Choices!moment_id (row {row['__row__']}) references unknown "
                f"moment '{choice['moment_id']}'"
            )

    chapter_orders = [item["order"] for item in chapters]
    if len(chapter_orders) != len(set(chapter_orders)):
        errors.append("Chapters!order values must be unique")

    for chapter in chapters:
        children = [
            item for item in moments if item["chapter_id"] == chapter["id"]
        ]
        orders = [item["order"] for item in children]
        if not children:
            errors.append(f"Chapter '{chapter['id']}' has no moments")
        elif len(orders) != len(set(orders)):
            errors.append(f"Moment order values in chapter '{chapter['id']}' must be unique")

    for moment in moments:
        children = [
            item for item in choices if item["moment_id"] == moment["id"]
        ]
        orders = [item["order"] for item in children]
        if not 2 <= len(children) <= 4:
            errors.append(
                f"Moment '{moment['id']}' must have between 2 and 4 choices"
            )
        elif len(orders) != len(set(orders)):
            errors.append(f"Choice order values in moment '{moment['id']}' must be unique")

    if errors:
        raise ContentError("Workbook validation failed:\n- " + "\n- ".join(errors))

    result_chapters = []
    for chapter in sorted(chapters, key=lambda item: item["order"]):
        result_chapter = {
            key: chapter[key]
            for key in (
                "id",
                "age",
                "title",
                "concept",
                "opening",
                "concept_text",
                "start_progress",
            )
        }
        result_moments = []
        chapter_moments = sorted(
            (
                item
                for item in moments
                if item["chapter_id"] == chapter["id"]
            ),
            key=lambda item: item["order"],
        )
        for moment in chapter_moments:
            result_moment = {
                key: moment[key] for key in ("id", "speech", "prompt")
            }
            moment_choices = sorted(
                (
                    item
                    for item in choices
                    if item["moment_id"] == moment["id"]
                ),
                key=lambda item: item["order"],
            )
            result_moment["actions"] = [
                {
                    key: choice[key]
                    for key in (
                        "id",
                        "label",
                        "progress",
                        "confidence",
                        "independence",
                        "stress",
                        "style",
                        "result",
                        "lesson",
                    )
                }
                for choice in moment_choices
            ]
            result_moments.append(result_moment)
        result_chapter["moments"] = result_moments
        result_chapters.append(result_chapter)
    return {"chapters": result_chapters}


def _lua_value(value: Any, indent: int = 0) -> str:
    prefix = " " * indent
    child_prefix = " " * (indent + 4)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, list):
        if not value:
            return "{}"
        lines = ["{"]
        for item in value:
            rendered = _lua_value(item, indent + 4)
            lines.append(f"{child_prefix}{rendered},")
        lines.append(f"{prefix}}}")
        return "\n".join(lines)
    if isinstance(value, dict):
        if not value:
            return "{}"
        lines = ["{"]
        for key, item in value.items():
            rendered = _lua_value(item, indent + 4)
            lines.append(f"{child_prefix}{key} = {rendered},")
        lines.append(f"{prefix}}}")
        return "\n".join(lines)
    raise TypeError(f"Cannot convert {type(value).__name__} to Lua")


def render_lua(content: Dict[str, Any]) -> str:
    header = (
        "-- AUTO-GENERATED from content/game_content.xlsx.\n"
        "-- Edit the workbook, then run: python3 tools/sync_content.py\n"
        "-- Do not edit this file by hand.\n\n"
    )
    return header + "GameContent = " + _lua_value(content) + "\n"


def write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as temporary_file:
        temporary_file.write(content)
        temporary_path = Path(temporary_file.name)
    temporary_path.replace(path)


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate the Excel content workbook and generate Lua data."
    )
    parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate and fail if the generated Lua file is out of date.",
    )
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    try:
        sheets = read_workbook(arguments.workbook)
        content = build_content(sheets)
        generated = render_lua(content)
        chapter_count = len(content["chapters"])
        moment_count = sum(len(chapter["moments"]) for chapter in content["chapters"])
        choice_count = sum(
            len(moment["actions"])
            for chapter in content["chapters"]
            for moment in chapter["moments"]
        )

        if arguments.check:
            current = (
                arguments.output.read_text(encoding="utf-8")
                if arguments.output.exists()
                else ""
            )
            if current != generated:
                raise ContentError(
                    "Generated content is out of date. Run: "
                    "python3 tools/sync_content.py"
                )
            action = "Checked"
        else:
            write_atomic(arguments.output, generated)
            action = "Synced"

        print(
            f"{action} {chapter_count} chapters, {moment_count} moments, "
            f"and {choice_count} choices."
        )
        return 0
    except (ContentError, ET.ParseError, zipfile.BadZipFile) as error:
        print(f"Content sync failed:\n{error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
