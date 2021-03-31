#!/bin/bash
set -euo pipefail

SRCGLOB="$1"
TGTDIR="$2"

mkdir -p "$TGTDIR" && cp -r $SRCGLOB "$TGTDIR/"
