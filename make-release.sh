#!/bin/sh
set -eu
THIS="$(realpath "$0")"
THISDIR="$(dirname "${THIS}")"

cd "$THISDIR"

# Create a distributable archive of the current version of Makeself

VER="$(cat VERSION)"
mkdir -p /tmp/makeself-"$VER" release
cp -pPR makeself* cmd-header.sh README.md COPYING VERSION /tmp/makeself-"$VER"/
./cmd-header.sh
./makeself.sh --header ./makeself-cmd-header.sh --notemp /tmp/makeself-"$VER" release/makeself-"$VER".run.bat "Makeself v$VER" echo "Makeself has extracted itself"

