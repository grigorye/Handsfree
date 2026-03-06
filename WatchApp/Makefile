all:
	./build-all app
	./build-all widget

.PHONY: poeditor-pull poeditor-update-manifests
.PHONY: poeditor-export-reference poeditor-upload-reference
.PHONY: poeditor-upload-language
.PHONY: poeditor-pull-reference
.PHONY: poeditor-pull-reference-dry-run
.PHONY: poeditor-pull-new-terms poeditor-pull-new-terms-dry-run

poeditor-pull:
	# Pull translations and generate localized resource XMLs.
	# Output mirrors the source resource layout, e.g.:
	#   resources/strings.xml -> resources-<garmin>/strings.xml
	#   traits/<trait>/strings.xml -> traits/<trait>/resources-<garmin>/strings.xml
	python3 Scripts/poeditor_sync.py pull

poeditor-pull-reference:
	# Pull POEditor reference language and update base resource XML string values in-place.
	# Useful when English text is maintained in POEditor and you want the repo to match.
	python3 Scripts/poeditor_sync.py pull --include-reference

poeditor-pull-reference-dry-run:
	# Preview what poeditor-pull-reference would change.
	python3 Scripts/poeditor_sync.py pull --include-reference --dry-run

poeditor-pull-new-terms:
	# Pull reference + translations and materialize any POEditor-only term keys into resources/strings.xml
	python3 Scripts/poeditor_sync.py pull --include-new-terms

poeditor-pull-new-terms-dry-run:
	# Preview what poeditor-pull-new-terms would write/update.
	python3 Scripts/poeditor_sync.py pull --include-new-terms --dry-run

poeditor-update-manifests:
	python3 Scripts/poeditor_sync.py update-manifests

poeditor-export-reference:
	python3 Scripts/poeditor_sync.py export-reference

poeditor-upload-reference:
	python3 Scripts/poeditor_sync.py upload-reference

poeditor-upload-language:
	# Upload a specific language from generated resources-<lang>/ XMLs back to POEditor.
	# By default this overwrites existing POEditor translations for that language.
	# Usage: make poeditor-upload-language POEDITOR_LANG=ru [POEDITOR_OVERWRITE=0]
	@test -n "$(POEDITOR_LANG)"
	python3 Scripts/poeditor_sync.py upload-language --language "$(POEDITOR_LANG)" $(if $(filter 0 false no,$(POEDITOR_OVERWRITE)),, --overwrite)
