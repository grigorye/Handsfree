#! /usr/bin/env /bin/bash
# shellcheck shell=bash

set -euo pipefail

wd=$(dirname "$0")
src_root=$(cd "$wd/.." && pwd)
output_root=
manifest_paths=()
manifest_languages=()

read_manifest_languages() {
    local manifest_path="$1"

    sed 's/iq://g' "$manifest_path" |
        xq -r '.manifest.application.languages.language | if type=="array" then .[] else . end'
}

append_manifest_languages() {
    local manifest_path="$1"
    local lang

    while IFS= read -r lang; do
        [[ -n "$lang" ]] || continue
        [[ " ${manifest_languages[*]-} " == *" $lang "* ]] && continue
        manifest_languages+=("$lang")
    done < <(read_manifest_languages "$manifest_path")
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --output-root)
        output_root="$2"
        shift 2
        ;;
    --manifest)
        manifest_paths+=("$2")
        shift 2
        ;;
    *)
        echo "Unknown argument: $1" >&2
        exit 1
        ;;
    esac
done

if [[ -z "$output_root" ]]; then
    echo "--output-root is required" >&2
    exit 1
fi

if [[ ${#manifest_paths[@]} -eq 0 ]]; then
    manifest_paths=("$src_root/manifest-app.xml" "$src_root/manifest-widget.xml")
fi

if [[ "$output_root" != /* ]]; then
    output_root="$src_root/$output_root"
fi

source_hash=$(git -C "$src_root" describe --match '736fd2e' --dirty --always | sed 's/dirty/?/g')
source_commits=$(git -C "$src_root" rev-list --count HEAD)
source_version="$source_commits-$source_hash"

mkdir -p "$output_root/source" "$output_root/resources"

sed -e "s/__SOURCE_VERSION__/$source_version/g" \
    "$src_root"/local/source/SourceVersion.mc-template >"$output_root"/source/SourceVersion.mc

sed -e "s/__SOURCE_VERSION__/$source_version/g" \
    "$src_root"/local/resources/sourceVersion.xml-template >"$output_root"/resources/sourceVersion.xml

for manifest_path in "${manifest_paths[@]}"; do
    append_manifest_languages "$manifest_path"
done

for lang in "${manifest_languages[@]}"; do
    if [[ -z "$lang" || "$lang" == "eng" ]]; then
        continue
    fi

    localized_source_version_template="$src_root/local/resources-$lang/sourceVersion.xml-template"
    if [[ ! -f "$localized_source_version_template" ]]; then
        localized_source_version_template="$src_root/local/resources/sourceVersion.xml-template"
    fi

    mkdir -p "$output_root/resources-$lang"
    sed -e "s/__SOURCE_VERSION__/$source_version/g" \
        "$localized_source_version_template" >"$output_root/resources-$lang/sourceVersion.xml"
done