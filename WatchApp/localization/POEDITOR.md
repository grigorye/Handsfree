# POEditor-based localization (Connect IQ)

This repo keeps the source (English) strings in existing Garmin resource XML files (e.g. `resources/strings.xml`, `resources/properties.xml`, and some `traits/**/strings.xml`).

The approach here is:

- Treat **POEditor term keys** as **Connect IQ string IDs** (e.g. `listAppName`, `openAppOnIncomingCall`).
- Pull translations from POEditor via API (`projects/export` with `type=key_value_json`).
- Generate localized resource XML files per language that **mirror the source file layout**.
  - Example: `resources/strings.xml` → `resources-<garmin>/strings.xml`
  - Example: `local/resources/strings.xml` → `local/resources-<garmin>/strings.xml`
  - Example: `traits/complication/strings.xml` → `traits/complication/resources-<garmin>/strings.xml`
  - Garmin’s resource compiler will pick the language-specific value based on device locale.

## Setup

1. Edit `localization/poeditor.json`:
   - `project_id`: your POEditor project id.
   - `target_languages`: list of POEditor language codes and their **Garmin manifest codes**.
     - Example: POEditor `de` → Garmin `deu`.

  You can start by copying `localization/poeditor.example.json` over `localization/poeditor.json` and adjusting values.

1. Provide the API token via env var:

- `export POEDITOR_API_TOKEN="..."`

## Pull translations and generate resources

- `make poeditor-pull`

This generates:

- `resources-<garmin>/**` files that match the source layout (and trait overlays under `traits/**`).

## Pull new POEditor terms (optional)

By design, `poeditor-pull` only writes translations for string IDs that already exist in the repo’s resource XMLs.

If you add new term keys in POEditor and want them materialized into the repo automatically, use:

- `make poeditor-pull-new-terms`

This appends new `<string id="...">...</string>` entries into `resources/strings.xml` (and includes them in generated `resources-<garmin>/strings.xml`) for any POEditor term keys not found in the repo.

It does **not** overwrite existing base strings unless you also use `pull --include-reference`.

If you prefer putting new terms into a separate file, run `pull` with `--extra-strings-file resources/poeditor-extra.xml`.

To preview what would change:

- `make poeditor-pull-new-terms-dry-run`

## Pull reference language (optional)

If your *reference language text* (usually English) is maintained in POEditor and you want the repo’s base resource XMLs to match it:

- `make poeditor-pull-reference`

To preview changes without writing files:

- `make poeditor-pull-reference-dry-run`

This exports the POEditor `reference_language` and updates `<string id="...">...</string>` values in the existing base XML files in-place (it does **not** replace other sections like `<properties>` / `<settings>` in `resources/properties.xml`).

## Upload a language from the repo (optional)

If you maintain translations in the repo (e.g. by editing `resources-<garmin>/**` files) and want to push them back into POEditor:

- `make poeditor-upload-language POEDITOR_LANG=ru`

This uploads translations from the generated `resources-<garmin>` directory corresponding to that `POEDITOR_LANG` (as configured in `target_languages`) and overwrites existing translations in POEditor by default.

If you want an additive upload without replacing existing POEditor copy, use:

- `make poeditor-upload-language POEDITOR_LANG=ru POEDITOR_OVERWRITE=0`

## Enable languages in manifest

Connect IQ manifests must declare supported languages. This repo’s manifests currently list only `eng`.

- `make poeditor-update-manifests`

This updates the `manifest_files` listed in `localization/poeditor.json` to include all `garmin` language codes configured there (plus `eng`).

## Seeding POEditor (initial)

If you don’t have terms created in POEditor yet, you have two options.

### Option A: seed only term keys (no English text)

This generates a `key_value_json` skeleton with all discovered string IDs as keys:

- `python3 Scripts/poeditor_sync.py dump-terms > poeditor-seed.json`

Then import/upload it into POEditor so translators can fill in values.

### Option B: seed terms + English from the repo (recommended)

Export repo strings (IDs and their current English text):


`traits/dev/**` resource overrides (used for dev builds) are ignored when exporting/uploading reference strings.

Then either:

- Import `poeditor-en.json` in the POEditor UI as `Key-Value JSON` into language `en` (as terms + translations), or
- Upload via API:
  - `make poeditor-upload-reference`
  - Add `--overwrite` only if you really want to replace existing translations.
  - Add `--sync-terms` only if you want POEditor to delete terms missing from the upload.

## Notes / conventions

- Keep placeholders like `$1$` intact in translations.
- Multi-line strings are preserved if POEditor exports actual newlines.
- Missing translations are filled using `fallback_language` (defaults to `reference_language`).
