#!/usr/bin/env bash
# Usage: paste-image.sh <vault_root> <note_path>
# Outputs the markdown image link to stdout

VAULT="$1"
NOTE_PATH="$2"
ASSETS_DIR="$VAULT/assets/images"

# --- Probe clipboard for image/png availability without reading binary data ---

has_image=0

if command -v xclip &>/dev/null; then
  xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -q 'image/png' && has_image=1
elif command -v wl-paste &>/dev/null; then
  wl-paste --list-types 2>/dev/null | grep -q 'image/png' && has_image=1
elif [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'the clipboard as «class PNGf»' &>/dev/null && has_image=1
fi

if [[ "$has_image" -eq 0 ]]; then
  echo "ERROR: no image in clipboard" >&2
  exit 1
fi

# --- Clipboard has an image: safe to create files now ---

mkdir -p "$ASSETS_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="${TIMESTAMP}-unprocessed.png"
DEST="$ASSETS_DIR/$FILENAME"

if command -v xclip &>/dev/null; then
  xclip -selection clipboard -t image/png -o > "$DEST"
elif command -v wl-paste &>/dev/null; then
  wl-paste --type image/png > "$DEST"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'set png_data to the clipboard as «class PNGf»
    set file_path to POSIX file "'"$DEST"'"
    set fileRef to open for access file_path with write permission
    write png_data to fileRef
    close access fileRef'
fi

if [[ ! -s "$DEST" ]]; then
  rm -f "$DEST"
  echo "ERROR: failed to write image" >&2
  exit 1
fi

REL_PATH="assets/images/$FILENAME"
printf '![](%s)' "$REL_PATH"

