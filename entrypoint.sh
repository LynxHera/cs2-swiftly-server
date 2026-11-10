#!/bin/bash
set -euo pipefail
INSTALL_DIR="/home/steam/Steam/steamapps/common/Counter-Strike Global Offensive"
GAME_DIR="$INSTALL_DIR/game/csgo"
SWIFTLY_DIR="$GAME_DIR/addons/swiftlys2"
mkdir -p "/home/steam/Steam/steamapps"
if [[ ! -f "$INSTALL_DIR/game/bin/linuxsteamrt64/cs2" || "${CS2_UPDATE_ON_START:-0}" == "1" ]]; then
  echo '[CS2] Installing/updating game in persistent Steam library...'
  /home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 730 validate +quit
fi
[[ -f "$INSTALL_DIR/game/bin/linuxsteamrt64/cs2" ]] || { echo '[CS2] executable missing' >&2; exit 1; }
if [[ ! -d "$SWIFTLY_DIR" || "${SWIFTLY_UPDATE_ON_START:-0}" == "1" ]]; then
  echo '[SwiftlyS2] Fetching latest stable Linux release with runtimes...'
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL --retry 3 -H 'Accept: application/vnd.github+json' -H 'User-Agent: cs2-coolify-installer' 'https://api.github.com/repos/swiftly-solution/swiftlys2/releases/latest' -o "$tmp/release.json"
  url=$(python3 - "$tmp/release.json" <<'PY'
import json,sys
r=json.load(open(sys.argv[1]))
assets=r.get('assets',[])
valid=[a for a in assets if 'linux' in a['name'].lower() and 'with-runtimes' in a['name'].lower() and a['name'].lower().endswith('.zip')]
if not valid:
    sys.exit('No stable Linux with-runtimes zip found; check SwiftlyS2 release assets')
print(valid[0]['browser_download_url'])
PY
)
  curl -fL --retry 3 "$url" -o "$tmp/swiftly.zip"
  mkdir -p "$tmp/unpacked"
  unzip -q "$tmp/swiftly.zip" -d "$tmp/unpacked"
  source_dir=$(find "$tmp/unpacked" -type d -path '*/addons/swiftlys2' -print -quit)
  [[ -n "$source_dir" ]] || { echo '[SwiftlyS2] addons/swiftlys2 missing from archive' >&2; exit 1; }
  mkdir -p "$SWIFTLY_DIR"
  cp -a "$source_dir/." "$SWIFTLY_DIR/"
  echo '[SwiftlyS2] Installed; existing plugin files retained.'
fi
GAMEINFO="$GAME_DIR/gameinfo.gi"
[[ -f "$GAMEINFO" ]] || { echo '[SwiftlyS2] gameinfo.gi missing' >&2; exit 1; }
python3 - "$GAMEINFO" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
if 'Game csgo/addons/swiftlys2' not in s:
    lines=s.splitlines(keepends=True)
    for i,line in enumerate(lines):
        if 'Game_LowViolence' in line and 'csgo_lv' in line:
            indent=line[:len(line)-len(line.lstrip())]
            lines.insert(i+1,indent+'Game csgo/addons/swiftlys2\n')
            p.write_text(''.join(lines))
            print('[SwiftlyS2] gameinfo.gi loader registered')
            break
    else:
        sys.exit('[SwiftlyS2] Game_LowViolence anchor not found in gameinfo.gi')
PY
cd "$INSTALL_DIR/game"
args=(-dedicated -console -usercon -port "${CS2_PORT:-27015}" +map "${CS2_MAP:-de_dust2}" +hostname "${CS2_HOSTNAME:-Coolify CS2 SwiftlyS2}" -maxplayers_override "${CS2_MAXPLAYERS:-10}")
if [[ -n "${CS2_GSLT:-}" ]]; then args+=(+sv_setsteamaccount "$CS2_GSLT"); else echo '[CS2] WARNING: GSLT missing'; fi
exec ./bin/linuxsteamrt64/cs2 "${args[@]}"
