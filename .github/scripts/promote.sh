#!/bin/bash
set -euox pipefail

SRCDIR="$1"
TGTDIR="$2"

mkdir -p "$TGTDIR"
rsync -a --exclude 'prify.yml' "$SRCDIR/" "$TGTDIR/"
git --no-pager diff --summary

cd "$TGTDIR"
prify run
