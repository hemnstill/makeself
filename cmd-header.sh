#!/bin/bash
set -eu
THIS="$(realpath "$0")"
THISDIR="$(dirname "${THIS}")"

tmp_dirpath="${TMPDIR:-/tmp}/makeself/$$"
mkdir -p "$tmp_dirpath"

content_before="$tmp_dirpath/content_before.sh"
content_after="$tmp_dirpath/content_after.sh"
content_busybox="$tmp_dirpath/_content.txt"

content_makeself_header_line="$tmp_dirpath/_content_header_line.txt"
cat "$THISDIR/makeself-header.sh" | head -n 1 > "$content_makeself_header_line"

content_makeself_header="$tmp_dirpath/_content_header.txt"
cat "$THISDIR/makeself-header.sh" | tail -n +2 > "$content_makeself_header"

win_header_path="$THISDIR/makeself-cmd-header.sh"

busybox_exename="busybox-w64-FRP-4716-g31467ddfc.exe"
busybox_exepath="$THISDIR/$busybox_exename"
[[ ! -f "$busybox_exepath" ]] && curl --fail --location "https://frippery.org/files/busybox/busybox-w64-FRP-4716-g31467ddfc.exe" --output "$busybox_exepath"

{
  echo -----BEGIN CERTIFICATE-----
  base64 "$busybox_exepath"
  echo -----END CERTIFICATE-----
} > "$content_busybox"

{ printf ': '\''"
@echo off
set busybox_local=%%temp%%\%s
if not exist %%busybox_local%% (
  certutil.exe -f -decode "%%~f0" "%%busybox_local%%"
)
goto :entrypoint

' "$busybox_exename"
} > "$content_before"

{ printf '
:entrypoint
"%%busybox_local%%" sh "%%~f0" %%*
exit /b %%errorlevel%%
"'\''

'
} > "$content_after"

cat "$content_makeself_header_line" "$content_before" "$content_busybox" "$content_after" "$content_makeself_header" > "$win_header_path"

echo cmd header created: "'$win_header_path'"