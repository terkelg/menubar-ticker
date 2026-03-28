#!/bin/zsh

set -euo pipefail

root=${0:A:h:h}
proj="$root/menubar-ticker.xcodeproj"
scheme=MenubarTicker
dest='platform=macOS'
team=${TEAM_ID:-}
cfg=Release
out="$root/dist"

cd "$root"
xcodebuild -project "$proj" -scheme "$scheme" -configuration "$cfg" -destination "$dest" build >/dev/null

eval "$(
  xcodebuild -project "$proj" -scheme "$scheme" -configuration "$cfg" -destination "$dest" -showBuildSettings |
    awk -F ' = ' '
      /Build settings for action build and target MenubarTicker:/ { flag = 1; next }
      /Build settings for action build and target / && flag { exit }
      flag && $1 ~ /^[[:space:]]*CODESIGNING_FOLDER_PATH$/ { print "src=\"" $2 "\"" }
      flag && $1 ~ /^[[:space:]]*MARKETING_VERSION$/ { print "ver=\"" $2 "\"" }
      flag && $1 ~ /^[[:space:]]*CURRENT_PROJECT_VERSION$/ { print "build=\"" $2 "\"" }
    '
)"

if [[ -z ${src:-} ]]; then
  echo "missing app bundle path" >&2
  exit 1
fi

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

app=${src:t}
name=${app:r}
tag=${ver:-0.1.0}-${build:-1}
dst="$out/$app"
zip="$out/$name-$tag.zip"
fw="$dst/Contents/Frameworks/TickerCore.framework"

mkdir -p "$out"
rm -rf "$dst"
rm -f "$zip"
ditto "$src" "$dst"

if [[ -d "$fw" ]]; then
  /usr/bin/codesign --force --sign "$id" --timestamp=none "$fw"
fi
/usr/bin/codesign --force --sign "$id" --timestamp=none "$dst"
/usr/bin/codesign --verify --deep --strict "$dst"

ditto -c -k --keepParent --norsrc --noextattr --noqtn --noacl "$dst" "$zip"

echo "$dst"
echo "$zip"
