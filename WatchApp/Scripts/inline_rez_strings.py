#!/usr/bin/env python3

from __future__ import annotations

import argparse
import difflib
import json
import re
import sys
from collections.abc import Callable
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Any, cast


EXPANDED_LITERAL_START = "\uFFF0"
EXPANDED_LITERAL_END = "\uFFF1"
DEFAULT_CONFIG_PATH = Path("Scripts/inline_rez_strings.jsonc")


@dataclass(frozen=True)
class InlineRezConfig:
    string_value_include_globs: tuple[str, ...]
    string_value_excluded_dir_names: tuple[str, ...]
    string_value_allowed_path_substrings: tuple[str, ...]
    string_value_excluded_path_substrings: tuple[str, ...]
    string_value_conflict_tolerant_path_substrings: tuple[str, ...]
    non_code_reference_patterns: tuple[str, ...]
    non_code_reference_excluded_dir_names: tuple[str, ...]
    strings_xml_patterns: tuple[str, ...]
    string_only_resource_patterns: tuple[str, ...]


@dataclass(frozen=True)
class DiscoveredStrings:
    inline_values: dict[str, str]
    available_ids: set[str]


def eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def _load_string_sequence(raw: object, field_name: str) -> tuple[str, ...]:
    if not isinstance(raw, list) or not all(isinstance(item, str) for item in raw):
        raise ValueError(f"{field_name} must be an array of strings")
    return tuple(cast(list[str], raw))


def _strip_json_comments(text: str) -> str:
    result: list[str] = []
    index = 0
    in_string = False
    escape_next = False

    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""

        if in_string:
            result.append(ch)
            if escape_next:
                escape_next = False
            elif ch == "\\":
                escape_next = True
            elif ch == '"':
                in_string = False
            index += 1
            continue

        if ch == '"':
            in_string = True
            result.append(ch)
            index += 1
            continue

        if ch == "/" and nxt == "/":
            index += 2
            while index < len(text) and text[index] != "\n":
                index += 1
            continue

        if ch == "/" and nxt == "*":
            index += 2
            while index + 1 < len(text) and not (
                text[index] == "*" and text[index + 1] == "/"
            ):
                index += 1
            index = min(index + 2, len(text))
            continue

        result.append(ch)
        index += 1

    return "".join(result)


def load_config(config_path: Path) -> InlineRezConfig:
    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found: {config_path}")

    raw = json.loads(_strip_json_comments(config_path.read_text(encoding="utf-8")))
    if not isinstance(raw, dict):
        raise ValueError("inline_rez_strings config must be a JSON object")
    raw_config = cast(dict[str, Any], raw)

    return InlineRezConfig(
        string_value_include_globs=_load_string_sequence(
            raw_config.get("string_value_include_globs"),
            "string_value_include_globs",
        ),
        string_value_excluded_dir_names=_load_string_sequence(
            raw_config.get("string_value_excluded_dir_names"),
            "string_value_excluded_dir_names",
        ),
        string_value_allowed_path_substrings=_load_string_sequence(
            raw_config.get("string_value_allowed_path_substrings"),
            "string_value_allowed_path_substrings",
        ),
        string_value_excluded_path_substrings=_load_string_sequence(
            raw_config.get("string_value_excluded_path_substrings"),
            "string_value_excluded_path_substrings",
        ),
        string_value_conflict_tolerant_path_substrings=_load_string_sequence(
            raw_config.get("string_value_conflict_tolerant_path_substrings"),
            "string_value_conflict_tolerant_path_substrings",
        ),
        non_code_reference_patterns=_load_string_sequence(
            raw_config.get("non_code_reference_patterns"),
            "non_code_reference_patterns",
        ),
        non_code_reference_excluded_dir_names=_load_string_sequence(
            raw_config.get("non_code_reference_excluded_dir_names"),
            "non_code_reference_excluded_dir_names",
        ),
        strings_xml_patterns=_load_string_sequence(
            raw_config.get("strings_xml_patterns"),
            "strings_xml_patterns",
        ),
        string_only_resource_patterns=_load_string_sequence(
            raw_config.get("string_only_resource_patterns"),
            "string_only_resource_patterns",
        ),
    )


def _xml_text_normalized(elem: ET.Element) -> str:
    text = "".join(elem.itertext())
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    return text.strip()


def _is_localized_resources_dir(name: str) -> bool:
    return name.startswith("resources-") and len(name) > len("resources-")


def _is_selected_localized_resources_dir(name: str, language: str) -> bool:
    return name == f"resources-{language}"


def _collect_known_languages(repo_root: Path) -> set[str]:
    languages: set[str] = set()
    for path in repo_root.glob("resources-*"):
        if path.is_dir():
            suffix = path.name[len("resources-") :]
            if suffix:
                languages.add(suffix)
    for path in repo_root.glob("local/resources-*"):
        if path.is_dir():
            suffix = path.name[len("resources-") :]
            if suffix:
                languages.add(suffix)
    return languages


def _get_localized_trait_language(parts: tuple[str, ...], known_languages: set[str]) -> str | None:
    for index, part in enumerate(parts[:-1]):
        if part != "traits":
            continue
        candidate = parts[index + 1]
        base, separator, suffix = candidate.rpartition("-")
        if separator and base and suffix in known_languages:
            return suffix
    return None


def discover_string_values(
    repo_root: Path,
    language: str,
    config: InlineRezConfig,
) -> DiscoveredStrings:
    include_globs = config.string_value_include_globs
    excluded_dir_names = set(config.string_value_excluded_dir_names)
    known_languages = _collect_known_languages(repo_root)

    inline_values: dict[str, str] = {}
    available_ids: set[str] = set()
    for pattern in include_globs:
        for path in repo_root.glob(pattern):
            if not path.is_file():
                continue
            normalized = "/".join(path.parts)
            is_allowed_path = any(
                substring in normalized
                for substring in config.string_value_allowed_path_substrings
            )
            if (
                any(part in excluded_dir_names for part in path.parts)
                and not is_allowed_path
            ):
                continue
            if any(
                substring in normalized
                for substring in config.string_value_excluded_path_substrings
            ):
                continue

            localized_parts = [part for part in path.parts if _is_localized_resources_dir(part)]
            localized_trait_language = _get_localized_trait_language(path.parts, known_languages)
            if localized_parts:
                if language == "eng":
                    continue
                if not all(_is_selected_localized_resources_dir(part, language) for part in localized_parts):
                    continue
            if localized_trait_language is not None:
                if language == "eng":
                    continue
                if localized_trait_language != language:
                    continue

            try:
                tree = ET.parse(path)
            except ET.ParseError:
                continue

            root = tree.getroot()
            for elem in root.iter("string"):
                string_id = elem.attrib.get("id")
                if not string_id:
                    continue
                available_ids.add(string_id)
                value = _xml_text_normalized(elem)
                existing = inline_values.get(string_id)
                if existing is None:
                    inline_values[string_id] = value
                elif localized_parts or localized_trait_language is not None:
                    inline_values[string_id] = value
                elif existing != value:
                    if any(
                        substring in normalized
                        for substring in config.string_value_conflict_tolerant_path_substrings
                    ):
                        inline_values.pop(string_id, None)
                        continue
                    raise ValueError(
                        f"Conflicting values for string id {string_id!r}: {existing!r} vs {value!r} in {path}"
                    )
    return DiscoveredStrings(inline_values=inline_values, available_ids=available_ids)


def strip_manifest_languages(text: str, language: str) -> tuple[str, int]:
    pattern = re.compile(r"(<iq:languages>\n)(.*?)([ \t]*</iq:languages>)", re.DOTALL)
    match = pattern.search(text)
    if match is None:
        return text, 0

    body = match.group(2)
    kept_lines: list[str] = []
    removed = 0
    for line in body.splitlines(keepends=True):
        language_match = re.search(r"<iq:language>([^<]+)</iq:language>", line)
        if language_match is None:
            kept_lines.append(line)
            continue
        if language_match.group(1) == language:
            kept_lines.append(line)
        else:
            removed += 1

    replacement = match.group(1) + "".join(kept_lines) + match.group(3)
    updated = text[:match.start()] + replacement + text[match.end():]
    return updated, removed


def monkey_string_literal(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\t", "\\t")
        .replace("\n", "\\n")
    )
    return f'"{escaped}"'


def marked_expanded_literal(value: str) -> str:
    return f"{EXPANDED_LITERAL_START}{monkey_string_literal(value)}{EXPANDED_LITERAL_END}"


def monkey_string_value(literal: str) -> str | None:
    if len(literal) < 2 or literal[0] != '"' or literal[-1] != '"':
        return None
    out: list[str] = []
    index = 1
    end = len(literal) - 1
    while index < end:
        ch = literal[index]
        if ch != "\\":
            out.append(ch)
            index += 1
            continue
        index += 1
        if index >= end:
            return None
        escaped = literal[index]
        if escaped == "n":
            out.append("\n")
        elif escaped == "t":
            out.append("\t")
        elif escaped in ('"', "\\"):
            out.append(escaped)
        else:
            return None
        index += 1
    return "".join(out)


def marked_expanded_literal_value(expr: str) -> str | None:
    stripped = expr.strip()
    if not stripped.startswith(EXPANDED_LITERAL_START) or not stripped.endswith(EXPANDED_LITERAL_END):
        return None
    inner = stripped[len(EXPANDED_LITERAL_START):-len(EXPANDED_LITERAL_END)]
    if not inner:
        return None
    if monkey_string_value(inner) is None:
        return None
    return inner


def parse_marked_expanded_literal(text: str, index: int) -> tuple[int, int, int] | None:
    if not text.startswith(EXPANDED_LITERAL_START, index):
        return None
    literal_start = index + len(EXPANDED_LITERAL_START)
    if literal_start >= len(text) or text[literal_start] != '"':
        return None
    literal_end = skip_string(text, literal_start)
    if not text.startswith(EXPANDED_LITERAL_END, literal_end):
        return None
    marked_end = literal_end + len(EXPANDED_LITERAL_END)
    return literal_start, literal_end, marked_end


def unmark_expanded_literals(text: str) -> str:
    return text.replace(EXPANDED_LITERAL_START, "").replace(EXPANDED_LITERAL_END, "")


def is_ident_char(ch: str) -> bool:
    return ch.isalnum() or ch == "_"


def previous_word(text: str, index: int) -> str:
    pos = index - 1
    while pos >= 0 and text[pos].isspace():
        pos -= 1
    end = pos + 1
    while pos >= 0 and is_ident_char(text[pos]):
        pos -= 1
    return text[pos + 1:end]


def skip_string(text: str, index: int) -> int:
    quote = text[index]
    index += 1
    while index < len(text):
        ch = text[index]
        if ch == "\\":
            index += 2
            continue
        if ch == quote:
            return index + 1
        index += 1
    return len(text)


def skip_line_comment(text: str, index: int) -> int:
    newline = text.find("\n", index)
    if newline == -1:
        return len(text)
    return newline + 1


def skip_block_comment(text: str, index: int) -> int:
    end = text.find("*/", index + 2)
    if end == -1:
        return len(text)
    return end + 2


def find_matching_paren(text: str, open_index: int) -> int | None:
    depth = 1
    index = open_index + 1
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return index
        index += 1
    return None


def split_top_level_args(text: str) -> list[str]:
    args: list[str] = []
    start = 0
    paren_depth = 0
    bracket_depth = 0
    brace_depth = 0
    index = 0
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if ch == "(":
            paren_depth += 1
        elif ch == ")":
            paren_depth -= 1
        elif ch == "[":
            bracket_depth += 1
        elif ch == "]":
            bracket_depth -= 1
        elif ch == "{":
            brace_depth += 1
        elif ch == "}":
            brace_depth -= 1
        elif ch == "," and paren_depth == 0 and bracket_depth == 0 and brace_depth == 0:
            args.append(text[start:index].strip())
            start = index + 1
        index += 1
    tail = text[start:].strip()
    if tail or args:
        args.append(tail)
    return args


def replace_calls(
    text: str,
    name: str,
    replacer: Callable[[str], str | None],
) -> tuple[str, int]:
    pieces: list[str] = []
    last = 0
    index = 0
    replacements = 0
    name_len = len(name)
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if text.startswith(name, index):
            before_ok = index == 0 or not is_ident_char(text[index - 1])
            after_index = index + name_len
            after_ok = after_index >= len(text) or not is_ident_char(text[after_index])
            if before_ok and after_ok and previous_word(text, index) != "function":
                call_start = after_index
                while call_start < len(text) and text[call_start].isspace():
                    call_start += 1
                if call_start < len(text) and text[call_start] == "(":
                    call_end = find_matching_paren(text, call_start)
                    if call_end is not None:
                        args_text = text[call_start + 1:call_end]
                        replacement = replacer(args_text)
                        if replacement is not None:
                            pieces.append(text[last:index])
                            pieces.append(replacement)
                            last = call_end + 1
                            index = call_end + 1
                            replacements += 1
                            continue
        index += 1
    pieces.append(text[last:])
    return "".join(pieces), replacements


def qualified_name_start(text: str, index: int) -> int:
    start = index
    while start > 0:
        pos = start - 1
        while pos >= 0 and text[pos].isspace():
            pos -= 1
        if pos < 0 or text[pos] != ".":
            break
        pos -= 1
        while pos >= 0 and is_ident_char(text[pos]):
            pos -= 1
        identifier_start = pos + 1
        if identifier_start == start - 1:
            break
        start = identifier_start
    return start


def replace_load_resource_calls(text: str, string_values: dict[str, str]) -> tuple[str, int, list[str], set[str]]:
    pieces: list[str] = []
    warnings: list[str] = []
    replaced_ids: set[str] = set()
    last = 0
    index = 0
    replacements = 0
    name = "loadResource"
    name_len = len(name)
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if text.startswith(name, index):
            before_ok = index == 0 or not is_ident_char(text[index - 1])
            after_index = index + name_len
            after_ok = after_index >= len(text) or not is_ident_char(text[after_index])
            if before_ok and after_ok and previous_word(text, index) != "function":
                call_start = after_index
                while call_start < len(text) and text[call_start].isspace():
                    call_start += 1
                if call_start < len(text) and text[call_start] == "(":
                    call_end = find_matching_paren(text, call_start)
                    if call_end is not None:
                        args = split_top_level_args(text[call_start + 1:call_end])
                        if len(args) == 1:
                            argument = args[0].strip()
                            if argument.startswith("Rez.Strings."):
                                string_id = argument[len("Rez.Strings."):]
                                if string_id in string_values:
                                    full_start = qualified_name_start(text, index)
                                    pieces.append(text[last:full_start])
                                    pieces.append(marked_expanded_literal(string_values[string_id]))
                                    replaced_ids.add(string_id)
                                    last = call_end + 1
                                    index = call_end + 1
                                    replacements += 1
                                    continue
                                warnings.append(f"Skipped loadResource({argument})")
        index += 1
    pieces.append(text[last:])
    return "".join(pieces), replacements, warnings, replaced_ids


def replace_string_or_resource_typedef(text: str) -> tuple[str, int]:
    pattern = re.compile(
        r"typedef\s+StringOrResource\s+as\s+Lang\.String\s*\|\s*Lang\.ResourceId\s*;"
    )
    updated, count = pattern.subn("typedef StringOrResource as Lang.String;", text)
    return updated, count


def find_function_definition_span(text: str, name: str) -> tuple[int, int] | None:
    match = re.search(rf"(^|\n)([ \t]*function\s+{name}\s*\()", text)
    if match is None:
        return None

    function_start = match.start(2)
    brace_open = text.find("{", function_start)
    if brace_open == -1:
        return None

    brace_depth = 1
    index = brace_open + 1
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if ch == "{":
            brace_depth += 1
        elif ch == "}":
            brace_depth -= 1
            if brace_depth == 0:
                index += 1
                while index < len(text) and text[index] in " \t":
                    index += 1
                if index < len(text) and text[index] == "\n":
                    index += 1
                return function_start, index
        index += 1
    return None


def replace_join_components_definition(text: str) -> tuple[str, int]:
    span = find_function_definition_span(text, "joinComponents")
    if span is None:
        return text, 0

    start, end = span
    replacement = (
        "function joinComponents(components as Lang.Array<StringOrResource>, separator as Lang.String) as Lang.String {\n"
        "    if (components.size() == 0) {\n"
        '        return "";\n'
        "    }\n"
        "    var result = components[0];\n"
        "    var size = components.size();\n"
        "    for (var i = 1; i < size; i++) {\n"
        "        var component = components[i];\n"
        "        result += separator + component;\n"
        "    }\n"
        "    return result;\n"
        "}\n"
    )
    if text[start:end] == replacement:
        return text, 0
    return text[:start] + replacement + text[end:], 1


def remove_helper_definitions(text: str) -> tuple[str, int]:
    removed = 0
    for name in ("loadIfResource", "formatIfResources", "joinNonNullComponents"):
        while True:
            match = re.search(rf"(^|\n)([ \t]*function\s+{name}\s*\()", text)
            if match is None:
                break

            function_start = match.start(2)
            removal_start = function_start
            while True:
                previous_newline = text.rfind("\n", 0, removal_start - 1)
                line_start = 0 if previous_newline == -1 else previous_newline + 1
                candidate = text[line_start:removal_start]
                if re.fullmatch(r"[ \t]*\(:[^\n]*\)\n", candidate):
                    removal_start = line_start
                    continue
                break

            brace_open = text.find("{", function_start)
            if brace_open == -1:
                break

            brace_depth = 1
            index = brace_open + 1
            while index < len(text):
                ch = text[index]
                nxt = text[index + 1] if index + 1 < len(text) else ""
                if ch in ('"', "'"):
                    index = skip_string(text, index)
                    continue
                if ch == "/" and nxt == "/":
                    index = skip_line_comment(text, index)
                    continue
                if ch == "/" and nxt == "*":
                    index = skip_block_comment(text, index)
                    continue
                if ch == "{":
                    brace_depth += 1
                elif ch == "}":
                    brace_depth -= 1
                    if brace_depth == 0:
                        index += 1
                        break
                index += 1

            removal_end = index
            while removal_end < len(text) and text[removal_end] in " \t":
                removal_end += 1
            if removal_end < len(text) and text[removal_end] == "\n":
                removal_end += 1

            text = text[:removal_start] + text[removal_end:]
            removed += 1

    return text, removed


def parse_array_literal(expr: str) -> list[str] | None:
    stripped = expr.strip()
    if not stripped.startswith("[") or not stripped.endswith("]"):
        return None
    return split_top_level_args(stripped[1:-1])


def strip_wrapping_parens(expr: str) -> str:
    stripped = expr.strip()
    while stripped.startswith("(") and stripped.endswith(")"):
        closing = find_matching_paren(stripped, 0)
        if closing != len(stripped) - 1:
            break
        stripped = stripped[1:-1].strip()
    return stripped


def expression_is_known_string(expr: str) -> bool:
    stripped = strip_wrapping_parens(expr)
    if marked_expanded_literal_value(stripped) is not None:
        return True
    if monkey_string_value(stripped) is not None:
        return True
    if re.search(r"\bas\s+(Lang\.String|StringOrResource)\b", stripped):
        return True
    if re.search(r"\.(toUpper|toLower)\s*\(\s*\)$", stripped):
        return True
    return False


def expression_needs_parentheses_in_concatenation(expr: str) -> bool:
    stripped = expr.strip()
    if not stripped:
        return False
    if stripped.startswith("(") and find_matching_paren(stripped, 0) == len(stripped) - 1:
        return False
    if stripped[0] in "[{":
        return True

    depth = 0
    bracket_depth = 0
    brace_depth = 0
    index = 0
    saw_top_level_whitespace = False
    while index < len(stripped):
        ch = stripped[index]
        nxt = stripped[index + 1] if index + 1 < len(stripped) else ""
        if ch == '"' or ch == "'":
            index = skip_string(stripped, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(stripped, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(stripped, index)
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif ch == "[":
            bracket_depth += 1
        elif ch == "]":
            bracket_depth -= 1
        elif ch == "{":
            brace_depth += 1
        elif ch == "}":
            brace_depth -= 1
        elif depth == 0 and bracket_depth == 0 and brace_depth == 0:
            if ch in "+-*/%?:<>=!&|^":
                return True
            if ch.isspace():
                saw_top_level_whitespace = True
        index += 1
    return saw_top_level_whitespace


def parenthesize_for_concatenation(expr: str) -> str:
    stripped = expr.strip()
    if expression_needs_parentheses_in_concatenation(stripped):
        return f"({stripped})"
    return stripped


def remove_string_literal_casts(text: str) -> tuple[str, int]:
    pieces: list[str] = []
    last = 0
    index = 0
    removed = 0
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        parsed_literal = parse_marked_expanded_literal(text, index)
        if parsed_literal is None:
            index += 1
            continue

        _literal_start, _literal_end, marked_end = parsed_literal
        cast_start = marked_end
        while cast_start < len(text) and text[cast_start].isspace():
            cast_start += 1
        if not text.startswith("as", cast_start):
            index = marked_end
            continue
        cast_type_start = cast_start + 2
        if cast_type_start < len(text) and is_ident_char(text[cast_type_start]):
            index = marked_end
            continue
        while cast_type_start < len(text) and text[cast_type_start].isspace():
            cast_type_start += 1
        if not text.startswith("Lang.String", cast_type_start):
            index = marked_end
            continue

        cast_end = cast_type_start + len("Lang.String")
        if cast_end < len(text) and is_ident_char(text[cast_end]):
            index = marked_end
            continue

        wrapped_start = index
        wrapped_end = cast_end

        before = index - 1
        while before >= 0 and text[before].isspace():
            before -= 1
        if before >= 0 and text[before] == "(":
            between_open_and_literal = text[before + 1:index]
            after_cast = cast_end
            while after_cast < len(text) and text[after_cast].isspace():
                after_cast += 1
            if between_open_and_literal.strip() == "" and after_cast < len(text) and text[after_cast] == ")":
                wrapped_start = before
                wrapped_end = after_cast + 1

        pieces.append(text[last:wrapped_start])
        pieces.append(text[index:marked_end])
        last = wrapped_end
        index = cast_end
        removed += 1
    pieces.append(text[last:])
    return "".join(pieces), removed


def remove_wrapped_string_literal_parens(text: str) -> tuple[str, int]:
    return text, 0


def format_to_concatenation(format_expr: str, args_expr: str) -> str | None:
    format_literal = format_expr.strip()
    format_value = monkey_string_value(format_literal)
    if format_value is None:
        marked_literal = marked_expanded_literal_value(format_literal)
        if marked_literal is not None:
            format_value = monkey_string_value(marked_literal)
    if format_value is None:
        return None
    args = parse_array_literal(args_expr)
    if args is None:
        return None

    pieces: list[str] = []
    last = 0
    for match in re.finditer(r"\$(\d+)\$", format_value):
        literal = format_value[last:match.start()]
        if literal:
            pieces.append(monkey_string_literal(literal))
        argument_index = int(match.group(1)) - 1
        if argument_index < 0 or argument_index >= len(args):
            return None
        argument = args[argument_index].strip()
        if not argument:
            return None
        pieces.append(parenthesize_for_concatenation(argument))
        last = match.end()
    trailing = format_value[last:]
    if trailing:
        pieces.append(monkey_string_literal(trailing))

    if not pieces:
        return monkey_string_literal(format_value)

    compacted = [piece for piece in pieces if piece != '""']
    if not compacted:
        return '""'
    return " + ".join(compacted)


def join_components_to_expression(
    components_expr: str, separator_expr: str
) -> str | None:
    def as_lang_string(expr: str) -> str:
        return f"({expr}) as Lang.String"

    components = parse_array_literal(components_expr)
    if components is None:
        return None
    if len(components) == 0:
        return as_lang_string('""')
    if len(components) == 1:
        component = components[0].strip()
        if not component:
            return None
        return as_lang_string(component)

    separator = separator_expr.strip()
    if not separator:
        return None

    compacted = [component.strip() for component in components]
    if any(not component for component in compacted):
        return None

    pieces: list[str] = []
    for index, component in enumerate(compacted):
        if index > 0:
            pieces.append(separator)
        pieces.append(component)

    return as_lang_string(" + ".join(pieces))


def join_non_null_components_to_expression(
    components_expr: str, separator_expr: str
) -> str | None:
    def as_lang_string(expr: str) -> str:
        return f"({expr}) as Lang.String"

    components = parse_array_literal(components_expr)
    if components is None:
        return None
    if len(components) == 0:
        return as_lang_string('""')
    if len(components) == 1:
        component = components[0].strip()
        if not component:
            return None
        if expression_is_known_string(component):
            return as_lang_string(component)
        return as_lang_string(f'({component} == null ? "" : {component})')
    if len(components) != 2:
        return None

    left = components[0].strip()
    right = components[1].strip()
    separator = separator_expr.strip()
    if not left or not right or not separator:
        return None

    left_is_string = expression_is_known_string(left)
    right_is_string = expression_is_known_string(right)

    if left_is_string and right_is_string:
        return as_lang_string(f"{left} + {separator} + {right}")
    if left_is_string:
        return as_lang_string(f'({right} == null ? {left} : {left} + {separator} + {right})')
    if right_is_string:
        return as_lang_string(f'({left} == null ? {right} : {left} + {separator} + {right})')

    return as_lang_string(
        f'({left} == null ? ({right} == null ? "" : {right})'
        f" : ({right} == null ? {left} : {left} + {separator} + {right}))"
    )


def replace_rez_strings(text: str, string_values: dict[str, str]) -> tuple[str, int, set[str]]:
    pieces: list[str] = []
    last = 0
    index = 0
    replacements = 0
    replaced_ids: set[str] = set()
    prefix = "Rez.Strings."
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if text.startswith(prefix, index):
            ident_start = index + len(prefix)
            ident_end = ident_start
            while ident_end < len(text) and is_ident_char(text[ident_end]):
                ident_end += 1
            string_id = text[ident_start:ident_end]
            if string_id in string_values:
                pieces.append(text[last:index])
                pieces.append(marked_expanded_literal(string_values[string_id]))
                replaced_ids.add(string_id)
                last = ident_end
                index = ident_end
                replacements += 1
                continue
        index += 1
    pieces.append(text[last:])
    return "".join(pieces), replacements, replaced_ids


def collect_referenced_string_ids(text: str) -> set[str]:
    found: set[str] = set()
    index = 0
    prefix = "Rez.Strings."
    while index < len(text):
        ch = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if ch in ('"', "'"):
            index = skip_string(text, index)
            continue
        if ch == "/" and nxt == "/":
            index = skip_line_comment(text, index)
            continue
        if ch == "/" and nxt == "*":
            index = skip_block_comment(text, index)
            continue
        if text.startswith(prefix, index):
            ident_start = index + len(prefix)
            ident_end = ident_start
            while ident_end < len(text) and is_ident_char(text[ident_end]):
                ident_end += 1
            string_id = text[ident_start:ident_end]
            if string_id:
                found.add(string_id)
            index = ident_end
            continue
        index += 1
    return found


def find_missing_string_ids(text: str, string_values: dict[str, str]) -> set[str]:
    return collect_referenced_string_ids(text) - set(string_values)


def find_missing_available_string_ids(text: str, available_ids: set[str]) -> set[str]:
    return collect_referenced_string_ids(text) - available_ids


def collect_non_code_referenced_string_ids(text: str) -> set[str]:
    return set(re.findall(r"@Strings\.([A-Za-z0-9_]+)", text))


def iter_non_code_reference_files(
    repo_root: Path, config: InlineRezConfig
) -> list[Path]:
    patterns = config.non_code_reference_patterns
    excluded_dir_names = set(config.non_code_reference_excluded_dir_names)
    paths: list[Path] = []
    for pattern in patterns:
        paths.extend(repo_root.glob(pattern))
    return sorted(
        path
        for path in paths
        if path.is_file() and not any(part in excluded_dir_names for part in path.parts)
    )


def remove_strings_xml_entries(text: str, ids_to_remove: set[str]) -> tuple[str, int]:
    if not ids_to_remove:
        return text, 0

    lines = text.splitlines(keepends=True)
    kept: list[str] = []
    index = 0
    removed = 0
    while index < len(lines):
        line = lines[index]
        if "<string" not in line:
            kept.append(line)
            index += 1
            continue

        block = line
        index += 1
        while "</string>" not in block and index < len(lines):
            block += lines[index]
            index += 1

        match = re.search(r'\bid="([^"]+)"', block)
        if match is not None and match.group(1) in ids_to_remove:
            removed += 1
            continue

        kept.append(block)

    return "".join(kept), removed


def discover_strings_xml_paths(repo_root: Path, config: InlineRezConfig) -> list[Path]:
    paths: list[Path] = []
    for pattern in config.strings_xml_patterns:
        paths.extend(sorted(repo_root.glob(pattern)))
    return [path for path in paths if path.exists()]


def discover_string_only_resource_paths(
    repo_root: Path, config: InlineRezConfig
) -> list[Path]:
    patterns = config.string_only_resource_patterns
    paths: list[Path] = []
    for pattern in patterns:
        paths.extend(sorted(repo_root.glob(pattern)))
    return [path for path in paths if path.exists()]


def string_only_resource_language(repo_root: Path, path: Path) -> str:
    parts = path.relative_to(repo_root).parts
    resources_dir = parts[1] if parts[0] == "local" else parts[0]
    if resources_dir == "resources":
        return "eng"
    return resources_dir.removeprefix("resources-")


def collect_xml_string_ids(text: str) -> set[str]:
    return set(re.findall(r'\bid="([^"]+)"', text))


def transform_text(text: str, string_values: dict[str, str]) -> tuple[str, dict[str, int], list[str], set[str]]:
    counts = {
        "StringOrResource": 0,
        "loadResource": 0,
        "loadIfResource": 0,
        "formatIfResources": 0,
        "joinComponents": 0,
        "joinNonNullComponents": 0,
        "joinHelperDefinitions": 0,
        "helperDefinitions": 0,
        "literalStringCasts": 0,
        "literalStringParens": 0,
        "Lang.format": 0,
        "Rez.Strings": 0,
    }
    warnings: list[str] = []
    replaced_string_ids: set[str] = set()

    def replace_load_if_resource(args_text: str) -> str | None:
        args = split_top_level_args(args_text)
        if len(args) != 1 or not args[0]:
            warnings.append(f"Skipped loadIfResource({args_text})")
            return None
        return args[0]

    def replace_format_if_resources(args_text: str) -> str | None:
        args = split_top_level_args(args_text)
        if len(args) != 2 or not args[0] or not args[1]:
            warnings.append(f"Skipped formatIfResources({args_text})")
            return None
        return f"Lang.format({args[0]}, {args[1]})"

    def replace_lang_format(args_text: str) -> str | None:
        args = split_top_level_args(args_text)
        if len(args) != 2 or not args[0] or not args[1]:
            warnings.append(f"Skipped Lang.format({args_text})")
            return None
        return format_to_concatenation(args[0], args[1])

    def replace_join_components(args_text: str) -> str | None:
        args = split_top_level_args(args_text)
        if len(args) != 2 or not args[0] or not args[1]:
            warnings.append(f"Skipped joinComponents({args_text})")
            return None
        replacement = join_components_to_expression(args[0], args[1])
        if replacement is None:
            return None
        return replacement

    def replace_join_non_null_components(args_text: str) -> str | None:
        args = split_top_level_args(args_text)
        if len(args) != 2 or not args[0] or not args[1]:
            warnings.append(f"Skipped joinNonNullComponents({args_text})")
            return None
        replacement = join_non_null_components_to_expression(args[0], args[1])
        if replacement is None:
            return None
        return replacement

    while True:
        changed = 0

        text, replaced = replace_string_or_resource_typedef(text)
        counts["StringOrResource"] += replaced
        changed += replaced

        text, replaced, call_warnings, call_ids = replace_load_resource_calls(text, string_values)
        counts["loadResource"] += replaced
        warnings.extend(call_warnings)
        replaced_string_ids.update(call_ids)
        changed += replaced

        text, replaced = replace_calls(text, "loadIfResource", replace_load_if_resource)
        counts["loadIfResource"] += replaced
        changed += replaced

        text, replaced = replace_calls(text, "formatIfResources", replace_format_if_resources)
        counts["formatIfResources"] += replaced
        changed += replaced

        text, replaced, replaced_ids = replace_rez_strings(text, string_values)
        counts["Rez.Strings"] += replaced
        replaced_string_ids.update(replaced_ids)
        changed += replaced

        text, replaced = remove_string_literal_casts(text)
        counts["literalStringCasts"] += replaced
        changed += replaced

        text, replaced = remove_wrapped_string_literal_parens(text)
        counts["literalStringParens"] += replaced
        changed += replaced

        text, replaced = replace_calls(text, "joinComponents", replace_join_components)
        counts["joinComponents"] += replaced
        changed += replaced

        text, replaced = replace_calls(text, "joinNonNullComponents", replace_join_non_null_components)
        counts["joinNonNullComponents"] += replaced
        changed += replaced

        text, replaced = replace_calls(text, "Lang.format", replace_lang_format)
        counts["Lang.format"] += replaced
        changed += replaced

        text, replaced = replace_join_components_definition(text)
        counts["joinHelperDefinitions"] += replaced
        changed += replaced

        text, replaced = remove_helper_definitions(text)
        counts["helperDefinitions"] += replaced
        changed += replaced

        if changed == 0:
            break

    text = unmark_expanded_literals(text)

    return text, counts, warnings, replaced_string_ids


def iter_mc_files(paths: list[Path]) -> list[Path]:
    files: list[Path] = []
    for path in paths:
        if path.is_file() and path.suffix == ".mc":
            files.append(path)
            continue
        if not path.exists():
            raise FileNotFoundError(f"Path not found: {path}")
        for child in sorted(path.rglob("*.mc")):
            if child.is_file():
                files.append(child)
    return files


def resolve_output_root(repo_root: Path, output_root: Path | None) -> Path | None:
    if output_root is None:
        return None
    if output_root.is_absolute():
        return output_root.resolve()
    return (repo_root / output_root).resolve()


def mirrored_output_path(repo_root: Path, output_root: Path, source_path: Path) -> Path:
    return output_root / source_path.resolve().relative_to(repo_root)


def write_output_text(repo_root: Path, output_root: Path | None, source_path: Path, text: str) -> None:
    if output_root is None:
        source_path.write_text(text, encoding="utf-8")
    else:
        target_path = mirrored_output_path(repo_root, output_root, source_path)
        target_path.parent.mkdir(parents=True, exist_ok=True)
        target_path.write_text(text, encoding="utf-8")
    print(source_path.relative_to(repo_root))


def remove_output_text(repo_root: Path, output_root: Path | None, source_path: Path) -> bool:
    if output_root is None:
        source_path.unlink()
        print(source_path.relative_to(repo_root))
        return True

    target_path = mirrored_output_path(repo_root, output_root, source_path)
    if not target_path.exists():
        return False
    target_path.unlink()
    print(source_path.relative_to(repo_root))
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Inline Rez.Strings values into Monkey C source, replace loadIfResource(x) with x, "
            "replace formatIfResources(a, b) with Lang.format(a, b), expand static Lang.format calls, "
            "inline simple joinComponents/joinNonNullComponents calls, "
            "inline *.loadResource(Rez.Strings.x), narrow StringOrResource to Lang.String, "
            "drop loadIfResource/formatIfResources definitions, prune strings.xml entries across all languages, "
            "keep selected localized string-only files in place, delete non-selected localized copies, "
            "and prune manifests for one language."
        )
    )
    parser.add_argument(
        "paths",
        nargs="*",
        default=["source", "local/source"],
        help="Files or directories to rewrite. Defaults to source and local/source.",
    )
    parser.add_argument(
        "--repo-root",
        default=Path(__file__).resolve().parents[1],
        type=Path,
        help="Repository root used for resource discovery and relative output.",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Write changes in place. Without this flag or --output-root, print unified diffs only.",
    )
    parser.add_argument(
        "--output-root",
        type=Path,
        help="Write rewritten files into a mirrored tree at this location instead of modifying the repo.",
    )
    parser.add_argument(
        "--language",
        default="eng",
        help="Language to inline and keep in manifests/resources. Examples: eng, rus.",
    )
    parser.add_argument(
        "--config",
        default=str(DEFAULT_CONFIG_PATH),
        help=f"Path to config JSON (default: {DEFAULT_CONFIG_PATH})",
    )
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    config = load_config((repo_root / args.config).resolve())
    output_root = resolve_output_root(repo_root, args.output_root)
    if args.write and output_root is not None:
        parser.error("Use either --write or --output-root, not both.")
    if output_root == repo_root:
        parser.error("--output-root must be different from the repository root. Use --write for in-place updates.")

    input_paths = [(repo_root / Path(path)).resolve() for path in args.paths]
    discovered_strings = discover_string_values(repo_root, args.language, config)
    string_values = discovered_strings.inline_values
    mc_files = iter_mc_files(input_paths)
    full_scan_paths = [repo_root / "source", repo_root / "local/source"]
    all_mc_files = [path for path in iter_mc_files(full_scan_paths) if path.exists()]
    transformed_texts: dict[Path, str] = {}
    inlined_string_ids: set[str] = set()
    emitted_files = 0
    transformed_results: list[tuple[Path, str, str, dict[str, int], list[str]]] = []
    missing_resources_by_file: dict[Path, set[str]] = {}

    changed_files = 0
    total_counts = {
        "StringOrResource": 0,
        "loadResource": 0,
        "loadIfResource": 0,
        "formatIfResources": 0,
        "joinComponents": 0,
        "joinNonNullComponents": 0,
        "joinHelperDefinitions": 0,
        "helperDefinitions": 0,
        "literalStringCasts": 0,
        "literalStringParens": 0,
        "Lang.format": 0,
        "Rez.Strings": 0,
        "stringsXmlEntries": 0,
        "manifestLanguages": 0,
    }

    for file_path in mc_files:
        original = file_path.read_text(encoding="utf-8")
        updated, counts, warnings, replaced_ids = transform_text(original, string_values)
        transformed_texts[file_path.resolve()] = updated
        transformed_results.append((file_path, original, updated, counts, warnings))
        inlined_string_ids.update(replaced_ids)
        missing_ids = find_missing_available_string_ids(
            updated,
            discovered_strings.available_ids,
        )
        if missing_ids:
            missing_resources_by_file[file_path] = missing_ids

    if missing_resources_by_file:
        for file_path, missing_ids in sorted(missing_resources_by_file.items()):
            eprint(
                f"{file_path.relative_to(repo_root)}: Missing string resources for inlining "
                f"(language {args.language}): {', '.join(sorted(missing_ids))}"
            )
        return 1

    for file_path, original, updated, counts, warnings in transformed_results:
        for warning in warnings:
            eprint(f"{file_path.relative_to(repo_root)}: {warning}")
        if updated != original:
            changed_files += 1
            for key, value in counts.items():
                total_counts[key] += value

        if output_root is not None:
            write_output_text(repo_root, output_root, file_path, updated)
            emitted_files += 1
            continue

        if updated == original:
            continue

        if args.write:
            write_output_text(repo_root, None, file_path, updated)
        else:
            diff = difflib.unified_diff(
                original.splitlines(keepends=True),
                updated.splitlines(keepends=True),
                fromfile=str(file_path.relative_to(repo_root)),
                tofile=str(file_path.relative_to(repo_root)),
            )
            sys.stdout.writelines(diff)

    remaining_string_ids: set[str] = set()
    for file_path in all_mc_files:
        resolved = file_path.resolve()
        if resolved in transformed_texts:
            text = transformed_texts[resolved]
        else:
            text = file_path.read_text(encoding="utf-8")
        remaining_string_ids.update(collect_referenced_string_ids(text))

    for file_path in iter_non_code_reference_files(repo_root, config):
        text = file_path.read_text(encoding="utf-8")
        remaining_string_ids.update(collect_non_code_referenced_string_ids(text))

    removable_string_ids = inlined_string_ids - remaining_string_ids
    string_only_paths = discover_string_only_resource_paths(repo_root, config)

    for strings_xml_path in discover_strings_xml_paths(repo_root, config):
        path_language = string_only_resource_language(repo_root, strings_xml_path)
        if path_language != "eng" and path_language != args.language:
            continue

        original_strings_xml = strings_xml_path.read_text(encoding="utf-8")
        updated_strings_xml, removed_entries = remove_strings_xml_entries(
            original_strings_xml,
            removable_string_ids,
        )
        total_counts["stringsXmlEntries"] += removed_entries
        if updated_strings_xml != original_strings_xml:
            changed_files += 1
        if output_root is not None:
            write_output_text(repo_root, output_root, strings_xml_path, updated_strings_xml)
            emitted_files += 1
        elif updated_strings_xml != original_strings_xml:
            if args.write:
                write_output_text(repo_root, None, strings_xml_path, updated_strings_xml)
            else:
                diff = difflib.unified_diff(
                    original_strings_xml.splitlines(keepends=True),
                    updated_strings_xml.splitlines(keepends=True),
                    fromfile=str(strings_xml_path.relative_to(repo_root)),
                    tofile=str(strings_xml_path.relative_to(repo_root)),
                )
                sys.stdout.writelines(diff)

    if output_root is not None:
        for string_only_path in string_only_paths:
            path_language = string_only_resource_language(repo_root, string_only_path)
            if path_language != "eng" and path_language != args.language:
                continue
            if string_only_path.name == "strings.xml":
                continue
            original_text = string_only_path.read_text(encoding="utf-8")
            write_output_text(repo_root, output_root, string_only_path, original_text)
            emitted_files += 1

    for string_only_path in string_only_paths:
        path_language = string_only_resource_language(repo_root, string_only_path)
        if path_language == "eng" or path_language == args.language:
            continue
        if path_language != args.language and not string_only_path.exists():
            continue

        changed_files += 1
        original_text = string_only_path.read_text(encoding="utf-8")
        if output_root is not None:
            if remove_output_text(repo_root, output_root, string_only_path):
                emitted_files += 1
        elif args.write:
            remove_output_text(repo_root, None, string_only_path)
        else:
            diff = difflib.unified_diff(
                original_text.splitlines(keepends=True),
                [],
                fromfile=str(string_only_path.relative_to(repo_root)),
                tofile="/dev/null",
            )
            sys.stdout.writelines(diff)

    manifest_paths = [
        repo_root / "manifest.xml",
        repo_root / "manifest-app.xml",
        repo_root / "manifest-widget.xml",
    ]
    for manifest_path in manifest_paths:
        if not manifest_path.exists():
            continue
        original_manifest = manifest_path.read_text(encoding="utf-8")
        updated_manifest, removed_languages = strip_manifest_languages(original_manifest, args.language)
        total_counts["manifestLanguages"] += removed_languages
        if updated_manifest != original_manifest:
            changed_files += 1
        if output_root is not None:
            write_output_text(repo_root, output_root, manifest_path, updated_manifest)
            emitted_files += 1
        elif updated_manifest != original_manifest:
            if args.write:
                write_output_text(repo_root, None, manifest_path, updated_manifest)
            else:
                diff = difflib.unified_diff(
                    original_manifest.splitlines(keepends=True),
                    updated_manifest.splitlines(keepends=True),
                    fromfile=str(manifest_path.relative_to(repo_root)),
                    tofile=str(manifest_path.relative_to(repo_root)),
                )
                sys.stdout.writelines(diff)

    if changed_files == 0 and emitted_files == 0:
        print("No changes.")
        return 0

    if output_root is not None:
        eprint("Emitted files:", emitted_files)

    if changed_files == 0:
        return 0

    eprint(
        "Changed files:",
        changed_files,
        "| StringOrResource:",
        total_counts["StringOrResource"],
        "| loadResource:",
        total_counts["loadResource"],
        "| Rez.Strings:",
        total_counts["Rez.Strings"],
        "| loadIfResource:",
        total_counts["loadIfResource"],
        "| formatIfResources:",
        total_counts["formatIfResources"],
        "| joinComponents:",
        total_counts["joinComponents"],
        "| joinNonNullComponents:",
        total_counts["joinNonNullComponents"],
        "| join helper defs:",
        total_counts["joinHelperDefinitions"],
        "| helperDefinitions:",
        total_counts["helperDefinitions"],
        "| literal string casts:",
        total_counts["literalStringCasts"],
        "| literal string parens:",
        total_counts["literalStringParens"],
        "| Lang.format:",
        total_counts["Lang.format"],
        "| strings.xml entries:",
        total_counts["stringsXmlEntries"],
        "| manifest languages:",
        total_counts["manifestLanguages"],
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())