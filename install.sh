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
PATH_LINE="export PATH=\"$BIN_DIR:\$PATH\""

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
        PROFILE="${PROFILE:-}"
        if [ -z "$PROFILE" ]; then
            case "${SHELL:-}" in
                */zsh) PROFILE="$HOME/.zshrc" ;;
                */bash) PROFILE="$HOME/.bashrc" ;;
                *) PROFILE="$HOME/.profile" ;;
            esac
        fi

        if [ -e "$PROFILE" ] && [ ! -w "$PROFILE" ]; then
            echo "Cannot write to $PROFILE. Add this line manually:"
            echo "  $PATH_LINE"
        else
            if [ ! -e "$PROFILE" ]; then
                : > "$PROFILE"
            fi

            if grep -Fqx "$PATH_LINE" "$PROFILE"; then
                echo "PATH entry already exists in $PROFILE"
            else
                printf '\n# Added by sshserve installer\n%s\n' "$PATH_LINE" >> "$PROFILE"
                echo "Added PATH entry to $PROFILE"
            fi
        fi
        echo "For current shell run:"
        echo "  $PATH_LINE"
        echo "  hash -r"
        ;;
esac
