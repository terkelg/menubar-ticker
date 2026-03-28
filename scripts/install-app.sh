#!/bin/zsh

set -euo pipefail

root=${0:A:h:h}
proj="$root/menubar-ticker.xcodeproj"
scheme=MenubarTicker
dest='platform=macOS'
team=${TEAM_ID:-}

cd "$root"
xcodebuild -project "$proj" -scheme "$scheme" -destination "$dest" build >/dev/null

src="$(
  xcodebuild -project "$proj" -scheme "$scheme" -destination "$dest" -showBuildSettings |
    awk -F ' = ' '
      /Build settings for action build and target MenubarTicker:/ { flag = 1; next }
      /Build settings for action build and target / && flag { exit }
      flag && $1 ~ /^[[:space:]]*CODESIGNING_FOLDER_PATH$/ { print $2; exit }
    '
)"

if [[ -z "$src" ]]; then
  echo "missing app bundle path" >&2
  exit 1
fi

app=${src:t}
dst="/Applications/$app"
id=$(
  security find-identity -v -p codesigning |
    awk -v team="$team" '
      /Apple Development:/ && match($0, /[0-9A-F]{40}/) {
        if (team == "" || index($0, "(" team ")")) {
          print substr($0, RSTART, RLENGTH)
          exit
        }
      }
    '
)

if [[ -z "$id" ]]; then
  if [[ -n "$team" ]]; then
    echo "missing Apple Development identity for team $team" >&2
  else
    echo "missing Apple Development identity" >&2
  fi
  exit 1
fi

fw="$src/Contents/Frameworks/TickerCore.framework"
if [[ -d "$fw" ]]; then
  /usr/bin/codesign --force --sign "$id" --timestamp=none "$fw"
fi
/usr/bin/codesign --force --sign "$id" --timestamp=none "$src"

pkill -x MenubarTicker >/dev/null 2>&1 || true
rm -rf "$dst"
ditto "$src" "$dst"
open -na "$dst"
