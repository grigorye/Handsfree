#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


POEDITOR_API_BASE = "https://api.poeditor.com/v2"


@dataclass(frozen=True)
class TargetLanguage:
    poeditor: str
    garmin: str


@dataclass(frozen=True)
class Config:
    api_token_env: str
    project_id: str
    reference_language: str
    target_languages: Tuple[TargetLanguage, ...]
    manifest_files: Tuple[str, ...]
    output_dir_pattern: str


def eprint(*args: Any) -> None:
    print(*args, file=sys.stderr)


def load_config(config_path: Path) -> Config:
    raw = json.loads(config_path.read_text(encoding="utf-8"))

    api_token_env = str(raw.get("api_token_env", "POEDITOR_API_TOKEN"))
    project_id = str(raw.get("project_id", "")).strip()
    reference_language = str(raw.get("reference_language", "en")).strip()
    output_dir_pattern = str(raw.get("output_dir_pattern", "resources-{garmin}"))

    raw_langs = raw.get("target_languages", [])
    target_languages: List[TargetLanguage] = []
    for item in raw_langs:
        if not isinstance(item, dict):
            raise ValueError("target_languages entries must be objects")
        poeditor = str(item.get("poeditor", "")).strip()
        garmin = str(item.get("garmin", "")).strip()
        if not poeditor or not garmin:
            raise ValueError("target_languages entries must include 'poeditor' and 'garmin'")
        target_languages.append(TargetLanguage(poeditor=poeditor, garmin=garmin))

    raw_manifests = raw.get("manifest_files", ["manifest-app.xml", "manifest-widget.xml"])
    manifest_files = tuple(str(x) for x in raw_manifests)

    return Config(
        api_token_env=api_token_env,
        project_id=project_id,
        reference_language=reference_language,
        target_languages=tuple(target_languages),
        manifest_files=manifest_files,
        output_dir_pattern=output_dir_pattern,
    )


def _xml_text_normalized(elem: ET.Element) -> str:
    # Collect all text (handles mixed indentation/newlines) then trim outer whitespace.
    text = "".join(elem.itertext())
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    # Preserve internal newlines, but remove leading/trailing whitespace.
    return text.strip()


def _is_localized_resources_dir(name: str) -> bool:
    # Generated localization folders follow the Connect IQ convention `resources-<lang>`.
    # We must never treat generated outputs as source inputs (avoids recursive `resources-xx/resources-xx/...`).
    return name.startswith("resources-") and len(name) > len("resources-")


def discover_string_values(repo_root: Path) -> Dict[str, Tuple[Optional[str], str]]:
    """Returns string_id -> (scope, value) from existing resource XMLs.

    If the same string_id is found more than once with different values,
    raises ValueError.
    """

    include_globs = [
        "resources/**/*.xml",
        "traits/**/*.xml",
        "local/resources/**/*.xml",
    ]

    excluded_dir_names = {
        "bin",
        "build",
        "gen",
        ".git",
        "jungle-prod",
    }

    out: Dict[str, Tuple[Optional[str], str]] = {}

    for pattern in include_globs:
        for path in repo_root.glob(pattern):
            if not path.is_file():
                continue
            if any(part in excluded_dir_names for part in path.parts):
                continue
            if any(_is_localized_resources_dir(part) for part in path.parts):
                continue

            # Dev trait resources are intentionally not user-facing (often include
            # build suffixes like "-B"). Do not use them as reference strings.
            normalized = "/".join(path.parts)
            if "/traits/dev/" in normalized:
                continue

            try:
                tree = ET.parse(path)
            except ET.ParseError:
                continue

            root = tree.getroot()
            for elem in root.iter():
                if elem.tag != "string":
                    continue
                string_id = elem.attrib.get("id")
                if not string_id:
                    continue
                scope = elem.attrib.get("scope")
                value = _xml_text_normalized(elem)

                existing = out.get(string_id)
                if existing is None:
                    out[string_id] = (scope, value)
                else:
                    existing_scope, existing_value = existing
                    if existing_value != value:
                        raise ValueError(
                            f"Conflicting values for string id '{string_id}': {existing_value!r} vs {value!r} (in {path})"
                        )
                    # Prefer explicit scope if previously missing.
                    if existing_scope is None and scope is not None:
                        out[string_id] = (scope, value)

    return out


def discover_string_values_for_localized_output(
    repo_root: Path,
    *,
    output_dir_name: str,
) -> Dict[str, Tuple[Optional[str], str]]:
    """Returns string_id -> (scope, value) from generated localized resource XMLs.

    Reads any XML under a directory named `output_dir_name` (e.g. resources-rus).
    """

    include_globs = [f"**/{output_dir_name}/**/*.xml"]

    excluded_dir_names = {
        "bin",
        "build",
        "gen",
        ".git",
        "jungle-prod",
    }

    out: Dict[str, Tuple[Optional[str], str]] = {}

    for pattern in include_globs:
        for path in repo_root.glob(pattern):
            if not path.is_file():
                continue
            if any(part in excluded_dir_names for part in path.parts):
                continue

            normalized = "/".join(path.parts)
            if "/traits/dev/" in normalized:
                continue

            try:
                tree = ET.parse(path)
            except ET.ParseError:
                continue

            root = tree.getroot()
            for elem in root.iter():
                if elem.tag != "string":
                    continue
                string_id = elem.attrib.get("id")
                if not string_id:
                    continue
                scope = elem.attrib.get("scope")
                value = _xml_text_normalized(elem)

                existing = out.get(string_id)
                if existing is None:
                    out[string_id] = (scope, value)
                else:
                    existing_scope, existing_value = existing
                    if existing_value != value:
                        raise ValueError(
                            f"Conflicting localized values for string id '{string_id}': {existing_value!r} vs {value!r} (in {path})"
                        )
                    if existing_scope is None and scope is not None:
                        out[string_id] = (scope, value)

    return out


def discover_string_ids(repo_root: Path) -> Dict[str, Optional[str]]:
    """Returns string_id -> scope (or None).

    Discovers <string id="..." ...> elements across project resource XMLs.
    """

    include_globs = [
        "resources/**/*.xml",
        "traits/**/*.xml",
        "source/**/*.xml",
    ]

    excluded_dir_names = {
        "bin",
        "build",
        "gen",
        ".git",
        "jungle-prod",
    }

    string_scopes: Dict[str, Optional[str]] = {}

    for pattern in include_globs:
        for path in repo_root.glob(pattern):
            if not path.is_file():
                continue
            if any(part in excluded_dir_names for part in path.parts):
                continue
            if any(_is_localized_resources_dir(part) for part in path.parts):
                continue

            try:
                tree = ET.parse(path)
            except ET.ParseError:
                continue

            root = tree.getroot()
            for elem in root.iter():
                if elem.tag != "string":
                    continue
                string_id = elem.attrib.get("id")
                if not string_id:
                    continue
                scope = elem.attrib.get("scope")
                if string_id not in string_scopes:
                    string_scopes[string_id] = scope
                else:
                    # Prefer an explicit scope if previously None.
                    if string_scopes[string_id] is None and scope is not None:
                        string_scopes[string_id] = scope

    return string_scopes


def discover_strings_by_source_file(
    repo_root: Path,
) -> Dict[Path, List[Tuple[str, Optional[str]]]]:
    """Returns relative xml path -> list of (string_id, scope) in that file.

    Used by `pull` to write translated strings back into matching file locations.
    """

    include_globs = [
        "resources/**/*.xml",
        "traits/**/*.xml",
        "local/resources/**/*.xml",
    ]

    excluded_dir_names = {
        "bin",
        "build",
        "gen",
        ".git",
        "jungle-prod",
    }

    out: Dict[Path, List[Tuple[str, Optional[str]]]] = {}

    for pattern in include_globs:
        for path in repo_root.glob(pattern):
            if not path.is_file():
                continue
            if any(part in excluded_dir_names for part in path.parts):
                continue
            if any(_is_localized_resources_dir(part) for part in path.parts):
                continue

            normalized = "/".join(path.parts)
            if "/traits/dev/" in normalized:
                continue

            try:
                tree = ET.parse(path)
            except ET.ParseError:
                continue

            root = tree.getroot()
            decls: List[Tuple[str, Optional[str]]] = []
            for elem in root.iter():
                if elem.tag != "string":
                    continue
                string_id = elem.attrib.get("id")
                if not string_id:
                    continue
                scope = elem.attrib.get("scope")
                decls.append((string_id, scope))

            if decls:
                out[path.relative_to(repo_root)] = decls

    return out


def localized_resource_path_for_source(
    *,
    source_rel_path: Path,
    output_dir_name: str,
) -> Path:
    """Maps a source resource xml path to its localized output path.

    Rules:
    - If the source path contains a directory named `resources`, replace that directory with
      `output_dir_name` (e.g. resources/strings.xml -> resources-rus/strings.xml).
    - Otherwise, create a sibling `output_dir_name` folder next to the file
      (e.g. traits/complication/strings.xml -> traits/complication/resources-rus/strings.xml).
    """

    parts = list(source_rel_path.parts)
    try:
        idx = parts.index("resources")
    except ValueError:
        idx = -1

    if idx >= 0:
        parts[idx] = output_dir_name
        return Path(*parts)

    # Insert a localized resources directory at the file's level.
    if len(parts) <= 1:
        return Path(output_dir_name) / source_rel_path.name
    return Path(*parts[:-1]) / output_dir_name / source_rel_path.name


def poeditor_post_form(endpoint: str, data: Dict[str, str]) -> Dict[str, Any]:
    encoded = urllib.parse.urlencode(data).encode("utf-8")
    request = urllib.request.Request(
        url=f"{POEDITOR_API_BASE}/{endpoint}",
        data=encoded,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=30) as resp:
        payload = resp.read().decode("utf-8")
    obj = json.loads(payload)
    if obj.get("response", {}).get("status") != "success":
        raise RuntimeError(f"POEditor API error: {obj}")
    return obj


def poeditor_post_multipart(
    endpoint: str,
    *,
    fields: Dict[str, str],
    files: Dict[str, Tuple[str, bytes, str]],
) -> Dict[str, Any]:
    boundary = "----poeditor-sync-boundary-7e61c7f3b6d44f2c"

    def part_field(name: str, value: str) -> bytes:
        return (
            f"--{boundary}\r\n"
            f"Content-Disposition: form-data; name=\"{name}\"\r\n\r\n"
            f"{value}\r\n"
        ).encode("utf-8")

    def part_file(name: str, filename: str, content: bytes, content_type: str) -> bytes:
        header = (
            f"--{boundary}\r\n"
            f"Content-Disposition: form-data; name=\"{name}\"; filename=\"{filename}\"\r\n"
            f"Content-Type: {content_type}\r\n\r\n"
        ).encode("utf-8")
        return header + content + b"\r\n"

    body = b"".join([part_field(k, v) for k, v in fields.items()])
    for field_name, (filename, content, content_type) in files.items():
        body += part_file(field_name, filename, content, content_type)
    body += f"--{boundary}--\r\n".encode("utf-8")

    request = urllib.request.Request(
        url=f"{POEDITOR_API_BASE}/{endpoint}",
        data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
        method="POST",
    )

    with urllib.request.urlopen(request, timeout=60) as resp:
        payload = resp.read().decode("utf-8")
    obj = json.loads(payload)
    if obj.get("response", {}).get("status") != "success":
        raise RuntimeError(f"POEditor API error: {obj}")
    return obj


def poeditor_export_key_value_json(
    *,
    api_token: str,
    project_id: str,
    language: str,
    fallback_language: Optional[str],
) -> Dict[str, str]:
    form: Dict[str, str] = {
        "api_token": api_token,
        "id": project_id,
        "language": language,
        "type": "key_value_json",
    }
    if fallback_language:
        form["fallback_language"] = fallback_language

    result = poeditor_post_form("projects/export", form)
    url = result["result"]["url"]

    with urllib.request.urlopen(url, timeout=30) as resp:
        body = resp.read().decode("utf-8")

    data = json.loads(body)
    if not isinstance(data, dict):
        raise RuntimeError("Expected key-value JSON export")

    out: Dict[str, str] = {}
    for key, value in data.items():
        out[str(key)] = "" if value is None else str(value)
    return out


def xml_escape(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def format_string_value_for_xml(value: str) -> str:
    """Formats a string value for embedding in XML text nodes.

    Newlines are serialized as &#10; so pulled XML stays single-line per string
    entry and never acquires indentation in the runtime value.
    """

    value = value.replace("\r\n", "\n").replace("\r", "\n")
    parts = value.split("\n")
    if len(parts) == 1:
        return xml_escape(parts[0])
    return "&#10;".join(xml_escape(p) for p in parts)


def write_strings_xml(
    *,
    output_path: Path,
    strings: List[Tuple[str, Optional[str], str]],
) -> None:
    """Writes a Connect IQ-compatible strings file.

    strings entries are (id, scope, value).
    """

    output_path.parent.mkdir(parents=True, exist_ok=True)

    lines: List[str] = []
    lines.append("<resources>")

    for string_id, scope, value in strings:
        attrs = f' id="{xml_escape(string_id)}"'
        if scope:
            attrs += f' scope="{xml_escape(scope)}"'

        escaped = format_string_value_for_xml(value)
        if "\n" not in escaped:
            lines.append(f"    <string{attrs}>{escaped}</string>")
        else:
            parts = escaped.split("\n")
            # Keep the first line nicely indented, but do not indent subsequent
            # lines (indentation becomes part of the runtime string).
            lines.append(f"    <string{attrs}>{parts[0]}")
            lines.extend(parts[1:-1])
            lines.append(f"{parts[-1]}</string>")

    lines.append("</resources>")
    lines.append("")

    output_path.write_text("\n".join(lines), encoding="utf-8")


_STRING_ID_RE = re.compile(r"<string\b[^>]*\bid\s*=\s*['\"]([^'\"]+)['\"]")


def append_strings_to_resource_xml(
    *,
    output_path: Path,
    strings: List[Tuple[str, Optional[str], str]],
) -> int:
    """Appends new <string> entries to an existing resource XML.

    - Only appends IDs that are not already present.
    - Inserts entries before the final </resources>.
    - Does not try to reformat existing content.
    """

    original = output_path.read_text(encoding="utf-8")
    if "</resources>" not in original:
        raise RuntimeError(f"Cannot find </resources> in {output_path}")

    existing_ids = set(_STRING_ID_RE.findall(original))
    to_add = [
        (sid, scope, val) for (sid, scope, val) in strings if sid not in existing_ids
    ]
    if not to_add:
        return 0

    new_lines: List[str] = []
    for string_id, scope, value in to_add:
        attrs = f' id="{xml_escape(string_id)}"'
        if scope:
            attrs += f' scope="{xml_escape(scope)}"'

        escaped = format_string_value_for_xml(value)
        if "\n" not in escaped:
            new_lines.append(f"    <string{attrs}>{escaped}</string>")
        else:
            parts = escaped.split("\n")
            new_lines.append(f"    <string{attrs}>{parts[0]}")
            new_lines.extend(parts[1:-1])
            new_lines.append(f"{parts[-1]}</string>")

    insert_at = original.rfind("</resources>")
    before = original[:insert_at]
    after = original[insert_at:]

    if not before.endswith("\n"):
        before += "\n"
    if not before.endswith("\n\n"):
        before += "\n"

    updated = before + "\n".join(new_lines) + "\n" + after
    output_path.write_text(updated, encoding="utf-8")
    return len(to_add)


def update_manifest_languages(manifest_path: Path, languages: List[str]) -> bool:
    """Updates <iq:languages> block; returns True if file changed."""

    original = manifest_path.read_text(encoding="utf-8")

    # Find the <iq:languages> line to capture indentation.
    m = re.search(r"^(?P<indent>\s*)<iq:languages>\s*$", original, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f"Cannot find <iq:languages> in {manifest_path}")

    indent = m.group("indent")
    inner_indent = indent + "    "

    new_block_lines = [f"{indent}<iq:languages>"]
    for lang in languages:
        new_block_lines.append(f"{inner_indent}<iq:language>{lang}</iq:language>")
    new_block_lines.append(f"{indent}</iq:languages>")
    new_block = "\n".join(new_block_lines)

    replaced, count = re.subn(
        r"^\s*<iq:languages>\s*$.*?^\s*</iq:languages>\s*$",
        new_block,
        original,
        flags=re.MULTILINE | re.DOTALL,
    )
    if count != 1:
        raise RuntimeError(f"Unexpected number of <iq:languages> blocks in {manifest_path}: {count}")

    if replaced == original:
        return False

    manifest_path.write_text(replaced, encoding="utf-8")
    return True


_STRING_ELEMENT_RE = re.compile(
    r"(?P<open><string\b[^>]*\bid\s*=\s*(?P<q>['\"])"
    r"(?P<id>[^'\"]+)"
    r"(?P=q)[^>]*>)"
    r"(?P<body>.*?)"
    r"(?P<close></string>)",
    flags=re.DOTALL,
)


def update_string_values_in_xml_text(
    *,
    xml_text: str,
    translations: Dict[str, str],
) -> Tuple[str, bool, List[str]]:
    """Updates <string id="...">...</string> bodies in an XML text.

    Returns (new_text, changed, changed_ids).
    """

    changed = False
    changed_ids: List[str] = []

    def repl(match: re.Match[str]) -> str:
        nonlocal changed
        string_id = match.group("id")
        if string_id not in translations:
            return match.group(0)

        new_body = format_string_value_for_xml(translations[string_id])
        replacement = f"{match.group('open')}{new_body}{match.group('close')}"
        if replacement != match.group(0):
            changed = True
            changed_ids.append(string_id)
        return replacement

    new_text = _STRING_ELEMENT_RE.sub(repl, xml_text)
    # Preserve order while de-duplicating.
    changed_ids = list(dict.fromkeys(changed_ids))
    return new_text, changed, changed_ids


def cmd_pull(
    repo_root: Path,
    cfg: Config,
    update_manifests: bool,
    include_reference: bool,
    dry_run: bool,
    include_new_terms: bool,
    extra_strings_file: str,
) -> int:
    api_token = os.environ.get(cfg.api_token_env, "").strip()
    if not api_token:
        eprint(f"Missing env var {cfg.api_token_env} (POEditor API token)")
        return 2

    if not cfg.project_id:
        eprint("Missing 'project_id' in localization/poeditor.json")
        return 2

    if not cfg.target_languages:
        eprint("No target_languages configured in localization/poeditor.json")
        return 2

    strings_by_file = discover_strings_by_source_file(repo_root)
    if not strings_by_file:
        eprint("No <string id=...> resources discovered")
        return 2

    known_ids: set[str] = set()
    for decls in strings_by_file.values():
        for string_id, _scope in decls:
            known_ids.add(string_id)

    extra_source_rel = Path(extra_strings_file)

    # If we need the reference language for any reason, fetch it once.
    reference_translations: Optional[Dict[str, str]] = None
    if include_reference or include_new_terms:
        reference_translations = poeditor_export_key_value_json(
            api_token=api_token,
            project_id=cfg.project_id,
            language=cfg.reference_language,
            fallback_language=None,
        )

    if include_reference:
        assert reference_translations is not None
        if dry_run:
            eprint(
                f"POEditor export: reference {cfg.reference_language} -> previewing base resource XML changes (dry-run)"
            )
        else:
            eprint(f"POEditor export: reference {cfg.reference_language} -> updating base resource XMLs")

        changed_any = False
        changed_files = 0
        changed_strings = 0
        for source_rel_path in sorted(strings_by_file.keys(), key=str):
            source_path = repo_root / source_rel_path
            if not source_path.exists():
                continue
            original = source_path.read_text(encoding="utf-8")
            updated, changed, changed_ids = update_string_values_in_xml_text(
                xml_text=original,
                translations=reference_translations,
            )
            if changed:
                changed_any = True
                changed_files += 1
                changed_strings += len(changed_ids)
                if dry_run:
                    eprint(f"DRY-RUN would update {source_rel_path}: {', '.join(changed_ids)}")
                else:
                    source_path.write_text(updated, encoding="utf-8")

        if changed_any:
            if dry_run:
                eprint(
                    f"DRY-RUN summary: {changed_files} file(s) would change, {changed_strings} string(s) would change"
                )
            else:
                eprint("Updated base resource XML strings from POEditor reference language")
        else:
            eprint("Base resource XML strings already match POEditor reference language")

    if include_new_terms:
        assert reference_translations is not None

        extra_ids = sorted(
            [k for k in reference_translations.keys() if k not in known_ids]
        )
        extra_entries: List[Tuple[str, Optional[str], str]] = [
            (string_id, None, reference_translations.get(string_id, ""))
            for string_id in extra_ids
        ]

        if not extra_entries:
            eprint("No new POEditor terms found outside repo resources")
        else:
            extra_source_path = repo_root / extra_source_rel
            extra_decls: List[Tuple[str, Optional[str]]] = [
                (sid, None) for sid in extra_ids
            ]

            if extra_source_rel in strings_by_file:
                # Append declarations so localized outputs for this file include the new IDs too.
                strings_by_file[extra_source_rel] = (
                    strings_by_file[extra_source_rel] + extra_decls
                )
            else:
                strings_by_file[extra_source_rel] = extra_decls

            if dry_run:
                eprint(
                    f"DRY-RUN would append {len(extra_entries)} new string(s) into {extra_source_rel}"
                )
            else:
                if extra_source_path.exists():
                    added = append_strings_to_resource_xml(
                        output_path=extra_source_path,
                        strings=extra_entries,
                    )
                    eprint(f"Appended {added} new string(s) into {extra_source_rel}")
                else:
                    write_strings_xml(
                        output_path=extra_source_path, strings=extra_entries
                    )
                    eprint(
                        f"Wrote {extra_source_rel} with {len(extra_entries)} new string(s)"
                    )

    for lang in cfg.target_languages:
        output_dir_name = cfg.output_dir_pattern.format(
            garmin=lang.garmin, poeditor=lang.poeditor
        )
        eprint(
            f"POEditor export: {lang.poeditor} -> {output_dir_name}/... (mirrors source file layout)"
        )

        translations = poeditor_export_key_value_json(
            api_token=api_token,
            project_id=cfg.project_id,
            language=lang.poeditor,
            fallback_language=cfg.reference_language,
        )

        for source_rel_path in sorted(strings_by_file.keys(), key=str):
            decls = strings_by_file[source_rel_path]
            entries: List[Tuple[str, Optional[str], str]] = []
            for string_id, scope in decls:
                value = translations.get(string_id, "")
                entries.append((string_id, scope, value))

            out_rel_path = localized_resource_path_for_source(
                source_rel_path=source_rel_path,
                output_dir_name=output_dir_name,
            )
            output_path = repo_root / out_rel_path
            write_strings_xml(output_path=output_path, strings=entries)

    if update_manifests:
        cmd_update_manifests(repo_root, cfg)

    return 0


def cmd_dump_terms(repo_root: Path) -> int:
    """Dumps discovered string IDs to stdout (for initial POEditor seeding)."""

    string_scopes = discover_string_ids(repo_root)
    out = {k: "" for k in sorted(string_scopes.keys())}
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


def cmd_export_reference(repo_root: Path) -> int:
    """Exports repo's current (English) strings as key_value_json (id -> value)."""

    values = discover_string_values(repo_root)
    if not values:
        eprint("No <string id=...> values discovered")
        return 2

    out = {k: v for k, (_scope, v) in sorted(values.items(), key=lambda kv: kv[0])}
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


def cmd_upload_reference(repo_root: Path, cfg: Config, *, overwrite: bool, sync_terms: bool) -> int:
    """Uploads repo strings to POEditor as terms + reference language translations."""

    api_token = os.environ.get(cfg.api_token_env, "").strip()
    if not api_token:
        eprint(f"Missing env var {cfg.api_token_env} (POEditor API token)")
        return 2

    if not cfg.project_id:
        eprint("Missing 'project_id' in localization/poeditor.json")
        return 2

    values = discover_string_values(repo_root)
    if not values:
        eprint("No <string id=...> values discovered")
        return 2

    payload = {k: v for k, (_scope, v) in sorted(values.items(), key=lambda kv: kv[0])}
    content = (json.dumps(payload, ensure_ascii=False, indent=2) + "\n").encode("utf-8")

    fields: Dict[str, str] = {
        "api_token": api_token,
        "id": cfg.project_id,
        "updating": "terms_translations",
        "language": cfg.reference_language,
        "overwrite": "1" if overwrite else "0",
        "sync_terms": "1" if sync_terms else "0",
    }

    poeditor_post_multipart(
        "projects/upload",
        fields=fields,
        files={"file": ("connectiq-strings.json", content, "application/json")},
    )

    eprint("Uploaded reference strings to POEditor")
    return 0


def cmd_upload_language(
    repo_root: Path,
    cfg: Config,
    *,
    language: str,
    overwrite: bool,
) -> int:
    """Uploads translations for a specific POEditor language from repo-localized resources."""

    api_token = os.environ.get(cfg.api_token_env, "").strip()
    if not api_token:
        eprint(f"Missing env var {cfg.api_token_env} (POEditor API token)")
        return 2

    if not cfg.project_id:
        eprint("Missing 'project_id' in localization/poeditor.json")
        return 2

    lang = language.strip()
    if not lang:
        eprint("Missing --language")
        return 2

    target: Optional[TargetLanguage] = None
    for item in cfg.target_languages:
        if item.poeditor == lang:
            target = item
            break
    if target is None:
        available = ", ".join(sorted([x.poeditor for x in cfg.target_languages]))
        eprint(f"Unknown language '{lang}'. Configured target languages: {available}")
        return 2

    output_dir_name = cfg.output_dir_pattern.format(garmin=target.garmin, poeditor=target.poeditor)
    values = discover_string_values_for_localized_output(repo_root, output_dir_name=output_dir_name)
    if not values:
        eprint(f"No localized <string id=...> values discovered under {output_dir_name}/")
        return 2

    payload = {k: v for k, (_scope, v) in sorted(values.items(), key=lambda kv: kv[0])}
    content = (json.dumps(payload, ensure_ascii=False, indent=2) + "\n").encode("utf-8")

    fields: Dict[str, str] = {
        "api_token": api_token,
        "id": cfg.project_id,
        "updating": "translations",
        "language": target.poeditor,
        "overwrite": "1" if overwrite else "0",
    }

    poeditor_post_multipart(
        "projects/upload",
        fields=fields,
        files={"file": (f"connectiq-strings-{target.poeditor}.json", content, "application/json")},
    )

    eprint(f"Uploaded translations for '{target.poeditor}' from {output_dir_name}/")
    return 0


def cmd_update_manifests(repo_root: Path, cfg: Config) -> int:
    if not cfg.target_languages:
        eprint("No target_languages configured in localization/poeditor.json")
        return 2

    # Always include English.
    languages = ["eng"] + [lang.garmin for lang in cfg.target_languages]

    changed_any = False
    for rel in cfg.manifest_files:
        path = repo_root / rel
        if not path.exists():
            eprint(f"Manifest not found: {rel}")
            return 2
        changed = update_manifest_languages(path, languages)
        changed_any = changed_any or changed

    if changed_any:
        eprint("Updated manifests language list")
    else:
        eprint("Manifests already up to date")

    return 0


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Sync Connect IQ string resources with POEditor")
    parser.add_argument(
        "--config",
        default="localization/poeditor.json",
        help="Path to config JSON (default: localization/poeditor.json)",
    )

    sub = parser.add_subparsers(dest="cmd", required=True)

    pull = sub.add_parser(
        "pull",
        help="Pull translations from POEditor and generate localized resource XMLs (mirrors source layout)",
    )
    pull.add_argument("--update-manifests", action="store_true", help="Also update manifest language list")
    pull.add_argument(
        "--include-reference",
        action="store_true",
        help="Also pull the reference language and update base resource XML string values in-place",
    )
    pull.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would change without writing files (for reference pulls and/or new-term appends)",
    )
    pull.add_argument(
        "--include-new-terms",
        action="store_true",
        help="Also append POEditor terms missing from repo into a resource XML file",
    )
    pull.add_argument(
        "--extra-strings-file",
        default="resources/strings.xml",
        help="Relative path to append/generated file for new-term strings (default: resources/strings.xml)",
    )

    sub.add_parser("dump-terms", help="Dump string IDs as key_value_json skeleton for initial POEditor seeding")

    sub.add_parser("export-reference", help="Export current repo strings as key_value_json (id -> English text)")

    upload = sub.add_parser(
        "upload-reference",
        help="Upload repo strings to POEditor as terms + reference language translations (projects/upload)",
    )
    upload.add_argument("--overwrite", action="store_true", help="Overwrite existing translations in POEditor")
    upload.add_argument(
        "--sync-terms",
        action="store_true",
        help="Sync terms in POEditor (terms missing from upload get deleted) — use with caution",
    )

    upload_lang = sub.add_parser(
        "upload-language",
        help="Upload a specific language's translations from resources-<lang> XMLs to POEditor (projects/upload)",
    )
    upload_lang.add_argument(
        "--language",
        required=True,
        help="POEditor language code to upload (must exist in target_languages)",
    )
    upload_lang.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing translations in POEditor",
    )

    sub.add_parser("update-manifests", help="Update manifest language list from config")

    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parents[1]
    cfg = load_config(repo_root / args.config)

    if args.cmd == "pull":
        return cmd_pull(
            repo_root,
            cfg,
            update_manifests=bool(args.update_manifests),
            include_reference=bool(args.include_reference),
            dry_run=bool(args.dry_run),
            include_new_terms=bool(args.include_new_terms),
            extra_strings_file=str(args.extra_strings_file),
        )
    if args.cmd == "dump-terms":
        return cmd_dump_terms(repo_root)
    if args.cmd == "export-reference":
        return cmd_export_reference(repo_root)
    if args.cmd == "update-manifests":
        return cmd_update_manifests(repo_root, cfg)
    if args.cmd == "upload-reference":
        return cmd_upload_reference(repo_root, cfg, overwrite=bool(args.overwrite), sync_terms=bool(args.sync_terms))
    if args.cmd == "upload-language":
        return cmd_upload_language(
            repo_root,
            cfg,
            language=str(args.language),
            overwrite=bool(args.overwrite),
        )

    raise AssertionError("unreachable")


if __name__ == "__main__":
    raise SystemExit(main())
