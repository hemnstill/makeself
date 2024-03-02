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

busybox_exename="busybox-w64-FRP-5301-gda71f7c57.exe"
if [[ ! -z ${MOCK_BUSYBOX_EXENAME+x} ]]; then
  busybox_exename="$MOCK_BUSYBOX_EXENAME"
fi

download_url="https://frippery.org/files/busybox/$busybox_exename"
busybox_exepath="$THISDIR/$busybox_exename"
if [[ ! -f "$busybox_exepath" ]]; then
  echo "Downloading: $download_url ..."
  curl --fail --location "$download_url" --output "$busybox_exepath"
fi

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