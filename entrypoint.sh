
#!/bin/bash
set -euo pipefail

INSTALL_DIR="/home/steam/Steam/steamapps/common/Counter-Strike Global Offensive"
GAME_DIR="$INSTALL_DIR/game/csgo"
SWIFTLY_DIR="$GAME_DIR/addons/swiftlys2"
GAMEINFO="$GAME_DIR/gameinfo.gi"

mkdir -p "/home/steam/Steam/steamapps"

# CS2 kurulumu
if [[ ! -f "$INSTALL_DIR/game/bin/linuxsteamrt64/cs2" || "${CS2_UPDATE_ON_START:-0}" == "1" ]]; then
  echo "[CS2] Installing/updating game..."
  /home/steam/steamcmd/steamcmd.sh \
    +login anonymous \
    +app_update 730 validate \
    +quit
fi

[[ -f "$INSTALL_DIR/game/bin/linuxsteamrt64/cs2" ]] || {
  echo "[CS2] Executable missing!"
  exit 1
}

[[ -f "$GAMEINFO" ]] || {
  echo "[CS2] gameinfo.gi missing!"
  exit 1
}

# SwiftlyS2 aç/kapat
if [[ "${SWIFTLY_ENABLED:-1}" == "1" ]]; then

  echo "[SwiftlyS2] Enabled"

  if [[ ! -d "$SWIFTLY_DIR" || "${SWIFTLY_UPDATE_ON_START:-0}" == "1" ]]; then

    echo "[SwiftlyS2] Downloading..."

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    curl -fsSL --retry 3 \
      -H "Accept: application/vnd.github+json" \
      -H "User-Agent: cs2-coolify-installer" \
      "https://api.github.com/repos/swiftly-solution/swiftlys2/releases/latest" \
      -o "$tmp/release.json"

    url=$(python3 - "$tmp/release.json" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
assets = r.get("assets", [])
valid = [
    a for a in assets
    if "linux" in a["name"].lower()
    and "with-runtimes" in a["name"].lower()
    and a["name"].lower().endswith(".zip")
]
if not valid:
    sys.exit("SwiftlyS2 Linux release not found")
print(valid[0]["browser_download_url"])
PY
)

    curl -fL --retry 3 "$url" -o "$tmp/swiftly.zip"
    mkdir -p "$tmp/unpacked"
    unzip -q "$tmp/swiftly.zip" -d "$tmp/unpacked"

    source_dir=$(find "$tmp/unpacked" -type d \
      -path '*/addons/swiftlys2' -print -quit)

    [[ -n "$source_dir" ]] || {
      echo "[SwiftlyS2] Installation files missing!"
      exit 1
    }

    mkdir -p "$SWIFTLY_DIR"
    cp -a "$source_dir/." "$SWIFTLY_DIR/"

    echo "[SwiftlyS2] Installed"
  fi
else
  echo "[SwiftlyS2] Disabled for diagnostic testing"
fi

# gameinfo.gi yükleme satırını yönet
python3 - "$GAMEINFO" "${SWIFTLY_ENABLED:-1}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
enabled = sys.argv[2] == "1"

lines = path.read_text().splitlines(keepends=True)

# Eski SwiftlyS2 kayıtlarını temizle
lines = [
    line for line in lines
    if not (
        line.strip().lower().startswith("game ")
        and "csgo/addons/swiftlys2" in line.lower()
    )
]

if enabled:
    for i, line in enumerate(lines):
        if "Game_LowViolence" in line and "csgo_lv" in line:
            indent = line[:len(line) - len(line.lstrip())]
            lines.insert(
                i + 1,
                indent + "Game csgo/addons/swiftlys2\n"
            )
            break
    else:
        sys.exit("[SwiftlyS2] gameinfo.gi anchor missing")

path.write_text("".join(lines))

print(
    "[SwiftlyS2] Loader enabled"
    if enabled else
    "[SwiftlyS2] Loader disabled"
)
PY

# CS2 başlat
cd "$INSTALL_DIR/game"

args=(
  -dedicated
  -console
  -usercon
  -port "${CS2_PORT:-27015}"
  +map "${CS2_MAP:-de_dust2}"
  +hostname "${CS2_HOSTNAME:-Coolify CS2 SwiftlyS2}"
  -maxplayers_override "${CS2_MAXPLAYERS:-10}"
)

if [[ -n "${CS2_GSLT:-}" ]]; then
  args+=(+sv_setsteamaccount "$CS2_GSLT")
else
  echo "[CS2] WARNING: GSLT missing"
fi

echo "[CS2] Starting server..."
exec ./bin/linuxsteamrt64/cs2 "${args[@]}"
