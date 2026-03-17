#!/usr/bin/env python3

"""List device IDs enabled in either Connect IQ manifest.

By default this compares manifest-app.xml and manifest-widget.xml from the
repository root and prints the combined product IDs, one per line.
"""

from __future__ import annotations

import argparse
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


CONNECT_IQ_NS = {"iq": "http://www.garmin.com/xml/connectiq"}


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments for the manifest comparison script."""
    repo_root = Path(__file__).resolve().parent.parent

    parser = argparse.ArgumentParser(
        description="List device IDs enabled in either manifest file."
    )
    parser.add_argument(
        "manifest_a",
        nargs="?",
        default=repo_root / "manifest-app.xml",
        type=Path,
        help="First manifest to compare.",
    )
    parser.add_argument(
        "manifest_b",
        nargs="?",
        default=repo_root / "manifest-widget.xml",
        type=Path,
        help="Second manifest to compare.",
    )
    return parser.parse_args()


def load_device_ids(manifest_path: Path) -> set[str]:
    """Load all product ids from a Connect IQ manifest file."""
    if not manifest_path.exists():
        raise SystemExit(f"Manifest not found: {manifest_path}")

    try:
        tree = ET.parse(manifest_path)
    except ET.ParseError as exc:
        raise SystemExit(f"Failed to parse {manifest_path}: {exc}") from exc

    device_ids = {
        element.attrib["id"]
        for element in tree.findall(".//iq:products/iq:product", CONNECT_IQ_NS)
        if element.attrib.get("id")
    }

    if not device_ids:
        raise SystemExit(f"No device IDs found in {manifest_path}")

    return device_ids


def get_manifest_device_ids(manifest_a: Path, manifest_b: Path) -> list[str]:
    """Return sorted device ids present in either manifest file."""
    return sorted(load_device_ids(manifest_a) | load_device_ids(manifest_b))


def main() -> int:
    """Print device ids that are present in either manifest file."""
    args = parse_args()
    device_ids = get_manifest_device_ids(args.manifest_a, args.manifest_b)

    for device_id in device_ids:
        print(device_id)

    return 0


if __name__ == "__main__":
    sys.exit(main())
