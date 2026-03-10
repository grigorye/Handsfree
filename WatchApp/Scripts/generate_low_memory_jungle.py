#!/usr/bin/env python3

"""Generate a Jungle file with low-memory device overrides.

This script reads low-memory device IDs from `lm.txt` and generates per-device
definitions from a required dist-style Jungle file:

    <device>.resourcePath = $(lowMemory_resourcePath)
    <device>.sourcePath   = $(lowMemory_sourcePath)
    <device>.personality  = $(lowMemory_personality)
    <device>.lang.<lang>  = $(lowMemory_lang_<lang>)

It derives the `lowMemory_*` header from the required `--derive-from` file,
builds `lowMemory_resourcePath` from `base.resourcePath`, derives
language-specific `lowMemory_lang_<lang>` values from whatever non-English
languages are declared in the manifests, reads devices from `lm.txt`, and
derives output from the input file name unless `--output` is given.

Usage:
    Scripts/generate_low_memory_jungle.py --derive-from jungle/dist/local.jungle
    Scripts/generate_low_memory_jungle.py --derive-from jungle/dist/local.jungle --output lm.jungle
  Scripts/generate_low_memory_jungle.py --dry-run            # print to stdout

Notes:
- Device IDs are loaded from a plain text file, one identifier per line.
- Lines starting with `#` are treated as comments.
"""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Iterable, Optional


_BASE_RESOURCE_RE = re.compile(r"^\s*base\.resourcePath\s*=\s*(.*)$")
CONNECT_IQ_NS = {"iq": "http://www.garmin.com/xml/connectiq"}


def resolve_jungle_path(root: Path, spec: str) -> Path:
    """Resolve a jungle path spec to an existing file."""

    candidate = Path(spec)
    if candidate.is_absolute():
        resolved = candidate
    else:
        resolved = (root / spec).resolve()

    if resolved.exists():
        return resolved

    raise SystemExit(f"--derive-from file not found: {spec!r}")


def build_default_output_path(derive_path: Path) -> Path:
    """Return the default output path for a derived jungle file."""
    return derive_path.with_name(f"{derive_path.stem}-lm{derive_path.suffix}")


def _strip_comment(line: str) -> str:
    # Jungle uses `#` for comments in this repo.
    return line.split("#", 1)[0].rstrip("\n")


def load_device_ids(device_list_path: Path) -> list[str]:
    """Load low-memory device IDs from a plain text file."""

    if not device_list_path.exists():
        raise SystemExit(f"Device list file not found: {device_list_path}")

    devices: list[str] = []
    seen: set[str] = set()

    try:
        raw_lines = device_list_path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        raw_lines = device_list_path.read_text(encoding="utf-8", errors="replace").splitlines()

    for line in raw_lines:
        candidate = _strip_comment(line).strip()
        if not candidate:
            continue

        if not re.fullmatch(r"[A-Za-z0-9_]+", candidate):
            raise SystemExit(f"Invalid device ID in {device_list_path}: {candidate!r}")

        if candidate not in seen:
            seen.add(candidate)
            devices.append(candidate)

    if not devices:
        raise SystemExit(f"No device IDs found in {device_list_path}")

    return devices


def parse_base_resource_path_append(jungle_path: Path) -> Optional[str]:
    """Parse dist-like jungle file for a base.resourcePath appended suffix.

    Expected form (example):
        base.resourcePath = $(base.resourcePath);../../local/resources;../../traits/dev

    Returns whatever comes after the `$(base.resourcePath)` reference
    (typically starting with ';...').
    """

    if not jungle_path.exists():
        return None

    try:
        raw_lines = jungle_path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        raw_lines = jungle_path.read_text(encoding="utf-8", errors="replace").splitlines()

    resource_suffix: Optional[str] = None

    for line in raw_lines:
        if line.lstrip().startswith("#"):
            continue
        code = _strip_comment(line).strip()
        if not code:
            continue

        match = _BASE_RESOURCE_RE.match(code)
        if match:
            rhs = match.group(1).strip()
            prefix = "$(base.resourcePath)"
            pos = rhs.find(prefix)
            if pos != -1:
                resource_suffix = rhs[pos + len(prefix) :]
            break

    return resource_suffix


def infer_dist_variant(*, resource_suffix: Optional[str]) -> Optional[str]:
    """Infer a variant name (like 'local' or 'build') from dist-style suffixes."""

    def _infer_from_suffix(suffix: Optional[str], needle: str) -> Optional[str]:
        if not suffix:
            return None
        # Example tokens we expect: ;../../local/resources or ;../../build/resources-rus
        pattern = re.compile(r";\s*\.\./\.\./([^/]+)/" + re.escape(needle) + r"\b")
        match = pattern.search(suffix)
        return match.group(1) if match else None

    return _infer_from_suffix(resource_suffix, "resources")


def infer_include_traits_dev(*, resource_suffix: Optional[str]) -> Optional[bool]:
    """Infer whether traits/dev should be included from base.resourcePath suffix."""
    if resource_suffix is None:
        return None
    return bool(re.search(r"/traits/dev\b", resource_suffix))


def convert_dist_suffix_to_tmp_paths(suffix: Optional[str]) -> list[str]:
    """Convert a dist suffix like ';../../build/resources' into l paths."""
    if not suffix:
        return []

    converted: list[str] = []
    for part in suffix.split(";"):
        token = part.strip()
        if not token:
            continue
        # If token starts with '../../', replace with '../../l/'
        if token.startswith("../../"):
            # Remove '../../' and prepend '../../l/'
            rest = token[6:]
            converted.append(f"../../l/{rest}")
        else:
            converted.append(token)

    return converted


def load_manifest_languages(manifest_paths: Iterable[Path]) -> list[str]:
    """Load declared languages from manifests, preserving first-seen order."""

    languages: list[str] = []
    seen: set[str] = set()

    for manifest_path in manifest_paths:
        if not manifest_path.exists():
            raise SystemExit(f"Manifest not found: {manifest_path}")

        try:
            tree = ET.parse(manifest_path)
        except ET.ParseError as exc:
            raise SystemExit(f"Failed to parse {manifest_path}: {exc}") from exc

        for element in tree.findall(".//iq:languages/iq:language", CONNECT_IQ_NS):
            language = (element.text or "").strip()
            if not language or language in seen:
                continue
            seen.add(language)
            languages.append(language)

    if "eng" not in seen:
        languages.insert(0, "eng")

    return languages


def build_low_memory_language_components(
    *,
    base_resource_path: str,
    language: str,
    base_dir: Path,
) -> list[str]:
    """Return existing low-memory resource paths for one language."""

    components: list[str] = []
    for component in base_resource_path.split(";"):
        token = component.strip()
        if not token:
            continue

        localized_token = f"{token}-{language}"
        resolved = (base_dir / localized_token).resolve()
        if resolved.exists():
            components.append(localized_token)

    return components


def render_low_memory_header(
    *,
    variant: str,
    resource_suffix: Optional[str],
    languages: Iterable[str],
    base_dir: Path,
) -> tuple[list[str], list[str]]:
    """Render the generated lowMemory_* header directly from derive-from."""
    low_memory_resource_path = f"../../l/resources{resource_suffix or ''}"
    low_memory_source_path = (
        "../../l/source/**.mc;../../local/source/**.mc"
        if variant == "local"
        else "../../l/source/**.mc;../../build/source/**.mc"
    )
    rendered_languages: list[str] = []

    lines = [
        f"lowMemory_sourcePath = {low_memory_source_path}\n",
        f"lowMemory_resourcePath = {low_memory_resource_path}\n",
        "lowMemory_personality = ../../l/resources\n",
    ]

    for language in languages:
        if language == "eng":
            continue

        localized_components = build_low_memory_language_components(
            base_resource_path=low_memory_resource_path,
            language=language,
            base_dir=base_dir,
        )
        if not localized_components:
            continue

        rendered_languages.append(language)
        lines.append(
            f"lowMemory_lang_{language} = {';'.join(localized_components)}\n"
        )

    lines.append("\n")
    return lines, rendered_languages


def render_low_memory_device_overrides(
    devices: Iterable[str],
    languages: Iterable[str],
) -> str:
    """Render per-device low-memory override lines."""
    out: list[str] = []
    for device in devices:
        out.append(f"{device}.resourcePath = $(lowMemory_resourcePath)\n")
        out.append(f"{device}.sourcePath = $(lowMemory_sourcePath)\n")
        out.append(f"{device}.personality = $(lowMemory_personality)\n")
        for language in languages:
            if language == "eng":
                continue
            out.append(f"{device}.lang.{language} = $(lowMemory_lang_{language})\n")
        out.append("\n")
    return "".join(out)


def build_output(
    *,
    header_lines: list[str],
    devices: Iterable[str],
    languages: Iterable[str],
    banner: Optional[str],
) -> str:
    """Build the final generated Jungle file content."""
    rendered_devices = render_low_memory_device_overrides(devices, languages)

    header = list(header_lines)
    if header and not header[-1].endswith("\n"):
        header[-1] = header[-1] + "\n"

    if banner:
        banner_lines = [
            "# ------------------------------------------------------------------------------\n",
            f"# {banner}\n",
            "# ------------------------------------------------------------------------------\n",
            "\n",
        ]
        header = banner_lines + header

    # Ensure exactly one blank line between header and device blocks.
    while header and header[-1].strip() == "":
        # Keep at most one trailing blank line.
        if len(header) >= 2 and header[-2].strip() == "":
            header.pop()
        else:
            break

    if header and header[-1].strip() != "":
        header.append("\n")

    return "".join(header) + rendered_devices


def main(argv: list[str]) -> int:
    """Run the CLI."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        default=".",
        help="Repo root for resolving relative paths (default: .)",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Output file to write (default: <derive-from stem>-lm.jungle)",
    )
    parser.add_argument(
        "--devices",
        default="lm.txt",
        help="Text file with low-memory device IDs, one per line (default: lm.txt)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print generated content to stdout instead of writing a file",
    )
    parser.add_argument(
        "--derive-from",
        required=True,
        help=(
            "Jungle file (e.g. jungle/dist/local.jungle) used to derive "
            "lowMemory_resourcePath from base.resourcePath. Manifest-declared "
            "non-English languages are then mapped to matching low-memory "
            "resource directories."
        ),
    )
    parser.add_argument(
        "--manifest",
        action="append",
        default=None,
        help=(
            "Manifest path used to discover enabled languages. Repeat to "
            "override the defaults of manifest-app.xml and manifest-widget.xml."
        ),
    )
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    device_list_path = (
        (root / args.devices).resolve()
        if not Path(args.devices).is_absolute()
        else Path(args.devices)
    )
    derive_path = resolve_jungle_path(root, args.derive_from)
    if args.output is None:
        output_path = build_default_output_path(derive_path)
    else:
        output_path = (
            (root / args.output).resolve()
            if not Path(args.output).is_absolute()
            else Path(args.output)
        )

    devices = load_device_ids(device_list_path)
    manifest_specs = args.manifest or ["manifest-app.xml", "manifest-widget.xml"]
    manifest_paths = [
        (root / manifest_path).resolve()
        if not Path(manifest_path).is_absolute()
        else Path(manifest_path)
        for manifest_path in manifest_specs
    ]
    languages = load_manifest_languages(manifest_paths)

    resource_suffix = parse_base_resource_path_append(derive_path)

    if resource_suffix is None:
        raise SystemExit(
            f"Could not derive base.resourcePath from {derive_path}; "
            "pass a dist-style jungle file with self-referential base.* assignments."
        )

    variant = infer_dist_variant(resource_suffix=resource_suffix)

    if variant is None:
        raise SystemExit(
            f"Could not infer a resource variant from {derive_path}; expected "
            "paths like ../../local/resources or ../../build/resources."
        )

    header_lines, rendered_languages = render_low_memory_header(
        variant=variant,
        resource_suffix=resource_suffix,
        languages=languages,
        base_dir=derive_path.parent,
    )

    banner = "AUTO-GENERATED by Scripts/generate_low_memory_jungle.py — DO NOT EDIT"
    output = build_output(
        header_lines=header_lines,
        devices=devices,
        languages=rendered_languages,
        banner=banner,
    )

    if args.dry_run:
        sys.stdout.write(output)
        return 0

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(output, encoding="utf-8")

    print(f"Wrote {output_path} ({len(devices)} devices)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
