#!/bin/bash
set -euox pipefail

SRCDIR="$1"
TGTDIR="$2"

mkdir -p "$TGTDIR"
# options: archive, recursive, permissions, checksum (file matching), delete added files
rsync -arpch --delete  --exclude 'prify.yml' --exclude 'env-specific*' "$SRCDIR/" "$TGTDIR/"
git --no-pager diff --summary

cd "$TGTDIR"
git config --global user.email "promotion@gh.actions"
git config --global user.name "PRify (promote-to-prod)"
echo "$GH_REPO_PAT_TOKEN" | gh auth login --with-token
prify run
