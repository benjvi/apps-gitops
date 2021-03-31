#!/bin/bash
set -euox pipefail

SRCGLOB="$1"
TGTDIR="$2"

mkdir -p "$TGTDIR" && cp -r $SRCGLOB "$TGTDIR/"
git --no-pager diff --summary
