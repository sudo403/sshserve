#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$SCRIPT_DIR/sshserve"

if [ ! -f "$SRC" ]; then
    echo "Source file not found: $SRC" >&2
    exit 1
fi

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
DEST="$BIN_DIR/sshserve"
DATA_FILE="$BIN_DIR/sshserve_connections.json"

mkdir -p "$BIN_DIR"
cp "$SRC" "$DEST"
chmod 755 "$DEST"

if [ ! -f "$DATA_FILE" ]; then
    printf '{\n  "connections": {}\n}\n' > "$DATA_FILE"
fi
chmod 600 "$DATA_FILE"

echo "Installed: $DEST"
echo "Data file: $DATA_FILE (mode 600)"

case ":$PATH:" in
    *":$BIN_DIR:"*)
        echo "PATH already contains $BIN_DIR"
        ;;
    *)
        echo "Add this to your shell profile:"
        echo "  export PATH=\"$BIN_DIR:\$PATH\""
        ;;
esac
