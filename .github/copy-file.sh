#!/bin/bash
set -euo pipefail

SRCPATH="$1"
TGTDIR="$2"
TGTFILE="$3"

mkdir -p "$TGTDIR" && cp "$SRCPATH" "$TGTDIR/$TGTFILE"
git --no-pager diff
